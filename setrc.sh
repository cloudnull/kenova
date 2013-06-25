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

function setrc(){
    if [[ ! $(grep "kenova" $RCFILE) ]];then
        cat << EOF >> $RCFILE

if [ -f $HOME/.kenova ];then
    source ~/.kenova
fi

EOF
    else
        echo -e "Looks like kenova is already in your RC file, so I did not re-add it"
    fi
}

# Installer for the kenova command and control script
echo -e "\nInstalling the kenova script\n"
cp -v kenova $HOME/.kenova

if [ -f "$HOME/.bashrc" ];then
    RCFILE="$HOME/.bashrc"
    setrc
elif [ -f "$HOME/.profile" ];then
    RCFILE="$HOME/.profile"
    setrc
elif [ -f "$HOME/.bash_profile" ];then
    RCFILE="$HOME/.bash_profile"
    setrc
else
    echo 'I could not file the RC file for setting Kenova, thus you have to do it yourself for what ever file you are using.'
fi
