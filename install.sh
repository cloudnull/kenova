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

#set -u
#set -e

# Temp Directory, This is Done like this because of OSX
TMPDIR=$(mktemp -d XXXXXXXXXXX)

# Installer Variables for NOVA
NOVAVERSIONGIT="git://github.com/openstack/python-novaclient.git"
RAXNOVAVERSIONGIT="https://github.com/rackerlabs/rackspace-novaclient"
LNOVAVERSIONGIT="https://github.com/cloudnull/python-lnovaclient.git"
SUPERNOVAGIT="https://github.com/major/supernova.git"
KEYRINGNAME="keyring"

# File Log
NOVALOG="$TMPDIR/Nova.Installation.log"
echo $NOVALOG
# Test for setuptools
if ! python -c 'import setuptools' &>/dev/null; then
    echo "Setup Tools was not found on your system" 1>&2
    exit 1
fi

# Test for requirements
for req in python git pip; do
    if ! which ${req};then
        echo "This program requires ${dep}, but ${dep} not found in PATH" 1>&2
        exit 1
    fi
done

# Commands
EZINST="$(which pip) install"

# Information before Installation
echo -e "
You should know that if you install the nova environment using this script there
will be several actions done.

1 - The installer will clean up known bad python modules that conflict with the
    nova and lnova scripts.
2 - If you have any parts of nova or lnova preinstalled, it will be removed.
3 - Using Git, it will install all of the needed scripts for nova and lnova to
    work specifically with the Rackspace Openstack and Legacy Environments.
"
read -p "Type [ YES ] To continue. Otherwise press the sciprt will quit. : " CONFIRM
if [[ ! "${CONFIRM}" == [yY][eE][sS] ]];then
    echo "Exiting."
    exit 1
fi

# Root user check for install
if [ "$(id -u)" != "0" ]; then
   echo -e "This script must be run as ROOT. You have attempted to run this as $( whoami ) use sudo $@ or change to root."
   exit 1
fi

if [[ -f "$NOVALOG" ]]; then
    mv "$NOVALOG" "$NOVALOG.old.$(date +%y%m%d%H%M).log"
fi

for module in prettytable keyring novaclient rackspace_auth_openstack supernova; do
    for locs in $(python -c "import site; print ' '.join(site.getsitepackages())"); do
        find "${locs}" -type d -name "*${module}*" -exec rm -rfv {} \; >> $NOVALOG
    done
done

echo -e "\nI am Installing the nova clients."
${EZINST} git+${NOVAVERSIONGIT} >> ${NOVALOG}
${EZINST} git+${LNOVAVERSIONGIT} >> ${NOVALOG}
${EZINST} git+${SUPERNOVAGIT} >> ${NOVALOG}
${EZINST} ${KEYRINGNAME} >> ${NOVALOG}
${EZINST} git+${RAXNOVAVERSIONGIT} >> ${NOVALOG}

echo -e "
The Log for the installation has been written to : $NOVALOG, all temp files are
also in $TMPDIR. Now add the source to your environment RC file with command

setrc.sh
"

exit 0

