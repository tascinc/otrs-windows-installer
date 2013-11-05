|====================================|
| OTRS WINDOWS INSTALLER BUILD GUIDE |
|====================================|

Prepare Prerequisites
=====================

    1. Download and install the newest NSIS installer from
       http://nsis.sourceforge.net/

    2. Install the NSIS Simple Firewall Plugin
        -Download the most recent version from http://nsis.sourceforge.net/NSIS_Simple_Firewall_Plugin
        -Extract the files
        -Copy SimpleFC.dll to your NSIS Plugin directory (e. g. C:\Program Files\NSIS\Plugins)

    3. Install the NSIS ShellLink Plugin
        -Download the most recent version from http://nsis.sourceforge.net/ShellLink_plug-in
        -Extract the files
        -Copy ShellLink.dll to your NSIS Plugin directory (e. g. C:\Program Files\NSIS\Plugins)

    4. Install the NSIS Ports plugin
        - Download Ports.nsh from http://nsis.sourceforge.net/Check_open_ports
        - Copy the file to your NSIS Include directory (e. g. C:\Program Files\NSIS\Include)

    5. Download and install the newest Eclipse framework from
       http://www.eclipse.org/

    6. Download and install the most recent EclipseNSIS plugin
        -Start Eclipse
        -Click Help > Install New Software
        -Add http://eclipsensis.sf.net/update as software location
        -Install EclipseNSIS

Prepare otrs4win
================

    1. Checkout the module otrs4win in the local directory C:\otrs4win

    2. Create a new project in your Eclipse

Prepare OTRS
============

    1. Download the newest version of OTRS from ftp.otrs.org

    2. Unzip the content to C:\otrs4win\OTRS\

    3. Update the version number (and the version postfix) in the OTRS.nsi file

Prepare Strawberry Perl
=======================

    1. Download the latest Portable version of Strawberry Perl from
        http://strawberryperl.com/

    2. Extract the files to C:\strawberry\

    3. Install CPAN modules using the CPAN shell

        > cpan Task::Win32::OTRS

    4. Add mod_perl
        Install mod_perl binaries with the following commands (ref: http://strawberryperl.com/package/kmx/mod_perl/README-512.TXT)
        pip http://strawberryperl.com/package/kmx/mod_perl/5.12_x86/mod_perl-2.0.4-MSWin32-x86-multi-thread-5.12.par
        pip http://strawberryperl.com/package/kmx/mod_perl/5.12_x86/libapreq2-2.12-MSWin32-x86-multi-thread-5.12.par

    5. Delete the cpan directory to save space
        del c:\strawberry\cpan

    6. Delete the temp directory
        del c:\strawberry\temp

    7. Copy the strawberry perl files to C:\otrs4win\StrawberryPerl\


Prepare Apache
==============

    1. Download the most recent Apache server with SSL!! from
       http://httpd.apache.org/

    2. Install it on a test system to extract the needed files
        -Set "somenet.com" as network domain
        -Set "webmaster@somenet.com" as administrator's email address
        -Install it for all users on port 80
        -Select "Custom" as install type
        -Select all components but deselect "Apache Documentation" and
         "Apache Service Taskbar Icon"
        -Install the Apache to C:\Apache
        -Start the installation

    3. Stop the apache service

    4. Copy the apache files to C:\otrs4win\Apache\

    5. Download the following files and store them in C:\otrs4win\Apache\Modules
        http://strawberryperl.com/package/kmx/mod_perl/5.12_x86/mod_perl.so
        http://strawberryperl.com/package/kmx/mod_perl/5.12_x86/mod_apreq2.so
        http://strawberryperl.com/package/kmx/mod_perl/5.12_x86/libapreq2.dll

    6. Download mod_auth_sspi, extract it and put it in C:\otrs4win\Apache\Modules
        - this is an optional module people can configure for easy SSO on Windows

Prepare MySQL
=============

    1. Download the most recent MySQL server "Windows Essentials (x86)" from
       http://dev.mysql.com/downloads/

    2. Install it on a test system to extract the needed files
        -Select "Custom" installation method
        -Select ALL components
        -Install the MySQL server to C:\MySQL

    3. Copy the mysql files to C:\otrs4win\MySQL\

Prepare CRONw
=============

    1. Download the most recent CRONw from http://cronw.sourceforge.net/

    2. Copy the CRONw files to C:\otrs4win\CRONw\

    3. Delete the useless modules directory
        del C:\otrs4win\CRONw\modules

Build the Installer
===================

    1. Start your Eclipse

    2. Open the OTRS.nsi file

    3. Build the installer
