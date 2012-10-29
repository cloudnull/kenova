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

# User Defined Variables
IAMWHO=$(whoami)
TEMP="/tmp"
INFO="$TEMP/$IAMWHO.cloudapi.info"

# API Version 1.0 End Point
V1USIDENTITY="https://identity.api.rackspacecloud.com/v1.0/"
V1UKIDENTITY="https://lon.identity.api.rackspacecloud.com/v1.0/"

# API Version 2.0 End Point
V2USIDENTITY="https://identity.api.rackspacecloud.com/v2.0/"
V2UKIDENTITY="https://lon.identity.api.rackspacecloud.com/v2.0/"


# Checking to see that nova and lnova are installed
NOVA=$(which nova)
if [ -z "$NOVA" ];then
clear
    echo -e '\nThis is a Python Wrapper for Openstack Nova Instances.\nYou will need to install Openstack-Novaclient in order to proceed.\n'
    exit 1
fi

LNOVA=$(which lnova)
if [ -z "$LNOVA" ];then
    echo -e '\nThis is a Python Wrapper for Legacy Nova Instances.\nYou will need to install Legacy Novaclient in order to proceed.\n'
    exit 1
fi

REMEMBERINFO(){
  API1=$(awk '{print $1}' $INFO)
  API2=$(awk '{print $2}' $INFO)
  API3=$(awk '{print $3}' $INFO)

### This prints the USERNAME and the API-KEY that you specified earlier ----
    echo ''
    echo "Remember You have set the USERNAME : $API1"
    echo "Remember You have set the API-Key  : $API2"
if [ "$API3" ];then
	echo "The System returned a User DDI of  : $API3"
fi
}

GODEFINED(){
# Go is used to start the script one a Username and API-KEY have been set --
### This is a sanity check to make sure that you have set an account ----
if [ -f $INFO ];then

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

CHECKFOROLDPROCESS(){
# This Function allows for a New USER and API key to be entered --
# Before Entering the New User Information the script cleans up any remnants that may have been running ---

# These are defined Variables, they are used to identify the processes that were running ----
KILLINFO=$( ps aux | grep $IAMWHO.cloudapi.info.removal | grep bash | awk '{print $2}' )
KILLSLEEP=$( ps aux | grep sleep | grep $SLEEPTIME | awk '{print $2}' )

### This removes the timed out removal script ----
if [ -f $INFO.removal ];then
    rm $INFO.removal > /dev/null
    echo "I hate left overs..."
fi

### This makes sure that the Process PIDs are killed ----
if [ "$KILLINFO" ]; then
    echo -e "\nI found some things that need to be stopped before we can continue\nIf there were more than one set of processes running you will have a nice list at the bottom"
    for KI in $KILLINFO; do kill -9 $KI > /dev/null; done
fi
if [ "$KILLSLEEP" ]; then
    echo -e "killing sleepy processes\n"
    for KS in $KILLSLEEP; do kill -9 $KS > /dev/null; done
fi
sleep 2
}

case "$1" in

new)
CHECKFOROLDPROCESS

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
echo "$2 $3" > $INFO
	DDI=`kenova ous credentials | awk -F "'" '/tenant/ {print $4}'`
		echo "$2 $3 $DDI" > $INFO
            chmod 600 $INFO
clear
### Here a notice of what was entered is shown and the username and API-KEY tmp file is created ----
			echo -e "\nThis will allow you to control the Cloud servers from the Command Line..."
			echo "HAL has saved the declarations to a TMP file located at $INFO"
			echo -e "The information that you have entered will be saved for $TTLFORINFO Minutes\n"
			echo "You have specified the USERNAME to be : $2"
			echo "You have specified the API KEY  to be : $3"
		if [ "$DDI" ];then 
			echo "The System returned a User DDI of     : $DDI"
		fi
			echo "now use the command [ $0 go ] to control your servers"
			echo -e "Use [ $0 help ] for a full list of commands\n"

### The time out script is created in TMP and then loaded as a background process ----
echo -e "#!/bin/bash\nsleep $SLEEPTIME\nrm $INFO\nrm $INFO.removal\nexit 0" > $INFO.removal
	chmod +x $INFO.removal
		$INFO.removal &
			exit 0
fi
;;

clean)
CHECKFOROLDPROCESS
    exit 1
;;

help)
# The help function calls the HELP function of the python-novaclient script --
### This prints the help section of the script on your screen ----
clear
if [ -f $INFO ];then
	REMEMBERINFO
fi

$NOVA help;
;;
 
lus)

GODEFINED

### This is a sanity check to make sure you have listed a function ----
   if [ ! -z $2 ];then
        LNOVA --url $V1USIDENTITY --username $API1 --apikey $API2 $2 $3 $4 $5 $6 $7 $8 $9;

### if no function was listed go will let you know and then show the help screen ----
                else
                        echo ''
			echo "AND THEN??? You did not give any arguments, try again..."
			echo ''
                        $LNOVA help
                        exit 0

   fi
;;

luk)

GODEFINED

### This is a sanity check to make sure you have listed a function ----
   if [ ! -z $2 ];then
        LNOVA --url $V1USIDENTITY --username $API1 --apikey $API2 $2 $3 $4 $5 $6 $7 $8 $9;

### if no function was listed go will let you know and then show the help screen ----
                else
                        echo ''
			echo "AND THEN??? You did not give any arguments, try again..."
			echo ''
                        $LNOVA help
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
OS_AUTH_URL="$V2USIDENTITY"
NOVA_VERSION=2
NOVA_SERVICE_NAME=cloudServersOpenStack

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

export OS_USERNAME OS_REGION_NAME NOVA_RAX_AUTH OS_PASSWORD OS_AUTH_URL NOVA_VERSION NOVA_SERVICE_NAME OS_TENANT_NAME

### This is a sanity check to make sure you have listed a function ----
   if [ ! -z $3 ];then
        NOVA $3 $4 $5 $6 $7 $8 $9;

### if no function was listed go will let you know and then show the help screen ----
                else
                        echo ''
			echo "AND THEN??? You did not give any arguments, try again..."
			echo ''
                        $NOVA help
                        exit 0

   fi
;;

ouk)

GODEFINED

OS_USERNAME="${API1}"
OS_PASSWORD="${API2}"
OS_TENANT_NAME="${API3}"
NOVA_RAX_AUTH=1
OS_AUTH_URL="$V2UKIDENTITY"
NOVA_VERSION=2
NOVA_SERVICE_NAME=cloudServersOpenStack

    OS_REGION_NAME="LON"

export OS_USERNAME OS_REGION_NAME NOVA_RAX_AUTH OS_PASSWORD OS_AUTH_URL NOVA_VERSION NOVA_SERVICE_NAME OS_TENANT_NAME

### If you use the go function it expects other functions too ----
### This is a sanity check to make sure you have listed a function ----
   if [ ! -z $2 ];then
        NOVA $3 $4 $5 $6 $7 $8 $9;

### if no function was listed go will let you know and then show the help screen ----
                else
                        echo ''
			echo "AND THEN??? You did not give any arguments, try again..."
			echo ''
                        $NOVA help
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
