# OTRS Windows Installer Build Guide

Once you set up the installation prerequisites, you can skip all steps except for 'Prepare OTRS'
and 'Build the installer' if you need to build a new installer for a new version of OTRS.


## Prepare NSIS Installer

1. Download and install the newest NSIS installer from http://nsis.sourceforge.net/

2. Install the NSIS Simple Firewall Plugin
 - Download the most recent version from http://nsis.sourceforge.net/NSIS_Simple_Firewall_Plugin
 - Extract the files
 - Copy `SimpleFC.dll` to your NSIS Plugin directory (e. g. `C:\Program Files\NSIS\Plugins`)

3. Install the NSIS ShellLink Plugin
 - Download the most recent version from http://nsis.sourceforge.net/ShellLink_plug-in
 - Extract the files
 - Copy ShellLink.dll to your NSIS Plugin directory (e. g. C:\Program Files\NSIS\Plugins)

4. Install the NSIS Ports plugin
 - Download Ports.nsh from http://nsis.sourceforge.net/Check_open_ports
 - Copy the file to your NSIS Include directory (e. g. C:\Program Files\NSIS\Include)

5. Install EnvVarUpdate Include
 - Download EnvVarUpdate.nsh from http://nsis.sourceforge.net/mediawiki/images/a/ad/EnvVarUpdate.7z
 - Copy the file to your NSIS Include directory (e. g. C:\Program Files\NSIS\Include)

6. Install Access Control Plugin
 - Download AccessControl.dll from http://nsis.sourceforge.net/AccessControl_plug-in
 - Copy the file to your NSIS Plugin directory (e. g. C:\Program Files\NSIS\Plugin)


## Prepare installer directory

1. Create a directory `c:\Installer`

2. Checkout the module otrs-windows-installer in the local directory C:\Installer in a dir called `otrs4win`

    git clone https://github.com/OTRS/otrs-windows-installer.git otrs4win


## Prepare Strawberry Perl

1. Download the Portable version of Strawberry Perl 5.16 (32 bit) from http://strawberryperl.com/

2. Extract the files to C:\strawberry\

3. Install CPAN modules using the CPAN shell

    > cpan Task::OTRS::Win32

4. Delete the cpan directory to save space
    > del c:\strawberry\cpan

5. Delete the temp directory
    > del c:\strawberry\temp

6. Copy the strawberry perl files to C:\Installer\StrawberryPerl\


## Prepare Apache

1. Download the most recent Apache server with SSL from http://httpd.apache.org/

2. Install it on a test system to extract the needed files
 - Set "somenet.com" as network domain
 - Set "webmaster@somenet.com" as administrator's email address
 - Install it for all users on port 80
 - Select "Custom" as install type
 - Select all components but deselect "Apache Documentation" and "Apache Service Taskbar Icon"
 - Install the Apache to C:\Apache
 - Start the installation

3. Stop the apache service

4. Copy the apache files to C:\Installer\Apache\

5. Download the following files and store them in C:\Installer\Apache\Modules
 - http://strawberryperl.com/package/kmx/mod_perl/5.12_x86/mod_perl.so
 - http://strawberryperl.com/package/kmx/mod_perl/5.12_x86/mod_apreq2.so
 - http://strawberryperl.com/package/kmx/mod_perl/5.12_x86/libapreq2.dll

6. Download mod_auth_sspi, extract it and put it in C:\Installer\Apache\Modules - this is an optional module people can configure for easy SSO on Windows


## Prepare MySQL

1. Download the most recent MySQL server 5.1 (32 bit) "Windows Essentials (x86)" from http://dev.mysql.com/downloads/

2. Install it on a test system to extract the needed files
 - Select "Custom" installation method
 - Select ALL components
 - Install the MySQL server to C:\MySQL

3. Skip the wizward for the configuration.

4. Copy the data folder of the MySQL from
    C:\ProgramData\MySQL\MySQL Server 5.1\Data\
    to
    C:\MySQL\data

5. Copy the mysql files to C:\Installer\MySQL\


## Prepare CRONw

1. Download the CRONw 2.0 from http://cronw.sourceforge.net/

2. Copy the CRONw files to C:\Installer\CRONw\

3. Delete the useless modules directory
    del C:\Installer\CRONw\modules


## Prepare OTRS

1. Open a cmd.exe window in the Installer directory.

2. Run the following script - it will download, extract, and put the OTRS directory in the correct place as well as update the version numbers in the OTRS.nsi installer file.

    perl otrs4win\GetOTRSArchive.pl http://ftp.otrs.org/pub/otrs/otrs-3.2.12.zip


## Build the Installer

1. Right-click OTRS.nsi in Explorer, select 'Compile'.

2. Upload the installer after build finishes (takes about 10 minutes).
