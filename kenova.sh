#!/bin/bash
# - title        : kenova
# - description  : This script will assist in the use of the Cloud Servers Python Script..
# - author       : Kevin Carter
# - date         : 2012-06-05
# - version      : 1.4    
# - usage        : bash kenova
# - notes        : Requires Python, NovaClient; 
# - notes        : While not needed for operation, Git is needed for installation.
# - notes        : the python-novaclient can be gotten here = https://github.com/openstack/python-novaclient
# - bash_version : >= 3.2.48(1)-release
#### ========================================= ####

## User Defined ##

# Installer for the python-novaclient script
LNOVAVERSIONGIT="git://github.com/rackspace/python-novaclient.git"
LNOVAVERSION="http://downloads.rackerua.com/Rackspace/legacy-python-novaclient.rackerua.tgz"
LNOVANAME="legacy-python-novaclient.rackerua.tgz"

# Installer for the python-novaclient script
NOVAVERSIONGIT="git://github.com/openstack/python-novaclient.git"
NOVAVERSION="http://downloads.rackerua.com/Rackspace/open-cloud-python-novaclient.rackerua.tgz"
NOVANAME="open-cloud-python-novaclient.rackerua.tgz"


if [ ! `which python` ];then
clear 
echo 'This is a Python Wrapper, which requires that you have Python installed.'
echo 'You will need to install Python in order to proceed.'
exit 1
fi

# Defined Variables --
## Where is the script located ---
SCRIPTLOCATION="$0"

## How long show I retain the information, in seconds ---
SLEEPTIME="1800"

CHECKFORROOT(){
# Root user check for install 
USERCHECK=$( whoami  )
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as ROOT"
        echo "You have attempted to run this as $USERCHECK"
                echo "use sudo $0 $1 or change to root."
   exit 1
fi
}

REPAIRFOOBAREDMODULES(){
echo ''
echo 'Checking for Incompatible Versions of Python Packages.'
echo ''

if [ -f ~/ShittyModulesHttpLib.txt ];then 
	rm ~/ShittyModulesHttpLib.txt
fi

if [ -f ~/ShittyModulesPrettyTable.txt ];then 
	rm ~/ShittyModulesPrettyTable.txt
fi

if [ -f /tmp/badPythonDir.txt ];then
rm /tmp/badPythonDir.txt
fi

echo "Looking in Known Standard Locations for Python Modules."
if [ -d /Library/ ];then
echo '/Library/' >> /tmp/badPythonDir.txt
fi

if [ -d /opt/local/ ];then 
echo '/opt/local/' >> /tmp/badPythonDir.txt
fi
	
if [ -d /usr/local/lib/ ];then 
echo '/usr/local/lib/' >> /tmp/badPythonDir.txt
fi
		
if [ -d /usr/lib/ ];then
echo '/usr/lib/' >> /tmp/badPythonDir.txt
fi

if [ -f /tmp/badPythonPurgeList.txt ];then
rm /tmp/badPythonPurgeList.txt
fi

echo "Building List of known bad Modules."
for P1L in {5..8}; do echo "httplib2-0.7.${P1L}*" >> /tmp/badPythonPurgeList.txt;done
for P2L in {7..9}; do echo "prettytable-0.${P2L}*" >> /tmp/badPythonPurgeList.txt;done

if [ -f ~/BadModules.txt ];then 
rm ~/BadModules.txt
fi

echo "Looking for and Removing Bad Modules."
for BadD in `cat /tmp/badPythonDir.txt`;
	do 
		for BadM in `cat /tmp/badPythonPurgeList.txt`;
			do 
				find $BadD -name $BadM -exec rm -rf {} \; 
			done;
	done; >> ~/BadModules.txt

SHITTYVERSIONSHTTPLIB2 > /dev/null
SHITTYVERSIONSPRETTYTABLE > /dev/null
for NOVADELETE in `ls /tmp/ | grep python-nova`;do rm -rf $NOVADELETE; done

if [ -z ~/BadModules.txt ];then
echo "Record of Purge can be found here : ~/BadModules.txt"
fi 

echo 'Cleanup Done'
}

SHITTYVERSIONSHTTPLIB2(){
CHECKHTTPLIB2=`python -c "try:
    import httplib2
except ImportError, e:
    print 'FAIL'
"`
if [ "$CHECKHTTPLIB2" == "FAIL" ];then
echo "The Python Module httplib2 was not found, I am performing a manual installation"
	cd /tmp/
	if [ `which curl` ];then
		echo "using CURL"
		curl -s -O http://httplib2.googlecode.com/files/httplib2-0.7.1.tar.gz
				elif [ `which wget` ];then
					echo "using WGET"
					wget http://httplib2.googlecode.com/files/httplib2-0.7.1.tar.gz
						else
							echo "We are failing because we found no way to proceed."
							exit 1
	fi
echo "Installing httplib2-0.7.1"
	tar xzf /tmp/httplib2-0.7.1.tar.gz -C /tmp/
	cd /tmp/httplib2-0.7.1/
	python /tmp/httplib2-0.7.1/setup.py install
fi
}

SHITTYVERSIONSPRETTYTABLE(){
CHECKPRETTYTABLE=`python -c "try:
    import prettytable
except ImportError, e:
    print 'FAIL'
"`
if [ "$CHECKPRETTYTABLE" == "FAIL" ];then 
echo "The Python Module prettytable was not found, I am performing a manual installation"
	cd /tmp/
	if [ `which curl` ];then
		echo "using CURL"
		curl -s -O http://pypi.python.org/packages/source/P/PrettyTable/prettytable-0.5.tar.gz
			elif [ `which wget` ];then
				echo "using WGET"
				wget http://pypi.python.org/packages/source/P/PrettyTable/prettytable-0.5.tar.gz
					else
						echo "We are failing because we found no way to proceed."
						exit 1
	fi
	tar xzf /tmp/prettytable-0.5.tar.gz
	cd /tmp/prettytable-0.5/
	python /tmp/prettytable-0.5/setup.py install
fi
}

REMEMBERINFO(){

  API1=$(awk '{print $1}' /tmp/cloudapi.info)
  API2=$(awk '{print $2}' /tmp/cloudapi.info)
  API3=$(awk '{print $3}' /tmp/cloudapi.info)

### This prints the USERNAME and the API-KEY that you specified earlier ----
    echo ''
    echo "Remember You have set the USERNAME : $API1"
    echo "Remember You have set the API-Key  : $API2"
	if [ "$API3" ];then 
		echo "The System returned a User DDI of      : $API3"
	fi

}

GODEFINED(){
# Go is used to start the script one a Username and API-KEY have been set --
### This is a sanity check to make sure that you have set an account ----
if [ -f /tmp/cloudapi.info ];then

	REMEMBERINFO

### If check fails this prints to let you know ----
                else
                        echo 'AND THEN???'
                        echo "You have not set an account., and to use this you need to..."
                        echo "Use the command [ $0 new ] and then set the USERNAME and API-KEY"
                        echo "Example : $0 new <SOME USERNAME> <SOME API-KEY>"
                        echo ''
                        exit 1
fi
}

# Installer for the kenova command and control script
INSTALLKENOVA(){
	echo ''
	echo "Installing the kenova script"
	cp $0 /usr/bin/kenova
	chmod +x /usr/bin/kenova
	chmod 0755 /usr/bin/kenova
}

case "$1" in
repair)
CHECKFORROOT
REPAIRFOOBAREDMODULES
;;

upgrade)
CHECKFORROOT
echo "Upgrading the kenova script"
	if [ `which curl` ];then 
		echo "using CURL"
		cd /tmp
			curl -s -O http://downloads.rackerua.com/tools/kenova.sh
				elif [ `which wget` ];then
				cd /tmp
					echo "using WGET"
					wget http://downloads.rackerua.com/tools/kenova.sh
						else
							echo "We are failing because we found no way to proceed."
							exit 1
	fi
	echo ''
	echo "Installing the kenova script"
	cp /tmp/kenova.sh /usr/bin/kenova
	chmod +x /usr/bin/kenova
	chmod 0755 /usr/bin/kenova
;;
install)
CHECKFORROOT
if [ ! `which git` ];then
	echo ''
	echo "Git was not found on this Instance.  You should install GIT to ensure compatibility,"
	echo "however, I can use fall back mode to retrieve the files but it is not guaranteed to work."
	echo "While Fall Back mode may work, I would recommend that you install a GIT client on this system before continuing."
	echo "Would you like to continue?"
	echo ''
	read -p "Please Answer [ yes ] or [ no ] ; " YESGIT
	echo ''
case "${YESGIT}" in 
yes | YES | Yes) 
echo "Proceeding in Fall Back Mode, but dont cry if this does not work."
sleep 5
;;
no | NO | No)
echo "Good Choice, please install Git and then I will be happy to continue."
exit 0
;;
*)
echo "I Did not understand what you wanted to do, so I quit."
exit 0
esac
	
fi

if [ `which curl` ];then
clear
echo "Located cURL" 
echo "Continuing with the installation."
	elif [ `which wget` ];then
		clear
		echo "You do not have WGET installed."
		echo "I am going to continue because I can use CURL,"
		echo "but you should think about resolving that." 
		sleep 5
			else 
				echo "NO Curl or WGET Found.  I cant continue..."
				echo "Install these applications and I will be happy to perform the automated Installation."
					exit 0
fi


SETUPTOOLSCHECK(){
echo "Checking for Python Setup Tools"
CHECKSETUPTOOLS=`python -c "try:
    import setuptools
except ImportError, e:
    print 'FAIL'
"`
if [ "$CHECKSETUPTOOLS" == "FAIL" ];then  
	echo "Setup Tools was not found on your System, I am attempting to install the Python Module.";
	echo ''
PYTHONVERSIONNUMBER=`python -c 'import sys; print sys.version[:3]'`
SETUPTOOLSVERSION=`curl -s http://pypi.python.org/pypi/setuptools | grep "http://pypi.python.org/packages/$PYTHONVERSIONNUMBER/"|sed -e 's/<a\ href\=//g' -e 's/\"//g' -e 's/#.*//g' -e 's/^[ ]*//g'|grep -v .exe`
SETUPTOOLSNAME=`echo ${SETUPTOOLSVERSION}|awk -F '/' '{print $8}'`
	if [ -z "$SETUPTOOLSVERSION" ];then 
		echo "Sorry though your version of Python has no Version of SetupTools Available."
		echo "Please Goto http://pypi.python.org/pypi/setuptools to see if there is a version available."
		exit 1 
	fi

	echo ''
	echo "1 - I am getting the installation files for python-setuptools."
	cd /tmp/
	echo "Installing $SETUPTOOLSNAME"
	curl -O ${SETUPTOOLSVERSION}
	sh /tmp/$SETUPTOOLSNAME > ~/SetupTools.Installation.log

fi 
}

SETUPTOOLSCHECK

if [ `which kenova` ];then
	echo ''
	echo "Nothing to do, kenova is alread installed. You can find it here `which kenova`"
	echo "However I can overwrite it..."
	echo "Would you like to replace the script?"
read -p "[ yes ] or [ no ] : " REINSTALLKENOVA

case "${REINSTALLKENOVA}" in 
yes | YES | Yes )
INSTALLKENOVA
;;
no | NO | No )
echo "Nothing Done"
;;
*)
echo "We Did not understand your input so I quit..."
exit 0
;;
esac
echo ''
fi

if [ ! `which kenova` ];then
INSTALLKENOVA
fi

INSTALLNOVACLIENT(){
if [ -d /tmp/python-novaclient ];then 
	rm -rf /tmp/python-novaclient
fi

	echo ''
	echo "2 - I am getting the installation files for python-novaclient."
	cd /tmp/
	echo "Installing Open Cloud $NOVANAME"
	if [ `which git` ];then
		if [ -d python-novaclient ];then 
			rm -rf python-novaclient
		fi
			git clone ${NOVAVERSIONGIT}
	elif [ `which curl` ];then 
		if [ -f /tmp/$NOVANAME ];then 
			rm /tmp/$NOVANAME
		fi
		echo "using CURL"
		echo "${NOVAVERSION}"
			curl -s -O ${NOVAVERSION} 
				elif [ `which wget` ];then
					if [ -f /tmp/$NOVANAME ];then 
						rm /tmp/$NOVANAME
					fi
					echo "using WGET"
					wget --no-check-certificate ${NOVAVERSION}
						else
							echo "We are failing because we found no way to proceed."
							exit 1
	fi
	
	if [ -f /tmp/$NOVANAME ];then
		echo "Un-Tar'ing $NOVANAME"	
		tar -xzvf /tmp/$NOVANAME
	fi
	
if [ -f /tmp/python-novaclient/tools/pip-requires ];then
	if [ `grep -i prettytable /tmp/python-novaclient/tools/pip-requires` ];then
		sed 's/prettytable==0\.6/prettytable==0\.5/g' /tmp/python-novaclient/tools/pip-requires > /tmp/pip-requires.mod
			rm /tmp/python-novaclient/tools/pip-requires
				mv /tmp/pip-requires.mod /tmp/python-novaclient/tools/pip-requires
		else 
			echo 'prettytable==0.5' >> /tmp/python-novaclient/tools/pip-requires
	fi
fi

if grep prettytable /tmp/python-novaclient/setup.py;then
		sed 's/prettytable/prettytable==0\.5/g' /tmp/python-novaclient/setup.py > /tmp/setup.py
			rm /tmp/python-novaclient/setup.py
				mv /tmp/setup.py /tmp/python-novaclient/setup.py
fi

cd /tmp/python-novaclient
	python setup.py install > ~/NovaClient.Installation.log

if [ -d /tmp/python-novaclient ];then 
	rm -rf /tmp/python-novaclient
fi
}

INSTALLLNOVACLIENT(){
if [ -d /tmp/python-novaclient ];then 
	rm -rf /tmp/python-novaclient
fi

	echo ''
	echo "3 - I am getting the installation files for python-novaclient."
	cd /tmp/
	echo "Installing Legacy $LNOVANAME"
	if [ `which git` ];then
		if [ -d python-novaclient ];then 
			rm -rf python-novaclient
		fi	
			git clone ${LNOVAVERSIONGIT}
	elif [ `which curl` ];then 
	if [ -f /tmp/$LNOVANAME ];then 
		rm /tmp/$LNOVANAME
	fi	
		echo "using CURL"
			curl -s -O ${LNOVAVERSION}
				elif [ `which wget` ];then
					if [ -f /tmp/$LNOVANAME ];then 
						rm /tmp/$LNOVANAME
					fi				
					echo "using WGET"
					wget --no-check-certificate ${LNOVAVERSION}
						else
							echo "We are failing because we found no way to proceed."
							exit 1
	fi
	
	if [ -f /tmp/$LNOVANAME ];then
		echo "Un-Tar'ing $LNOVANAME"	
		tar -xzvf /tmp/$LNOVANAME
	fi	
	
	cd /tmp/python-novaclient

if [ -f /tmp/python-novaclient/tools/pip-requires ];then
	if [ `grep -i prettytable /tmp/python-novaclient/tools/pip-requires` ];then
		sed 's/prettytable==0\.6/prettytable==0\.5/g' /tmp/python-novaclient/tools/pip-requires > /tmp/pip-requires.mod
			rm /tmp/python-novaclient/tools/pip-requires
				mv /tmp/pip-requires.mod /tmp/python-novaclient/tools/pip-requires
		else 
			echo 'prettytable==0.5' >> /tmp/python-novaclient/tools/pip-requires
	fi
fi

if grep prettytable /tmp/python-novaclient/setup.py;then
		sed 's/prettytable/prettytable==0\.5/g' /tmp/python-novaclient/setup.py > /tmp/setup.py
			rm /tmp/python-novaclient/setup.py
				mv /tmp/setup.py /tmp/python-novaclient/setup.py
fi

	python setup.py install > ~/LNovaClient.Installation.log
		LEGACYNOVA=`which nova`
			mv $LEGACYNOVA `echo $LEGACYNOVA | sed 's/nova/lnova/'`
			
if [ -d /tmp/python-novaclient ];then 
	rm -rf /tmp/python-novaclient
fi
}

if [ `which lnova` ];then
echo ''
echo "Nothing to do, Legacy python-novaclient has already been installed."
echo "However I can overwrite it..."
echo "Would you like to replace Legacy python-novaclient?"
read -p "[ yes ] or [ no ] : " REINSTALLLNOVACLIENT

case "${REINSTALLLNOVACLIENT}" in 
yes | YES | Yes )
INSTALLLNOVACLIENT
;;
no | NO | No )
echo "Nothing Done"
;;
*)
echo "We Did not understand your input so I quit..."
exit 0
;;
esac

echo ''
fi

if [ ! `which lnova` ];then
INSTALLLNOVACLIENT
fi


if [ `which nova` ];then
echo ''
echo "Nothing to do, Open Cloud python-novaclient has already been installed."
echo "However I can overwrite it..."
echo "Would you like to replace Open Cloud python-novaclient?"
read -p "[ yes ] or [ no ] : " REINSTALLNOVACLIENT

case "${REINSTALLNOVACLIENT}" in 
yes | YES | Yes )
INSTALLNOVACLIENT
;;
no | NO | No )
echo "Nothing Done"
;;
*)
echo "We Did not understand your input so I quit..."
exit 0
;;
esac

echo ''
fi

if [ ! `which nova` ];then
INSTALLNOVACLIENT
fi

REPAIRFOOBAREDMODULES
 
echo ''
echo 'The Log for the installation has been written to :'
echo '~/NovaClient.Installation.log'
echo '~/LNovaClient.Installation.log'
echo ''
echo 'The script has been installed, and is part of your $PATH'
echo 'Usage: kenova <EXPRESSION>'
echo ''

exit 1
;;

where)
# This will tell you where the Script has been Placed --
echo "Because you were asking so nice I will tell you where I am."
echo $SCRIPTLOCATION
echo "happy now?"
;;

new)
# This Function allows for a New USER and API key to be entered --
clear
## Before Entering the New User Information the script cleans up any remnants that may have been running ---

### These are defined Variables, they are used to identify the processes that were running ----
KILLINFO=$( ps aux | grep cloudapi.info.removal | grep bash | awk '{print $2}' )
KILLSLEEP=$( ps aux | grep sleep | grep $SLEEPTIME | awk '{print $2}' )

### This removes the timed out removal script ----
if [ -f /tmp/cloudapi.info.removal ];then
    rm /tmp/cloudapi.info.removal > /dev/null
    echo "I hate left overs..."
	sleep 1
fi      

### This makes sure that the Process PIDs are killed ----
      if [ "$KILLINFO" ]; then
        echo "I found some things that need to be stopped before we can continue"
        echo "If there were more than one set of processes running you will have a nice list at the bottom"
        for KI in `ps aux | grep cloudapi.info.removal | grep bash | awk '{print $2}'`; do kill -9 $KI > /dev/null; done
		sleep 2
      fi
	if [ "$KILLSLEEP" ]; then
        echo 'killing sleepy processes'
        for KS in `ps aux | grep sleep | grep $SLEEPTIME | awk '{print $2}'`; do kill -9 $KS > /dev/null; done
		sleep 2
        fi
echo ''

### This is a sanity check to make sure you have specified a USERNAME ---- 
if [ -z $2 ];then 
echo "You have not specified a USERNAME, Please try again"
exit 1

### This is a Sanity check to make sure you have specified a API-KEY ----
### This also makes sure that the API-KEY is at least 20 characters long ----
	elif [ ! $(echo ${3} | wc -c) -gt 20 ];then 
		echo "Your API-KEY is not long enough or you did not put one, Please try again..."
		exit 1
		else
		
## This is the translation from seconds to minutes ---
TTLFORINFO=$( expr $SLEEPTIME / 60 )

# Bulding API Cookie 
echo "$2 $3" > /tmp/cloudapi.info
	DDI=`kenova ous credentials | awk -F "'" '/tenant/ {print $4}'`
		echo "$2 $3 $DDI" > /tmp/cloudapi.info

### Here a notice of what was entered is shown and the username and API-KEY tmp file is created ----
			echo 'This will allow you to control the Cloud servers from the Command Line...'
			echo "HAL has saved the declarations to a TMP file located at /tmp/cloudapi.info"
			echo "The information that you have entered will be saved for $TTLFORINFO Minutes"
			echo ''
			echo "You have specified the USERNAME to be : $2"
			echo "You have specified the API KEY  to be : $3"
		if [ "$DDI" ];then 
			echo "The System returned a User DDI of     : $DDI"
		fi
			echo ''
			echo "now use the command [ $0 go ] to control your servers"
			echo "Use [ $0 help ] for a full list of commands"
			echo ''

### The time out script is created in TMP and then loaded as a background process ----
echo "#!/bin/bash
sleep $SLEEPTIME 
rm /tmp/cloudapi.info
rm /tmp/cloudapi.info.removal
exit 0" > /tmp/cloudapi.info.removal	
	chmod +x /tmp/cloudapi.info.removal
		/tmp/cloudapi.info.removal &
			exit 0
fi
;;

clean)
# This is a function that will remove an old setup and kill any and all processes that were started by this script --

### These are defined Variables, they are used to identify the processes that were running ----
KILLINFO=$( ps aux | grep cloudapi.info.removal | grep bash | awk '{print $2}' )
KILLSLEEP=$( ps aux | grep sleep | grep $SLEEPTIME | awk '{print $2}' )

### This removes the timed out removal script ----
clear
echo "Thank you for calling Initech, Please Hold..."
sleep 1
if [ -f /tmp/cloudapi.info.removal ];then
    rm /tmp/cloudapi.info.removal > /dev/null
    echo "I hate left overs... Especially left over files..."

### This removes the USERNAME and API-KEY tmp file script ----
    if [ -f /tmp/cloudapi.info ];then
      echo "Removing old and dirty info"
      rm /tmp/cloudapi.info
    fi

### This makes sure that the Process PIDs are killed ----
      if [ "$KILLINFO" ]; then
        echo "I found some things that need to be stopped before we can continue"
        echo "If there were more than one set of processes running you will have a nice list at the bottom"
        for KI in `ps aux | grep cloudapi.info.removal | grep bash | awk '{print $2}'`; do kill -9 $KI > /dev/null; done
                sleep 2
      fi
        if [ "$KILLSLEEP" ]; then
        echo 'killing sleepy processes'
        for KS in `ps aux | grep sleep | grep $SLEEPTIME | awk '{print $2}'`; do kill -9 $KS > /dev/null; done
                sleep 2
        fi
  echo "I really hope you enjoyed your Cleaning Experience, I know I did."
  echo "Should you need anything else please let me know..."
  echo ''  
exit 1

### If there was nothing to do then this will let you know ----
	else 
	echo "So there was nothing to clean, Yea I know I am than good..."
	echo ''
exit 1
fi
;;

help)
# The help function calls the HELP function of the python-novaclient script --

### This prints the help section of the script on your screen ----
clear
if [ -f /tmp/cloudapi.info ];then
	REMEMBERINFO
fi

/usr/local/bin/nova help;
;;
 
lus)
GODEFINED

### If you use the go function it expects other functions too ----
### This is a sanity check to make sure you have listed a function ----
   if [ ! -z $2 ];then
        lnova --url https://auth.api.rackspacecloud.com/v1.0 --username $API1 --apikey $API2 ${2} ${3} ${4} ${5} ${6} ${7} ${8} ${9} ${10};

### if no function was listed go will let you know and then show the help screen ----
                else
                        echo ''
			echo "AND THEN??? You did not give any arguments, try again..."
			echo ''
                        /usr/local/bin/lnova help
                        exit 0

   fi
;;

luk)
GODEFINED

### If you use the go function it expects other functions too ----
### This is a sanity check to make sure you have listed a function ----
   if [ ! -z $2 ];then
        lnova --url https://lon.auth.api.rackspacecloud.com/v1.0 --username $API1 --apikey $API2 ${2} ${3} ${4} ${5} ${6} ${7} ${8} ${9} ${10};

### if no function was listed go will let you know and then show the help screen ----
                else
                        echo ''
			echo "AND THEN??? You did not give any arguments, try again..."
			echo ''
                        /usr/local/bin/lnova help
                        exit 0

   fi
;;

ous)
GODEFINED

if [ -z "$API3" ];then
	API3="self"
fi

OS_USERNAME="${API1}"
OS_PASSWORD="${API2}"
OS_TENANT_NAME="${API3}"
NOVA_RAX_AUTH=1
OS_AUTH_URL=https://identity.api.rackspacecloud.com/v2.0/
NOVA_VERSION=2
NOVA_SERVICE_NAME=cloudServersOpenStack
export OS_USERNAME OS_REGION_NAME NOVA_RAX_AUTH OS_PASSWORD OS_AUTH_URL NOVA_VERSION NOVA_SERVICE_NAME OS_TENANT_NAME

if [ -z "$2" ];then
	echo "You need to specify a region, I can't proceed without the region."
	exit 1
		else 
			if [ "$2" == "dfw" ] || [ "$2" == "DFW" ];then
				OS_REGION_NAME="DFW"
					elif [ "$2" == "ord" ] || [ "$2" == "ORD" ];then
						OS_REGION_NAME="ORD"
						else 
							echo "The region was not specified or was invalid."
							echo "Please try Again."
							exit 1
			fi		

fi		

### If you use the go function it expects other functions too ----
### This is a sanity check to make sure you have listed a function ----
   if [ ! -z $3 ];then
        nova ${3} ${4} ${5} ${6} ${7} ${8} ${9} ${10};

### if no function was listed go will let you know and then show the help screen ----
                else
                        echo ''
			echo "AND THEN??? You did not give any arguments, try again..."
			echo ''
                        /usr/local/bin/nova help
                        exit 0

   fi
;;

ouk)
GODEFINED

OS_USERNAME="${API1}"
OS_PASSWORD="${API2}"
OS_TENANT_NAME="${API3}"
	OS_REGION_NAME="LON"
NOVA_RAX_AUTH=1
OS_AUTH_URL=https://lon.identity.api.rackspacecloud.com/v2.0/
NOVA_VERSION=2
NOVA_SERVICE_NAME=cloudServersOpenStack
OS_TENANT_NAME=self
export OS_USERNAME NOVA_RAX_AUTH OS_PASSWORD OS_AUTH_URL NOVA_VERSION NOVA_SERVICE_NAME OS_TENANT_NAME

### If you use the go function it expects other functions too ----
### This is a sanity check to make sure you have listed a function ----
   if [ ! -z $2 ];then
        nova ${2} ${3} ${4} ${5} ${6} ${7} ${8} ${9} ${10};

### if no function was listed go will let you know and then show the help screen ----
                else
                        echo ''
			echo "AND THEN??? You did not give any arguments, try again..."
			echo ''
                        /usr/local/bin/nova help
                        exit 0

   fi
;;

weather)
# This is a function to get the weather where you are based on a provided zip code--
clear
### Remove the temp file if there was one left behind ----
if [ -f /tmp/weather.info ];then 
	echo "I am not sure how this happened, but I found a TMP file that should not be there..."
	echo "Don't worry I made sure it was dealt with..."
	rm /tmp/weather.info
	sleep 2
fi
#### These are sanity checks to make sure that the zip code entered is > 4 characters and less than 6 characters ----
if [ -z $2 ];then 
	echo ''
	echo "You did not give a Zip Code, How I am going to tell you the weather without a Zip Code???"
	echo "This time use it like this, [ $0 weather 78218 ] and then I will tell you how is the Weather ..."
		exit 1
			elif [ ! $(echo ${2} | wc -c) -gt 4 ];then 
				echo ''
				echo "Zip Codes are at least 4 digits long, You should try again..."
					exit 1
			elif [ ! $(echo ${2} | wc -c) -lt 7 ];then 
				echo ''
				echo "Please Only use a 5 digit Zip Code, that is all I can handle right now..."
					exit 1
### This is the weather function that is used to get the weather from Google.com ----
else
   curl -s "http://www.google.com/ig/api?weather=$2" > /tmp/weather.info
	CITY=$( sed 's|.*<city data="\([^"]*\)"/>.*|\1|' /tmp/weather.info )
	ZIPCODE=$( sed 's|.*<postal_code data="\([^"]*\)"/>.*|\1|' /tmp/weather.info )
	CURRENTTEMP=$( sed 's|.*<temp_f data="\([^"]*\)"/>.*|\1|' /tmp/weather.info )
	CURRENTHUMI=$( sed 's|.*<humidity data="\([^"]*\)"/>.*|\1|' /tmp/weather.info )
	CURRENTWIND=$( sed 's|.*<wind_condition data="\([^"]*\)"/>.*|\1|' /tmp/weather.info )
		echo ''
		echo "WOW! This script really does everything, including giving you the Weather in $CITY..."
		echo ''
			echo "City            : $CITY"
			echo "Zipcode         : $ZIPCODE"
			echo "Temperature     : $CURRENTTEMP"
			echo "Humidity        : $CURRENTHUMI"
			echo "Wind Conditions : $CURRENTWIND"
### This removes the weather info TMP file ----				
rm /tmp/weather.info
				if [ ${2} == 78218 ];then 
					echo ''
					echo "Did you know Rackspace is there?  It is a Very Cool Place!"
					echo "There is no Place like Rackspace!"
						if [[ ${2} == 78218 && `which python` ]];then 
						python -mwebbrowser http://www.rackspace.com/information/aboutus/
							else 
								echo "Check out Rackspace at http://www.rackspace.com"
				
					echo ''
    fi
  fi
fi

;;

*)
echo ''
# This shows all of the usage --
echo "Usage: $0 <EXPRESSION>"
echo '
Base Functions :
      where     -- Tells you where the script is located
      weather  -- Tells you the weather for a specified Zip Code
      install   -- Installs the script into the $PATH
	  
Usage Functions :
      new       -- Used to specify a Username and API Key

      lus       -- Used to access Legacy US Cloud Servers
      luk       -- Used to access Legacy UK Cloud Servers

      ous       -- Used to access Open Cloud US Cloud Servers,
                  \_ You have to specify a Region 
                     \_Available Regions are : ord & dfw
					
      ouk       -- Used to access Open Cloud UK Cloud Servers

      clean     -- Removes all temp files for user interactions, 
                   This is also done automatically every 30 minutes

Repair and Upgrade Functions :
      repair    -- Identifies and Repairs python modules that are know to be incompatible
      upgrade   -- Upgrades the kenova script
'
echo ''
exit 1
;;

esac
