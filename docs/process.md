Bukin Process
=============

Getting from a fresh Bukfile to having all plugins installed is a rather complex process.  This file tries to document it as much as possible.

Parse Bukfile
-------------

The Bukfile is evaluated and any errors are presented to the user.  Each resource present is constructed into a list of `Resource` objects that will be passed to future steps.

Resolve Dependencies
--------------------

All resources are checked for any dependancies that will also need to be installed.  At this point, the final version for each `Resource` is recoreded.  Any conflicts are reported to the user.  During this time, many webservice calls are made to the various sites to confirm information.  If the correct version of a resource is already installed, it's excluded from installation.

Download Resources
------------------

All required files from the previous step are downloaded to a temporary folder.  If installation is cancelled at this point, no changes will be made to the system.  Any compressed files are also extracted.

Install Resources
-----------------

All previously downloaded files are copied to the locations specified for installation.  All information about installed version is updated in Bukfile.lock and the locations of installed files is stored.
