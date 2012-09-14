#!/bin/bash
# - title        : kenova
# - description  : Installer script for kenova.sh
# - author       : Kevin Carter
# - date         : 2012-06-05
# - version      : 1.4    
# - License      : GPLv3
# - usage        : bash install.sh
# - notes        : Requires Python, NovaClient; 
# - notes        : Git is needed for installation.
# - bash_version : >= 3.2.48(1)-release
#### ========================================= ####

## User Defined ##

# Installer for the python-novaclient script
LNOVAVERSIONGIT="https://github.com/cloudnull/python-lnovaclient.git"

# Installer for the python-novaclient script
NOVAVERSIONGIT="git://github.com/openstack/python-novaclient.git"

# Temp Directory 
TEMPDIR="/tmp/"
LEGACYNOVACLIENTDIR="/tmp/python-lnovaclient"
OPENSTACKNOVACLIENTDIR="/tmp/python-novaclient"

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

# Installer for the kenova command and control script
INSTALLKENOVA(){
	echo -e "\nInstalling the kenova script\n"
	cp kenova.sh /usr/bin/kenova
	chmod +x /usr/bin/kenova
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
for P2L in {6..9}; do echo "prettytable-0.${P2L}*" >> /tmp/badPythonPurgeList.txt;done

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

if [ ! `which python` ];then
clear 
echo 'This is a Python Wrapper, which requires that you have Python installed.'
echo 'You will need to install Python in order to proceed.'
exit 1
fi

CHECKFORROOT
if [ ! `which git` ];then
	echo ''
	echo -e "\nGit was not found on this Instance. You should install GIT to ensure compatibility,\nhowever, I can use fall back mode to retrieve the files but it is not guaranteed to work.\nWhile Fall Back mode may work, I would recommend that you install a GIT client on this system before continuing.\n"
		exit 1
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
if [ -d $OPENSTACKNOVACLIENTDIR ];then 
	rm -rf $OPENSTACKNOVACLIENTDIR
fi

	echo ''
	echo "2 - I am getting the installation files for python-novaclient."
	cd /tmp/
	echo "Installing Open Cloud $NOVANAME"
	if [ `which git` ];then
		if [ -d $OPENSTACKNOVACLIENTDIR ];then 
			rm -rf $OPENSTACKNOVACLIENTDIR
		fi
			git clone ${NOVAVERSIONGIT}
			else
				echo "We are failing because we found no way to proceed."
				exit 1
	fi
	
if [ -f $OPENSTACKNOVACLIENTDIR/tools/pip-requires ];then
	echo -e "\nFixing pip so that it only installs the known working prettytable module.\npip-requires File Found.\n"
	if [ `grep -i prettytable $OPENSTACKNOVACLIENTDIR/tools/pip-requires` ];then
		sed /^prettytable/d $OPENSTACKNOVACLIENTDIR/tools/pip-requires > /tmp/pip-requires.mod
			rm $OPENSTACKNOVACLIENTDIR/tools/pip-requires
				mv /tmp/pip-requires.mod $OPENSTACKNOVACLIENTDIR/tools/pip-requires
					echo 'prettytable==0.5' >> $OPENSTACKNOVACLIENTDIR/tools/pip-requires
	fi
fi

if grep prettytable $OPENSTACKNOVACLIENTDIR/setup.py;then
		sed 's/prettytable/prettytable==0\.5/g' $OPENSTACKNOVACLIENTDIR/setup.py > /tmp/setup.py
			rm $OPENSTACKNOVACLIENTDIR/setup.py
				mv /tmp/setup.py $OPENSTACKNOVACLIENTDIR/setup.py
fi

cd $OPENSTACKNOVACLIENTDIR
	python setup.py install > ~/NovaClient.Installation.log

#if [ -d $OPENSTACKNOVACLIENTDIR ];then 
#	rm -rf $OPENSTACKNOVACLIENTDIR
#fi


}

INSTALLLNOVACLIENT(){
if [ -d $LEGACYNOVACLIENTDIR ];then 
	rm -rf $LEGACYNOVACLIENTDIR
fi

cd $TEMPDIR
echo -e "\n3 - I am getting the installation files for python-novaclient.\n"
	echo "Installing Legacy $LNOVANAME"
	if [ `which git` ];then
		if [ -d $LEGACYNOVACLIENTDIR ];then 
			rm -rf $LEGACYNOVACLIENTDIR
		fi	
			git clone ${LNOVAVERSIONGIT}
			else
				echo "We are failing because we found no way to proceed."
				exit 1
	fi

	cd $LEGACYNOVACLIENTDIR

if [ -f $LEGACYNOVACLIENTDIR/tools/pip-requires ];then
	echo -e "\nFixing pip so that it only installs the known working prettytable module.\npip-requires File Found.\n"
	if [ `grep -i prettytable $LEGACYNOVACLIENTDIR/tools/pip-requires` ];then
		sed 's/prettytable==0\.6/prettytable==0\.5/g' $LEGACYNOVACLIENTDIR/tools/pip-requires > /tmp/pip-requires.mod
			rm $LEGACYNOVACLIENTDIR/tools/pip-requires
				mv /tmp/pip-requires.mod $LEGACYNOVACLIENTDIR/tools/pip-requires
	fi
fi

FINDPRETTYTABLE=$(grep prettytable /tmp/python-novaclient/setup.py)
if [ "$FINDPRETTYTABLE" ];then
	sed 's/prettytable/prettytable==0\.5/g' $LEGACYNOVACLIENTDIR/setup.py > $LEGACYNOVACLIENTDIR/setup.py.old
		rm $LEGACYNOVACLIENTDIR/setup.py
			mv $LEGACYNOVACLIENTDIR/setup.py.old $LEGACYNOVACLIENTDIR/setup.py
fi

	python $LEGACYNOVACLIENTDIR/setup.py install
		LEGACYNOVA=`which nova`
			mv $LEGACYNOVA $(echo $LEGACYNOVA | sed 's/nova/lnova/')


if [ -d $LEGACYNOVACLIENTDIR ];then 
	rm -rf $LEGACYNOVACLIENTDIR
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
# INSTALLLNOVACLIENT
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

exit 1
