#!/usr/bin/env bash
# ==============================================================================
# Copyright [2013] [Kevin Carter]
# License Information :
# This software has no warranty, it is provided 'as is'. It is your
# responsibility to validate the behavior of the routines and its accuracy using
# the code provided. Consult the GNU General Public license for further details
# (see GNU General Public License).
# http://www.gnu.org/licenses/gpl.html
# ==============================================================================

# Note that after running this script you will need to set source the kenova
# file in your bash rc this can be done for you, if you run setrc.sh.
# ==============================================================================

set -u
set -e

FORCE=${1:-no}

# Temp Log File, This is Done like this because of OSX
NOVALOG="$(mktemp tmp.XXXXXXXXXXX).Kenova.Installation.log"

# Installer Variables for NOVA
NOVAVERSIONGIT="git://github.com/openstack/python-novaclient.git"
RAXNOVAVERSIONGIT="https://github.com/rackerlabs/rackspace-novaclient"
LNOVAVERSIONGIT="https://github.com/cloudnull/python-lnovaclient.git"
SUPERNOVAGIT="https://github.com/major/supernova.git"
KEYRINGNAME="keyring"

# Test for setuptools
if ! python -c 'import setuptools' &>/dev/null; then
    echo "Setup Tools was not found on your system" 1>&2
    exit 1
fi

# Test for requirements
for dep in python git pip; do
    if [[ ! $(which ${dep}) ]];then
        echo "This program requires ${dep}, but ${dep} not found in PATH" 1>&2
        exit 1
    fi
done

# Root user check for install
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as ROOT. You have attempted to run this as $USER use sudo $@ or change to root." 1>&2
   exit 1
fi

# Commands
EZINST="$(which pip) install --upgrade"

# Information before Installation
if [[ ! "$FORCE" == "-f" ]];then
    echo "
You should know that if you install the nova environment using this script global actions will be performed.

1 - Using Git, it will install all of the needed parts of nova and lnova to
    work specifically with the Rackspace Openstack and Legacy Environments.

"
    read -p "Type [ YES ] To continue. Otherwise press the script will quit. : " CONFIRM
    if [[ ! "${CONFIRM}" == [yY][eE][sS] ]];then
        echo "Exiting." 1>&2
        exit 1
    fi
fi

if [[ -f "$NOVALOG" ]]; then
    mv "$NOVALOG" "$NOVALOG.old.$(date +%y%m%d%H%M).log"
fi

echo "[+] I am Installing the nova clients." >> ${NOVALOG}
${EZINST} git+${NOVAVERSIONGIT} >> ${NOVALOG}
${EZINST} git+${LNOVAVERSIONGIT} >> ${NOVALOG}
${EZINST} git+${RAXNOVAVERSIONGIT} >> ${NOVALOG}

echo "[+] Installing the supernova and keyring for shits and giggles..." >> ${NOVALOG}
${EZINST} ${KEYRINGNAME} >> ${NOVALOG}
${EZINST} git+${SUPERNOVAGIT} >> ${NOVALOG}

echo "[+] The Log for the installation has been written to \"$NOVALOG\"."

exit 0
