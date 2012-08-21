The python Nova Client is a powerful python based tool that can assist in A LOT of Openstack / Rackspace Cloud Functions.  When you interface with python-nova-client you are using some fantastic libraries that extend the functionality of the Cloud.  

Please have a look here to review the work done by many other very bright people. Please review the `Python Nova Client On GIT hub`_\.

kenova
^^^^^^

What the kenova.sh script does is create a wrapper script for the python nova client, which simplifies the users interactions with the python-novaclient.  The script is FULL Featured and works with the Rackspace Cloud in all Active environments.  This includes :

* US Cloud Servers
* US Open Cloud Servers
* UK Cloud Servers

In order to install the ``kenova`` application you **MUST** have two dependencies installed on your system.
You need to have both ``Python`` and ``Git`` installed.  These two applications are found in ALL Repositories, or you can get them from source here :

* `Git Client Download and Information`_
* `Python from python.org`_

The ``kenova`` wrapper has been tested to work on most Linux and Unix systems that have Python 2.5+ install and are compatibile with the Python NovaClient modules..

``Here are the Basic Functions of the application :``

.. code-block:: bash 

  Usage: /usr/bin/kenova <EXPRESSION>

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


Once you have authenticated with the user name and the API-Key for the account that you want to interact with, simply enter the country that you are authenticated against and the function that you would like to perform.

Once you have the script you will need to install it
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Install the wrapper, which will download the latest NOVA-Client.

.. code-block:: bash

    sudo bash kenova.sh install

Once installed it is part of the ``$PATH`` you can verify that with the `which` command

.. code-block:: bash

    which kenova

After you have installed the script you can simply execute the ``kenova`` command from the CLI and begin managing / monitoring your cloud servers more efficiently. 

Installation has been tested on :
  * Mac OS X 10.5 +
  * Ubuntu 10.04 + 
  * CentOS 5 + 
  * Debian 6  
  * Mageia 2

While these were the only "Tested" systems, installation should work on ALL Linux Unix Systems, provided you have the python NovaClient.  

Drop me a line if you have any questions.

