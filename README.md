# Sync XML Data From RoboForm Everywhere Account

This scripts will export all passcard data from your RoboForm Everywhere
account and locally store it in an **unencrypted** raw form.

This is useful if you wish to use this data to import into another password
manager application.

Be careful, your passwords will be stored in open text. Make sure to delete the
data as soon as you are done with it.

The data is stored in raw XML format as it is returned by the RoboForm Everywhere
service. This script makes no attempt to make any sense or format this data. It
simply downloads and dumps each passcard XML file to the disk.

**Suggestion**: I recommend you use some form of encrypted disk, either virtual
or real to work with this data while it is in the open state.

# Getting Started

You will need to install the following Perl modules:

* WWW::Mechanize
* XML::Simple

The easiest way to install the modules is with (`cpanm` command line
tool)[https://metacpan.org/pod/App::cpanminus#INSTALLATION].

You will need to edit two constants `USERNAME` and `PASSWORD` to set your
RoboForm Everywhere account information for retrieval of data.

You may also optionally set the `DATA_DIR` constant which is the directory
used for storing this data.