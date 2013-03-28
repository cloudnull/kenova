#!/bin/bash
# - title        : kenova
# - description  : Installer script for kenova.sh
# - author       : Kevin Carter
# - date         : 2012-10-25
# - version      : 1.6
# - License      : GPLv3
# - usage        : bash install.sh
# - notes        : Requires Python, NovaClient;
# - notes        : Git is needed for installation.
# - bash_version : >= 3.2.48(1)-release
#### ========================================= ####

# User Defined Information

# Temp Directory
TEMPDIR="/tmp"
WHEREAMI=$(pwd)

# Installer Variables for NOVA
NOVAVERSIONGIT="git://github.com/openstack/python-novaclient.git"
RAXNOVAVERSIONGIT="https://github.com/rackspace/rackspace-novaclient.git"
LNOVAVERSIONGIT="https://github.com/cloudnull/python-lnovaclient.git"
SUPERNOVAGIT="https://github.com/rackerhacker/supernova.git"

# Temp Install Directories
LEGACYNOVACLIENTDIR="$TEMPDIR/python-lnovaclient"
OPENSTACKNOVACLIENTDIR="$TEMPDIR/python-novaclient"
RAXNOVACLIENT="rackspace-novaclient"
RAXNOVACLIENTDIR="$TEMPDIR/$RAXNOVACLIENT"
SUPERNOVADIR="$TEMPDIR/supernova"
KEYRINGNAME="keyring"

# File Log
NOVALOG="$TEMPDIR/Nova.Installation.log"
BADMODSDIR="badPythonDir.log"
BADMODSLIST="badPythonPurgeList.log"
BADMODSREMOVED="BadModules.log"

# Commands
EZINST="easy_install"

# Information before Installation
echo -e "\nYou should know that if you install the nova environment using this script there will be several actions done.\n1 - The installer will clean up known bad python modules that conflict with the nova and lnova scripts.\n2 - If you have any parts of nova or lnova preinstalled, it will be removed.\n3 - Using Git, it will install all of the needed scripts for nova and lnova to work specifically with the Rackspace Openstack and Legacy Environments.\n"

read -p "Please press [ Enter ] To continue. Otherwise press [ CTRL-c ] to quit."

# Root user check for install
USERCHECK=$( whoami  )
if [ "$(id -u)" != "0" ]; then
   echo -e "This script must be run as ROOT\nYou have attempted to run this as $USERCHECK\nuse sudo $0 $1 or change to root."
   exit 1
fi

if [ ! $(which python) ];then
    clear
    echo -e "\nThis is a Python Wrapper for a Python application, which requires that you have Python installed.\nYou will need to install Python in order to proceed."
    exit 1
fi

if [ ! $(which git) ];then
    clear
    echo -e "\nGit was not found on this Instance. You should install GIT to ensure compatibility,\nhowever, I can use fall back mode to retrieve the files but it is not guaranteed to work.\nWhile Fall Back mode may work, I would recommend that you install a GIT client on this system before continuing.\n"
    echo -e "\nPlease go to \"http://git-scm.com/downloads\" and install git on your system.\n"
    exit 1
fi

# Move Log to Old if it exists
if [ -f "$NOVALOG" ];then
    mv $NOVALOG $NOVALOG.old.$(date +%y%m%d%H%M).log
fi

echo -e "\nChecking for Incompatible Versions of Python Packages.\n"
# remove old directory text files if they exist
if [ -f $TEMPDIR/$BADMODSDIR ];then
    rm $TEMPDIR/$BADMODSDIR
fi


echo -e "\nLooking in Known Standard Locations for Python Modules.\n"
# Build a list of directories if they exist
if [ -d /Library/ ];then
    echo '/Library/' >> $TEMPDIR/$BADMODSDIR
fi

if [ -d /opt/ ];then
    echo '/opt/' >> $TEMPDIR/$BADMODSDIR
fi

if [ -d /usr/ ];then
    echo '/usr/' >> $TEMPDIR/$BADMODSDIR
fi


# Build a list of bad Python Modules
if [ -f $TEMPDIR/$BADMODSLIST ];then
    rm $TEMPDIR/$BADMODSLIST
fi

echo -e "\nBuilding a list of known bad Python Modules for RAX Nova.\n"
    for P1L in {6..10}; do echo "httplib2-0.7.$P1L*" >> $TEMPDIR/$BADMODSLIST; done
    for P2L in {6..10}; do echo "prettytable-0.$P2L*" >> $TEMPDIR/$BADMODSLIST; done

echo -e "Looking for and Removing Bad Modules."
for BadD in $(cat $TEMPDIR/$BADMODSDIR); do
    for BadM in $(cat $TEMPDIR/$BADMODSLIST); do
        find $BadD -name $BadM -exec rm -rf {} \;
        find $BadD -name 'keyring*' -exec rm -rf {} \;
        find $BadD -name '*python_novaclient*' -exec rm -rf {} \;
        find $BadD -name '*python_lnovaclient*' -exec rm -rf {} \;
        find $BadD -name '*rackspace_auth_openstack*' -exec rm -rf {} \;
        find $BadD -name '*rackspace_novaclient*' -exec rm -rf {} \;
        find $BadD -name '*supernova*' -exec rm -rf {} \;
    done;
done; >> $TEMPDIR/$BADMODSREMOVED

if [ -z $TEMPDIR/$BADMODSREMOVED ];then
    echo "Record of Purge can be found here : $TEMPDIR/$BADMODSREMOVED"
fi

echo 'Cleanup Done'

# Install Setup Tools if needed
PYTHONVERSIONNUMBER=$(python -c 'import sys; print sys.version[:3]')
SETUPTOOLSVERSION=$(curl -s http://pypi.python.org/pypi/setuptools | grep "http://pypi.python.org/packages/$PYTHONVERSIONNUMBER/" | sed -e 's/<a\ href\=//g' -e 's/\"//g' -e 's/#.*//g' -e 's/^[ ]*//g' | grep -v .exe)
SETUPTOOLSNAME=$(echo $SETUPTOOLSVERSION | awk -F '/' '{print $8}')

echo "Checking for Python Setup Tools"
CHECKSETUPTOOLS=$(python -c "
try:
    import setuptools
except ImportError, e:
    print 'FAIL'
")

if [ "$CHECKSETUPTOOLS" == "FAIL" ];then
    echo -e "\nSetup Tools was not found on your System, I am attempting to install the Python Module.\n"
    if [ -z "$SETUPTOOLSVERSION" ];then
        echo -e "Sorry though your version of Python has no Version of SetupTools Available.\nPlease Goto http://pypi.python.org/pypi/setuptools to see if\nthere is a version available."
        exit 1
    fi
    echo -e "\nI am getting the installation files for python-setuptools."
    cd $TEMPDIR/
    curl -O $SETUPTOOLSVERSION
    bash $TEMPDIR/$SETUPTOOLSNAME >> $NOVALOG
fi


# Removing old openstack nova directory
cd $TEMPDIR
if [ -d $OPENSTACKNOVACLIENTDIR ];then
    rm -rf $OPENSTACKNOVACLIENTDIR
fi

echo -e "\nI am installating python-novaclient."
cd $TEMPDIR
git clone $NOVAVERSIONGIT

if [ -f $OPENSTACKNOVACLIENTDIR/tools/pip-requires ];then
    echo -e "\nFixing pip so that it only installs the known working prettytable module.\npip-requires File Found.\n"
    if [ $(grep -i prettytable $OPENSTACKNOVACLIENTDIR/tools/pip-requires) ];then
        sed /^prettytable/d $OPENSTACKNOVACLIENTDIR/tools/pip-requires > $TEMPDIR/pip-requires.mod
        rm $OPENSTACKNOVACLIENTDIR/tools/pip-requires
        mv $TEMPDIR/pip-requires.mod $OPENSTACKNOVACLIENTDIR/tools/pip-requires
        echo 'prettytable==0.5' >> $OPENSTACKNOVACLIENTDIR/tools/pip-requires
    fi
fi

if grep prettytable $OPENSTACKNOVACLIENTDIR/setup.py;then
    sed 's/prettytable/prettytable==0\.5/g' $OPENSTACKNOVACLIENTDIR/setup.py > $TEMPDIR/setup.py
    rm $OPENSTACKNOVACLIENTDIR/setup.py
    mv $TEMPDIR/setup.py $OPENSTACKNOVACLIENTDIR/setup.py
fi

# Installing Openstack Nova Client
cd $OPENSTACKNOVACLIENTDIR
python setup.py install >> $NOVALOG

cd $TEMPDIR
if [ -d $OPENSTACKNOVACLIENTDIR ];then
    rm -rf $OPENSTACKNOVACLIENTDIR
fi

# Removing old rackspace nova directory
cd $TEMPDIR
if [ -d $RAXNOVACLIENTDIR ];then
    rm -rf $RAXNOVACLIENTDIR
fi

# Removing old Legacy nova directory
cd $TEMPDIR
if [ -d $LEGACYNOVACLIENTDIR ];then
    rm -rf $LEGACYNOVACLIENTDIR
fi

# Installing the Legacy Nova
echo -e "\nI am Installing the python-lnovaclient."
cd $TEMPDIR
git clone $LNOVAVERSIONGIT

cd $LEGACYNOVACLIENTDIR
python setup.py install >> $NOVALOG

cd $TEMPDIR
if [ -d $LEGACYNOVACLIENTDIR ];then
    rm -rf $LEGACYNOVACLIENTDIR
fi

# Installing keyring
echo -e "\nI am Installing KeyRing."
cd $TEMPDIR
$EZINST $KEYRINGNAME >> $NOVALOG

# Removing old Supernova directory
cd $TEMPDIR
if [ -d $SUPERNOVADIR ];then
    rm -rf $SUPERNOVADIR
fi

# Installing Supernova
echo -e "\nI am Installing Supernova."
cd $TEMPDIR
git clone $SUPERNOVAGIT

cd $SUPERNOVADIR
python setup.py install >> $NOVALOG

cd $TEMPDIR
if [ -d $SUPERNOVADIR ];then
    rm -rf $SUPERNOVADIR
fi

# Install the Rackspace NovaClient from PIP
$EZINST $RAXNOVACLIENT >> $NOVALOG

# Installer for the kenova command and control script
echo -e "\nInstalling the kenova script\n"
cp -v $WHEREAMI/kenova.sh /usr/bin/kenova >> $NOVALOG
chmod +x /usr/bin/kenova
echo -e "\nThe Log for the installation has been written to :\n$NOVALOG\n"

exit 0
