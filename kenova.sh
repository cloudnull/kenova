#!/bin/bash
# - title        : kenova
# - description  : This script will assist in the use of the Cloud Servers Python Script..
# - author       : Kevin Carter
# - date         : 2012-06-05
# - version      : 1.4    
# - License      : GPLv3
# - usage        : bash kenova
# - notes        : Requires Python, NovaClient; 
# - notes        : While not needed for operation, Git is needed for installation.
# - notes        : the python-novaclient can be gotten here = https://github.com/openstack/python-novaclient
# - bash_version : >= 3.2.48(1)-release
#### ========================================= ####
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

case "$1" in

repair)
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

CHECKFORROOT
REPAIRFOOBAREDMODULES
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
if [ ! `which lnova` ];then
clear 
echo -e '\nThis is a Python Wrapper for Legacy Nova Instances.\nYou will need to install Legacy Novaclient in order to proceed.\n'
exit 1
fi
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
if [ ! `which lnova` ];then
clear 
echo -e '\nThis is a Python Wrapper for Legacy Nova Instances.\nYou will need to install Legacy Novaclient in order to proceed.\n'
exit 1
fi
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
if [ ! `which nova` ];then
clear 
echo -e '\nThis is a Python Wrapper for Openstack Nova Instances.\nYou will need to install Openstack-Novaclient in order to proceed.\n'
exit 1
fi
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
if [ ! `which nova` ];then
clear 
echo -e '\nThis is a Python Wrapper for Openstack Nova Instances.\nYou will need to install Openstack-Novaclient in order to proceed.\n'
exit 1
fi
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

*)
echo ''
# This shows all of the usage --
echo "Usage: $0 <EXPRESSION>"
echo '
Base Functions :
      where     -- Tells you where the script is located
	  
Usage Functions :
      new       -- Used to specify a Username and API Key
      lus       -- Used to access Legacy US Cloud Servers
      luk       -- Used to access Legacy UK Cloud Servers
      ous       -- Used to access Open Cloud US Cloud Servers,
                   |_ You have to specify a Region 
                   |_ Available Regions are : ord & dfw
					
      ouk       -- Used to access Open Cloud UK Cloud Servers
      clean     -- Removes all temp files for user interactions, 
                   This is also done automatically every 30 minutes

Repair Functions :
      repair    -- This attempts to repair the functions if they were broken
'
echo ''
exit 1
;;

esac
