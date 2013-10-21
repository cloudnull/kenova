kenova
^^^^^^

What the kenova source file does is create a wrapper function for the python nova client, which simplifies the users interactions with the python-novaclient.  The script is FULL Featured and works with the Rackspace Cloud in all Active environments.  

This includes :

  * US Cloud Servers
  * US Open Cloud Servers
  * UK Cloud Servers
  * UK Open Cloud Servers
  * SYD Open Cloud Servers


Now Supported is also Cloud Networks as well as Cloud Block Storage.

The python Nova Client is a powerful python based tool that can assist in A LOT of Openstack / Rackspace Cloud Functions.  When you interface with python-nova-client you are using some fantastic libraries that extend the functionality of the Cloud.

Please have a look here to review the work done by many other very bright people. Please review the `Python Nova Client On GIT hub`_\.

In order to install the ``kenova`` application you **MUST** have two dependencies installed on your system.
You need to have both ``Python`` and ``Git`` installed.  These two applications are found in ALL Repositories, or you can get them from source here :

* `Git Client Download and Information`_
* `Python from python.org`_

The ``kenova`` wrapper has been tested to work on most Linux and Unix systems that have Python 2.5+ install and are compatibile with the Python NovaClient modules.

``Here are the Basic Functions of the application :``

.. code-block:: bash 

  Usage: /usr/bin/kenova <EXPRESSION>

  Admin Functions :
    set       -- Used for setting a Key Ring Password used with a setup Endpoint.
    admin     -- Used to specify a Username and API Key
                 \_ Select a region, which is spcified in "[PATH-TO-YOUR-API-FILE]"
                 [-l], [--list] for all available Environments
    new       -- Used to specify a Username and API Key

  Rackspace Specific Functions :
    [region]  -- Specific Region to use, [ord, dfw, syd, iad, hk, lon, luk, lus]


Once you have authenticated with the user name and the API-Key for the account that you want to interact with, simply enter the region that you are authenticated against and the function that you would like to perform.

Once you have the script you will need to install it
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


STOP
====

If you have installed Previous Versions of Kenova, then you will need to locate the old script and remove it.

This can be done in ONE simple step

.. code-block:: bash

    sudo rm $(which kenova)


Basically locate the old script with what ever you chose and then remove it. Done.


Ponder
======

If you have all the dependencies that are required and do not want to re-install things, you can simply run the ``setrc.sh`` script or add the following to your Shell RC file and copy the kenova file to the root of your home directory.

.. code-block:: bash

  if [ -f "$HOME/.kenova" ];then
    source .kenova
  fi


.. code-block:: bash

  cp kenova ~/.kenova


Continue
========

Install the wrapper, which will download the latest Python-NovaClient from the folks at Openstack. This will also install the package Python-LNovaClient which is an adaptation of the openstack client which provides functionality for the Legacy Rackspace Cloud. Additionally the installer will get and install the Rackspace Nova Extensions which provide more capability for the Python-NovaClient.  

Here are the three repositories that are installed when using the scripted installation method :
  * `Legacy Python-NovaClient`_
  * `Openstack Python-NovaClient`_
  * `Rackspace Python-NovaClient Extensions`_

.. code-block:: bash

    sudo bash install.sh

You should know that the Application installation is not needed. If you would like to simply add the kenova functionality to your system you may source the `kenova` file in your `.bashrc` or if you are on a Mac, use the `.profile`

The installer is simply an application which installs the dependencies for Kenova. This also Sets up your system to use Lnova which is a customized nova client used for accessing Legacy Rackspace Cloud Servers.
After you have installed the dependencies, run the ``setrc.sh`` sciprt which will complete the installation and copy the functions to your home folder.
To use the application simply execute the ``kenova`` command from the CLI and begin managing / monitoring your cloud servers more efficiently.

Installation has been tested on :
  * Mac OS X 10.5 +
  * Ubuntu 10.04 +
  * CentOS 5 +
  * Debian 6
  * Mageia 2

While these were the only "Tested" systems, installation should work on ALL Linux Unix Systems, provided you have the python NovaClient.  

Drop me a line if you have any questions.

.. _kenova: https://github.com/cloudnull/kenova
.. _Python Nova Client On GIT hub: https://github.com/openstack/python-novaclient
.. _Git Client Download and Information: http://git-scm.com/downloads
.. _Python from python.org: http://www.python.org/getit/
.. _Legacy Python-NovaClient: https://github.com/cloudnull/python-lnovaclient
.. _Openstack Python-NovaClient: https://github.com/openstack/python-novaclient
.. _Rackspace Python-NovaClient Extensions: https://pypi.python.org/pypi/rackspace-novaclient/


License
_______

Copyright [2013] [Kevin Carter]

License Information :
This software has no warranty, it is provided 'as is'. It is your
responsibility to validate the behavior of the routines and its accuracy using
the code provided. Consult the GNU General Public license for further details
(see GNU General Public License).
http://www.gnu.org/licenses/gpl.html
