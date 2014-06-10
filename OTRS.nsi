# --
# OTRS.nsi - a script to generate the OTRS Windows installer
# Copyright (C) 2001-2013 OTRS AG, http://otrs.com/
# --
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU AFFERO General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
# or see http://www.gnu.org/licenses/agpl.txt.
# --

# ------------------------------------------------------------ #
# define general information
# ------------------------------------------------------------ #

!define Installer_Home            "C:\Installer"
!define Installer_Home_Nsis       "${Installer_Home}\otrs4win"
!define Installer_Version_Major   3
!define Installer_Version_Minor   0
!define Installer_Version_Patch   5
#!define Installer_Version_Jointer "-"
#!define Installer_Version_Postfix "rc1"
!define Installer_Version_Jointer ""
!define Installer_Version_Postfix ""

!define OTRS_Name            "OTRS"
!define OTRS_Version_Major "3"
!define OTRS_Version_Minor "3"
!define OTRS_Version_Patch "5"
!define OTRS_Version_Jointer ""
!define OTRS_Version_Postfix ""
!define OTRS_Company         "OTRS Group"
!define OTRS_Url             "www.otrs.com"
!define OTRS_Instance_Number 1

!define OTRS_Version         "${OTRS_Version_Major}.${OTRS_Version_Minor}.${OTRS_Version_Patch}${OTRS_Version_Jointer}${OTRS_Version_Postfix}"
!define OTRS_Instance        "Instance-${OTRS_Instance_Number}"
!define OTRS_RegKey          "SOFTWARE\${OTRS_Name}"
!define OTRS_RegKey_Instance "${OTRS_RegKey}\${OTRS_Instance}"

!define Installer_Version "${Installer_Version_Major}.${Installer_Version_Minor}.${Installer_Version_Patch}${Installer_Version_Jointer}${Installer_Version_Postfix}"
!define Win_RegKey_Uninstall "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\${OTRS_Name}"

!define NET_FRAMEWORK_DOT_MAJOR "4"
!define NET_FRAMEWORK_DOT_MINOR "0"

var ActiveStatePerl
var MinorDifference
var PerlEx
var PerlMajor
var PerlMinor
var PerlExe
var ToInstallDir
var MySQLInstalled
var MySQLConfig
var Installed_OTRS_Major
var Installed_OTRS_Minor
var Installed_OTRS_Patch
var Installed_OTRS_Postfix
var Installed_OTRS_Version
var InstallDirShort
var InstallMode
var Upgrade
var hCtl_btn_OTRSLink
var hCtl_label_Questions

# ------------------------------------------------------------ #
# define installer information
# ------------------------------------------------------------ #

RequestExecutionLevel admin
CRCCheck              on
XPStyle               on
#SetCompress           off
SetCompress           Auto
SetCompressor         /SOLID lzma
SetCompressorDictSize 4
SetDatablockOptimize  On

Name         "${OTRS_Name} ${OTRS_Version}"
OutFile      "${Installer_Home}\otrs-${OTRS_Version}-win-installer-${Installer_Version}.exe"
BrandingText "otrs4win installer - version ${Installer_Version}"

InstallDir $PROGRAMFILES32\${OTRS_Name}
InstallDirRegKey HKLM "${OTRS_RegKey_Instance}" Path

# ------------------------------------------------------------ #
# define multi user information
# ------------------------------------------------------------ #

!define MULTIUSER_EXECUTIONLEVEL Admin
!define MULTIUSER_INSTALLMODE_DEFAULT_REGISTRY_KEY "${OTRS_RegKey_Instance}"
!define MULTIUSER_INSTALLMODE_DEFAULT_REGISTRY_VALUENAME MultiUserInstallMode
!define MULTIUSER_INSTALLMODE_COMMANDLINE
!define MULTIUSER_INSTALLMODE_INSTDIR "${OTRS_Name}"
!define MULTIUSER_INSTALLMODE_INSTDIR_REGISTRY_KEY "${OTRS_RegKey_Instance}"
!define MULTIUSER_INSTALLMODE_INSTDIR_REGISTRY_VALUE "Path"

# ------------------------------------------------------------ #
# define mui information
# ------------------------------------------------------------ #

# global settings
!define MUI_ABORTWARNING

# gui icons
!define MUI_ICON   "${Installer_Home_Nsis}\Graphics\Icons\OTRS.ico"
!define MUI_UNICON "${Installer_Home_Nsis}\Graphics\Icons\OTRS.ico"

# gui header images
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_RIGHT
!define MUI_HEADERIMAGE_BITMAP   "${Installer_Home_Nsis}\Graphics\Header\OTRS.bmp"
!define MUI_HEADERIMAGE_UNBITMAP "${Installer_Home_Nsis}\Graphics\Header\OTRS.bmp"

# ------------------------------------------------------------ #
# load required modules
# ------------------------------------------------------------ #

!include EnvVarUpdate.nsh
!include FileFunc.nsh
!include LogicLib.nsh
!include MUI2.nsh
!include MultiUser.nsh
!include Ports.nsh
!include Sections.nsh
!include WordFunc.nsh
!include x64.nsh
!include "Mode.nsdinc"
!include "DatabaseSelection.nsdinc"

!insertmacro "DirState"

# ------------------------------------------------------------ #
# installer pages
# ------------------------------------------------------------ #

# welcome page
!define MUI_WELCOMEPAGE_TEXT $(mui_welcomepage_text)
!define MUI_WELCOMEFINISHPAGE_BITMAP "${Installer_Home_Nsis}\Graphics\Wizard\OTRS.bmp"
!define MUI_PAGE_CUSTOMFUNCTION_SHOW Questions
!insertmacro MUI_PAGE_WELCOME
Page custom fnc_Mode_Show

# license page (AGPL)
!define MUI_LICENSEPAGE_RADIOBUTTONS
!insertmacro MUI_PAGE_LICENSE "${Installer_Home_Nsis}\Licenses\GNU_Affero_License.rtf"

# directory page
!define MUI_PAGE_CUSTOMFUNCTION_LEAVE InstInstallationDirValidate
!define MUI_PAGE_CUSTOMFUNCTION_PRE DirectoryHide
!define MUI_DIRECTORYPAGE_VARIABLE $ToInstallDir
!insertmacro MUI_PAGE_DIRECTORY

# database selection
Page custom fnc_DatabaseSelection_Show

# start menu page
Var StartMenuGroup
!define MUI_STARTMENUPAGE_REGISTRY_ROOT HKLM
!define MUI_STARTMENUPAGE_NODISABLE
!define MUI_STARTMENUPAGE_REGISTRY_KEY       "${OTRS_RegKey_Instance}"
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME StartMenuGroup
!define MUI_STARTMENUPAGE_DEFAULTFOLDER      "${OTRS_Name}"
!insertmacro MUI_PAGE_STARTMENU Application $StartMenuGroup

# install page
ShowInstDetails Hide
!insertmacro MUI_PAGE_INSTFILES

# finish page
!define MUI_PAGE_CUSTOMFUNCTION_LEAVE InstStartWeb
!define MUI_PAGE_CUSTOMFUNCTION_SHOW  Questions
!define MUI_FINISHPAGE_TEXT           $(mui_finishpage_text)
!define MUI_FINISHPAGE_BUTTON         $(mui_finishpage_button)

!insertmacro MUI_PAGE_FINISH

# ------------------------------------------------------------ #
# uninstaller pages
# ------------------------------------------------------------ #

# welcome page
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "${Installer_Home_Nsis}\Graphics\Wizard\OTRS.bmp"
!insertmacro MUI_UNPAGE_WELCOME

# confirm page
!insertmacro MUI_UNPAGE_CONFIRM

# uninstall page
ShowUninstDetails NeverShow
!insertmacro MUI_UNPAGE_INSTFILES

# finish page
!insertmacro MUI_UNPAGE_FINISH

# ------------------------------------------------------------ #
# load languages
# ------------------------------------------------------------ #

# enable different languages
!insertmacro MUI_LANGUAGE English
!insertmacro MUI_LANGUAGE German
!insertmacro MUI_LANGUAGE Spanish
!insertmacro MUI_LANGUAGE Dutch

# English strings
LangString mui_welcomepage_text        ${LANG_ENGLISH} "This wizard will guide you through the installation of ${OTRS_Name}. $\r$\n$\r$\n\
If you want to avoid rebooting your system after setup please close all other applications before starting the installation.$\r$\n$\r$\n\
Click Next to start the installation."
LangString questions                   ${LANG_ENGLISH} "Questions? Need help?"
LangString perl_header                 ${LANG_ENGLISH} "Production or test environment?"
LangString perl_subheader              ${LANG_ENGLISH} "Please install ActiveState Perl for production use"
LangString perl_title                  ${LANG_ENGLISH} "ActiveState Perl not found!"
LangString perl_advise_text_part1      ${LANG_ENGLISH} "For production environments downloading and installing ActiveState ActivePerl (x86) is highly recommended before running this installer."
LangString perl_cancel_button          ${LANG_ENGLISH} "Cancel and download ActivePerl"
LangString perl_advise_text_part2      ${LANG_ENGLISH} "If you click Next, the installer will set up its own version of perl. This will configure Apache in CGI mode and will be relatively slow. Please only use this for testing or evaluating ${OTRS_Name}."
LangString mui_finishpage_text         ${LANG_ENGLISH} "Installation of all needed services to run ${OTRS_Name} finished successfully.$\r$\n$\r$\nIf you click 'Launch' you'll start the Web Installer to configure ${OTRS_Name}."
LangString mui_finishpage_text_upgrade ${LANG_ENGLISH} "The upgrade of your ${OTRS_Name} is completed successfully and all needed services are restarted. $\r$\n$\r$\nIf you click 'Launch' you'll get redirected to your ${OTRS_Name}."
LangString mui_finishpage_button       ${LANG_ENGLISH} "Launch"
LangString database_header             ${LANG_ENGLISH} "Select database for ${OTRS_Name}"
LangString database_options            ${LANG_ENGLISH} "Options"
LangString database_bundled            ${LANG_ENGLISH} "Install the bundled MySQL database"
LangString database_own                ${LANG_ENGLISH} "Use an already installed database (MySQL, PostgreSQL, Oracle, SQL Server)"

# German strings
LangString mui_welcomepage_text        ${LANG_GERMAN} "Dieser Assistent wird Sie durch den Installationsprozess von ${OTRS_Name} f�hren. $\r$\n$\r$\n\
Um einen Neustart nach Abschluss der Installation zu vermeiden, schlie�en Sie bitte alle laufenden Programme bevor Sie die Installation starten.$\r$\n$\r$\n\
Fortfahren um die Installation zu starten."
LangString questions                   ${LANG_GERMAN} "Fragen? Ben�tigen Sie Hilfe?"
LangString perl_header                 ${LANG_GERMAN} "Produktiv- oder Testumgebung?"
LangString perl_subheader              ${LANG_GERMAN} "Bei produktiven Einsatz bitte ActiveState Perl benutzen"
LangString perl_title                  ${LANG_GERMAN} "ActiveState Perl nicht gefunden!"
LangString perl_advise_text_part1      ${LANG_GERMAN} "F�r produktive Umgebungen wird dringend empfohlen, ActiveState ActivePerl (x86) herunterzuladen und zu installieren, bevor dieser Installer gestartet wird."
LangString perl_cancel_button          ${LANG_GERMAN} "Abbrechen und ActivePerl downloaden"
LangString perl_advise_text_part2      ${LANG_GERMAN} "Wenn Sie fortfahren, wird eine integrierte Perl-Version verwendet und Apache im CGI Modus konfiguriert. Da dieses Setup relativ langsam sein wird, wird dies nur empfohlen um ${OTRS_Name} zu evaluieren oder zu testen."
LangString mui_finishpage_text         ${LANG_GERMAN} "Die Installation aller ben�tigten Dienste um ${OTRS_Name} zu betreiben wurde erfolgreich abgeschlossen.$\r$\n$\r$\nBitte 'Start' klicken um ${OTRS_Name} mit Hilfe des WebInstallers zu konfigurieren."
LangString mui_finishpage_text_upgrade ${LANG_GERMAN} "Das Upgrade Ihres ${OTRS_Name} ist erfolgreich abgeschlossen und alle damit verbundenen Dienste wurden neugestartet.$\r$\n$\r$\n Wenn Sie 'Start' dr�cken, werden Sie zu Ihrem ${OTRS_Name} weitergeleitet."
LangString mui_finishpage_button       ${LANG_GERMAN} "Start"
LangString database_header             ${LANG_GERMAN} "Datenbank f�r ${OTRS_Name} ausw�hlen"
LangString database_options            ${LANG_GERMAN} "Optionen"
LangString database_bundled            ${LANG_GERMAN} "Die mitgelieferte MySQL-Datenbank installieren"
LangString database_own                ${LANG_GERMAN} "Eine bereits installierte Datenbank verwenden (MySQL, PostgreSQL, Oracle, SQL Server)"

# Spanish strings
LangString mui_welcomepage_text        ${LANG_SPANISH} "Este asistente le guiar� a trav�s de la instalaci�n de ${OTRS_Name}. $\r$\n$\r$\n\
Si usted desea evitar el reiniciar su sistema despu�s de la instalaci�n, por favor cierre cualquier otra aplicaci�n antes de iniciar la instalaci�n.$\r$\n$\r$\n\
Haga clic en Siguiente para iniciar la instalaci�n."
LangString questions                   ${LANG_SPANISH} "Questions? Need help?"
LangString perl_header                 ${LANG_SPANISH} "�En producci�n o entorno de prueba?"
LangString perl_subheader              ${LANG_SPANISH} "Por favor instale ActiveState Perl si ser� usado en producci�n"
LangString perl_title                  ${LANG_SPANISH} "!No se encontr� ActiveState Perl!"
LangString perl_advise_text_part1      ${LANG_SPANISH} "Para entornos de producci�n, la descarga e instalaci�n de ActiveState ActivePerl (x86) es altamente recomendable antes de ejecutar este programa de instalaci�n."
LangString perl_cancel_button          ${LANG_SPANISH} "Cancelar y descargar ActivePerl"
LangString perl_advise_text_part2      ${LANG_SPANISH} "Si hace clic en Siguiente, el instalador configurar� su propia versi�n de perl. Esto a su vez configurar� Apache en modo CGI y esto har� que el sistema sea relativamente lento. Por favor use esta configuraci�n solo para pruebas y evaluaci�n de ${OTRS_Name}."
LangString mui_finishpage_text         ${LANG_SPANISH} "La instalaci�n de todos los servicios necesarios para ejecutar ${OTRS_Name} finaliz� con �xito.$\r$\n$\r$\nSi hace clic en 'Iniciar', podr� comenzar el instalador Web para configurar ${OTRS_Name}."
LangString mui_finishpage_text_upgrade ${LANG_SPANISH} "La actualizaci�n de su ${OTRS_Name} ha sido completada satisfactoriamente y todos los servicios fueron reanudados.$\r$\n$\r$\nAl presionar 'Enviar'�ser� redireccionado a su ${OTRS_Name}."
LangString mui_finishpage_button       ${LANG_SPANISH} "Iniciar"
LangString database_header             ${LANG_SPANISH} "Select database for ${OTRS_Name}"
LangString database_options            ${LANG_SPANISH} "Options"
LangString database_bundled            ${LANG_SPANISH} "Install the bundled MySQL database"
LangString database_own                ${LANG_SPANISH} "Use an already installed database (MySQL, PostgreSQL, Oracle, SQL Server)"

# Dutch strings
LangString mui_welcomepage_text        ${LANG_DUTCH} "Dit is de installatieprocedure voor ${OTRS_Name}. $\r$\n$\r$\n\
als u een herstart wilt voorkomen kunt u het beste alle andere applicaties afsluiten voordat u deze installatie start.$\r$\n$\r$\n\
Klik Volgende om de installatie te starten."
LangString questions                   ${LANG_DUTCH} "Vragen? Hulp nodig?"
LangString perl_header                 ${LANG_DUTCH} "Productie- of testomgeving?"
LangString perl_subheader              ${LANG_DUTCH} "Installeer ActiveState perl op productie-omgevingen"
LangString perl_title                  ${LANG_DUTCH} "Geen ActiveState Perl gevonden!"
LangString perl_advise_text_part1      ${LANG_DUTCH} "Voor gebruik in productie-omgevingen raden we aan om ActiveState ActivePerl (x86) te downloaden en installeren voordat u de OTRS installatie start."
LangString perl_cancel_button          ${LANG_DUTCH} "Annuleer en download ActivePerl"
LangString perl_advise_text_part2      ${LANG_DUTCH} "Als u op Volgende klikt zal de installatieprocedure een gebundelde perl-versie installeren. Dit configureert Apache in CGI mode en is relatief langzaam. We raden u aan dit alleen voor het testen of evalueren van ${OTRS_Name} te gebruiken."
LangString mui_finishpage_text         ${LANG_DUTCH} "Installatie van alle services nodig voor ${OTRS_Name} is afgerond.$\r$\n$\r$\nZodra u op 'Start' klikt begint de Web Installer die u gebruikt voor het configureren van ${OTRS_Name}."
LangString mui_finishpage_text_upgrade ${LANG_DUTCH} "De upgrade van ${OTRS_Name} is compleet en alle services zijn herstart. $\r$\n$\r$\nAls u op 'Start' klikt wordt de ${OTRS_Name} inlogpagina geopend."
LangString mui_finishpage_button       ${LANG_DUTCH} "Start"
LangString database_header             ${LANG_DUTCH} "Kies database voor ${OTRS_Name}"
LangString database_options            ${LANG_DUTCH} "Opties"
LangString database_bundled            ${LANG_DUTCH} "Installeer de gebundelde MySQL database"
LangString database_own                ${LANG_DUTCH} "Gebruik een al ge�nstalleerde database (MySQL, PostgreSQL, Oracle, SQL Server)"

# ------------------------------------------------------------ #
# install sections
# ------------------------------------------------------------ #

# install pre section
Section -InstPre

    # install the icon files
    SetOutPath $INSTDIR\otrs4win
    File /r "${Installer_Home_Nsis}\Graphics\Icons\OTRS.ico"

    # install the helper scripts
    File /r "${Installer_Home_Nsis}\Scripts"

    # delete the CVS directory
    sleep 1000  # sleep one second to give the OS time to unlock the directory
    RmDir /r /REBOOTOK $INSTDIR\otrs4win\Scripts\CVS

    ${If} $Upgrade != "no"
        DetailPrint "Stopping services"
        nsExec::Exec "$\"$PerlExe$\" $\"$INSTDIR\OTRS\bin\otrs.Scheduler4win.pl$\" -a stop"
        nsExec::Exec "NET STOP $\"Cron Service (CRONw)$\""
        nsExec::Exec "NET STOP Apache2.2"
        nsExec::Exec "NET STOP MySQL"
    ${EndIf}

SectionEnd

Section -InstPerl
    ${If} ${FileExists} "$ActiveStatePerl"
        # For ActiveState perl, we prefer to install any modules
        # via PPM. We'll also install MinGW so we can install
        # whatever else via cpan.
        ExpandEnvStrings $0 %COMSPEC%
        DetailPrint "Configuring ActiveState Perl. Warning: this can take a very long time..."
        NSExec::ExecToLog '"$0" /C "ppm install DBD::mysql"'
        NSExec::ExecToLog '"$0" /C "ppm install DBD::Pg"'
        NSExec::ExecToLog '"$0" /C "ppm install Crypt::Eksblowfish"'
        NSExec::ExecToLog '"$0" /C "ppm install Crypt::SSLeay"'
        NSExec::ExecToLog '"$0" /C "ppm install Date::Format"'
        NSExec::ExecToLog '"$0" /C "ppm install Date::Manip"'
        NSExec::ExecToLog '"$0" /C "ppm install File::Find::Rule"'
        NSExec::ExecToLog '"$0" /C "ppm install JSON::XS"'
        NSExec::ExecToLog '"$0" /C "ppm install Log::Dispatch"'
        NSExec::ExecToLog '"$0" /C "ppm install Log::Dispatch::FileRotate"'
        NSExec::ExecToLog '"$0" /C "ppm install Log::Log4perl"'
        NSExec::ExecToLog '"$0" /C "ppm install Mail::IMAPClient"'
        NSExec::ExecToLog '"$0" /C "ppm install Net::DNS"'
        NSExec::ExecToLog '"$0" /C "ppm install Net::LDAP"'
        NSExec::ExecToLog '"$0" /C "ppm install PDF::API2"'
        NSExec::ExecToLog '"$0" /C "ppm install Win32::Console::ANSI"'
        NSExec::ExecToLog '"$0" /C "ppm install Win32::Daemon"'
        NSExec::ExecToLog '"$0" /C "ppm install MinGW"'
        NSExec::ExecToLog '"$0" /C "cpan Encode::HanExtra"'

        # set perlexe
        StrCpy $PerlExe $ActiveStatePerl
        DetailPrint "ActivePerl configured."
    ${Else}
        # StrawberryPerl is pre-configured with all modules we need
        # we only need to copy the files
        DetailPrint "Installing Strawberry Perl"

        # remove old perls - but only if it is a 5.16 perl
        ${If} ${FileExists} "$INSTDIR\StrawberryPerl\perl\bin\perl516.dll"
            RMDir /r "$INSTDIR\StrawberryPerl"
        ${EndIf}

        SetOutPath $INSTDIR
        File /r "${Installer_Home}\StrawberryPerl"

        # set perlexe
        StrCpy $PerlExe "$INSTDIR\StrawberryPerl\perl\bin\perl.exe"
        DetailPrint "StrawberryPerl installed."
    ${EndIf}

SectionEnd

# install CRONw section
Section -InstCRONw

    # install CRONw files
    SetOutPath $INSTDIR
    File /r "${Installer_Home}\CRONw"

    # configure CRONw
    GetFullPathName /SHORT $InstallDirShort $INSTDIR
    NSExec::ExecToLog "$\"$PerlExe$\" $\"$INSTDIR\OTRS\bin\otrs.Cron4Win32.pl$\" $\"$InstallDirShort\CRONw\crontab.txt$\""

    # register CRONw as service
    NSExec::ExecToLog "$\"$PerlExe$\" $\"$INSTDIR\CRONw\cronHelper.pl$\" --install"

    # remove the helper script
    ${If} $InstallMode != "Unittest"
        sleep 1000  # sleep one second to give the OS time to unlock the file
        Delete /REBOOTOK "$INSTDIR\otrs4win\Scripts\ConfigureCRONw.pl"
    ${EndIf}

SectionEnd

# install MySQL section
Section /o -InstMySQL InstMySQL

    ${If} $MySQLInstalled <> 1
    ${AndIf} $Upgrade == "no"

        ${IfNot} $BundledMySQL == "false"

            # install MySQL files
            SetOutPath $INSTDIR
            File /r "${Installer_Home}\MySQL"

            # configure the mysql server
            GetFullPathName /SHORT $InstallDirShort $INSTDIR
            NSExec::ExecToLog "$\"$PerlExe$\" $\"$INSTDIR\otrs4win\Scripts\ConfigureMySQL.pl$\" -d $\"$InstallDirShort$\""

            # register mysql as service
            NSExec::ExecToLog '"$INSTDIR\MySQL\bin\mysqld.exe" --install MySQL --defaults-file="$INSTDIR\MySQL\my.ini"'

            sleep 1000  # sleep one second to give the OS time to unlock the file

            # generate a strong password for the OTRS database user
            pwgen::GeneratePassword 14
            pop $0

            StrCpy $MySQLConfig "$\"DBType$\": $\"mysql$\", $\"InstallType$\": $\"CreateDB$\", $\"DBHost$\": $\"localhost$\", $\"OTRSDBUser$\": $\"otrs$\", $\"OTRSDBPassword$\": $\"$0$\", $\"DBName$\": $\"otrs$\", $\"DBUser$\": $\"root$\", $\"DBPassword$\": $\"$\", "

        ${EndIf}

        # remove the helper script
        Delete /REBOOTOK "$INSTDIR\otrs4win\Scripts\ConfigureMySQL.pl"
    ${EndIf}

    # Start MySQL Service
    DetailPrint "Starting MySQL service"
    nsExec::Exec "NET START MySQL"

SectionEnd

# install Apache section
Section /o -InstApache InstApache

   ${If} ${FileExists} "$INSTDIR\StrawberryPerl\perl\bin\perl.exe"

        DetailPrint "Installing/upgrading Apache"
        nsExec::Exec "NET STOP Apache2.2"
        # install Apache files
        SetOutPath $INSTDIR
        File /r "${Installer_Home}\Apache"

       # configure apache
       GetFullPathName /SHORT $InstallDirShort $INSTDIR
       NSExec::ExecToLog "$\"$PerlExe$\" $\"$INSTDIR\otrs4win\Scripts\ConfigureApache.pl$\" -d $\"$InstallDirShort$\""

       # register apache as service
       NSExec::ExecToLog '"$INSTDIR\Apache\bin\httpd.exe" -k install'

       # add the apache service to the firewall exception list
       SimpleFC::AddApplication "Apache HTTP Server" "$INSTDIR\Apache\bin\httpd.exe" 0 2 "" 1
       Pop $0

       # remove the helper script
       ${If} $InstallMode != "Unittest"
           sleep 1000  # sleep one second to give the OS time to unlock the file
           Delete /REBOOTOK "$INSTDIR\otrs4win\Scripts\ConfigureApache.pl"
       ${EndIf}
   ${Else}
       DetailPrint "Configuring Microsoft IIS"

       # locate PerlEx dll based on perl.exe
       ${WordReplace} $ActiveStatePerl 'perl.exe' 'PerlEx30.dll' "-1" $PerlEx
       ExpandEnvStrings $0 %COMSPEC%

       # first make sure Microsoft IIS is installed
       ${DisableX64FSRedirection}
       NSExec::ExecToLog '"$0" /c $WINDIR\system32\dism.exe /online /norestart /enable-feature /ignorecheck /featurename:$\"IIS-WebServerRole$\" /featurename:$\"IIS-ManagementConsole$\" /featurename:$\"IIS-ISAPIExtensions$\" /featurename:$\"IIS-ISAPIFilter$\"'
       ${EnableX64FSRedirection}

       # now configure a web site, and setup perlex with its own application pool
       NSExec::ExecToLog '"$WINDIR\system32\inetsrv\appcmd.exe" add apppool /name:$\"OTRS$\"'
       NSExec::ExecToLog '"$WINDIR\system32\inetsrv\appcmd.exe" set config /section:applicationPools -[name=$\'OTRS$\'].managedPipelineMode:Integrated'
       NSExec::ExecToLog '"$WINDIR\system32\inetsrv\appcmd.exe" set config /section:applicationPools -[name=$\'OTRS$\'].enable32BitAppOnWin64:$\"True$\" /commit:apphost'
       NSExec::ExecToLog '"$WINDIR\system32\inetsrv\appcmd.exe" set config /section:handlers /+[name=$\'PerlEx$\',path=$\'*.pl$\',verb=$\'*$\',modules=$\'IsapiModule$\',scriptProcessor=$\'c:\Perl\bin\PerlEx30.dll$\']'
       NSExec::ExecToLog '"$WINDIR\system32\inetsrv\appcmd.exe" set config /section:system.webServer/security/isapiCgiRestriction /+[path=$\'$PerlEx$\',allowed=$\'True$\'] /commit:apphost'
       NSExec::ExecToLog '"$WINDIR\system32\inetsrv\appcmd.exe" add vdir /app.name:$\"Default Web Site/$\" /path:/otrs-web /physicalPath:$INSTDIR\OTRS\var\httpd\htdocs'
       NSExec::ExecToLog '"$WINDIR\system32\inetsrv\appcmd.exe" add app /site.name:$\"Default Web Site$\" /path:/otrs /physicalPath:$INSTDIR\OTRS\bin\cgi-bin -applicationPool:OTRS'

       # set .NET Framework 4.0 as required version for the pools
       NSExec::ExecToLog "$\"$WINDIR\system32\inetsrv\appcmd.exe$\" set apppool /apppool.name:$\"DefaultAppPool$\" /managedRuntimeVersion:$\"v4.0$\""
       NSExec::ExecToLog "$\"$WINDIR\system32\inetsrv\appcmd.exe$\" set apppool /apppool.name:$\"OTRS$\" /managedRuntimeVersion:$\"v4.0$\""
   ${EndIf}

SectionEnd

# install OTRS section
Section -InstOTRS

    # install OTRS files
    SetOutPath $INSTDIR
    IfFileExists $INSTDIR\OTRS\ARCHIVE 0 +2
       CopyFiles $INSTDIR\OTRS\ARCHIVE $INSTDIR\OTRS\ARCHIVE_OLD

    File /r "${Installer_Home}\OTRS"

    # write permission on OTRS subfolder - Full Control for 'Users' group
    AccessControl::GrantOnFile "$INSTDIR\OTRS" "(S-1-5-32-545)" "FullAccess"

    # configure OTRS
    GetFullPathName /SHORT $InstallDirShort $INSTDIR

    # if we're on Strawberry (i.e. no PerlEx) update shebang line for CGI mode
    ${If} ${FileExists} "$INSTDIR\StrawberryPerl\perl\bin\perl.exe"
        NSExec::ExecToLog "$\"$PerlExe$\" $\"$INSTDIR\otrs4win\Scripts\ConfigureOTRS.pl$\" -s -d $\"$InstallDirShort$\""
    ${Else}
        NSExec::ExecToLog "$\"$PerlExe$\" $\"$INSTDIR\otrs4win\Scripts\ConfigureOTRS.pl$\" -d $\"$InstallDirShort$\""
    ${EndIf}

    ${If} $Upgrade == "no"

        # register Scheduler service (just for 3.1 and later)
        IfFileExists $INSTDIR\OTRS\bin\otrs.Scheduler4winInstaller.pl 0 +2
            NSExec::ExecToLog "$\"$PerlExe$\" $\"$INSTDIR\OTRS\bin\otrs.Scheduler4winInstaller.pl$\" -a install"
    ${Else}

        DetailPrint "Execute additional TODOs for $Upgrade level upgrade..."

        # delete files that existed in the old framework version but no longer exist in the new one
        NSExec::ExecToLog "perl $\"$INSTDIR\otrs4win\Scripts\RemoveOldFrameworkFiles.pl$\" -a remove -o $\"$INSTDIR\OTRS\ARCHIVE_OLD$\" -n $\"$INSTDIR\OTRS\ARCHIVE$\" -d $\"$INSTDIR\OTRS$\""

        # upgrade/patch for otrs
        ${If} $Upgrade == "patch"
            # reinstall all packages, such as ITSM
            NSExec::ExecToLog "perl $\"$INSTDIR\OTRS\bin\otrs.PackageManager.pl$\" -a reinstall-all"

            # delete cache
            NSExec::ExecToLog "perl $\"$INSTDIR\OTRS\bin\otrs.DeleteCache.pl$\""

            # rebuild config
            NSExec::ExecToLog "perl $\"$INSTDIR\OTRS\bin\otrs.RebuildConfig.pl$\""

        ${ElseIf} $Upgrade == "minor"
            # upgrade DB (RebuildConfig and DeleteCache is include in DBUpdate-to...pl)
            NSExec::ExecToLog "perl $\"$INSTDIR\OTRS\bin\otrs.ExecuteDatabaseXML.pl$\" $\"$INSTDIR\OTRS\scripts\database\update\otrs-upgrade-to-${OTRS_Version_Major}.${OTRS_Version_Minor}.xml$\""
            NSExec::ExecToLog "perl $\"$INSTDIR\OTRS\scripts\DBUpdate-to-${OTRS_Version_Major}.${OTRS_Version_Minor}.pl$\""
        ${EndIf}

        # so if we have ActiveStatePerl then we will
        # have IIS server installed.
        ${If} ${FileExists} "$ActiveStatePerl"
            # restart IIS server
            DetailPrint "Reset Microsoft IIS Server..."
            NSExec::ExecToLog "iisreset"
        ${EndIf}

    ${EndIf}

    # add common otrs information
    WriteRegStr HKLM "${OTRS_RegKey_Instance}" OTRS_Version_Major   "${OTRS_Version_Major}"
    WriteRegStr HKLM "${OTRS_RegKey_Instance}" OTRS_Version_Minor   "${OTRS_Version_Minor}"
    WriteRegStr HKLM "${OTRS_RegKey_Instance}" OTRS_Version_Patch   "${OTRS_Version_Patch}"
    WriteRegStr HKLM "${OTRS_RegKey_Instance}" OTRS_Version_Postfix "${OTRS_Version_Postfix}"
    WriteRegStr HKLM "${OTRS_RegKey_Instance}" OTRS_Instance_Number "${OTRS_Instance_Number}"

    # create start menu entries
    !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
    SetOutPath $SMPROGRAMS\$StartMenuGroup
    CreateShortcut "$SMPROGRAMS\$StartMenuGroup\${OTRS_Name} Agent Interface.lnk"     "http://localhost/otrs/index.pl"     "" "$INSTDIR\otrs4win\OTRS.ico"
    CreateShortcut "$SMPROGRAMS\$StartMenuGroup\${OTRS_Name} Customer Interface.lnk"  "http://localhost/otrs/customer.pl"  "" "$INSTDIR\otrs4win\OTRS.ico"
    SetOutPath $SMPROGRAMS\$StartMenuGroup\Tools
    CreateShortcut "$SMPROGRAMS\$StartMenuGroup\Tools\${OTRS_Name} Web Installer.lnk" "http://localhost/otrs/installer.pl" "" "$INSTDIR\otrs4win\OTRS.ico"
    !insertmacro MUI_STARTMENU_WRITE_END

    # create desktop shortcut
    createShortCut "$DESKTOP\${OTRS_Name} Agent Interface.lnk" "http://localhost/otrs/index.pl" "" "$INSTDIR\otrs4win\OTRS.ico"

    # remove the helper script
    ${If} $InstallMode != "Unittest"
        sleep 1000  # sleep one second to give the OS time to unlock the file
        Delete /REBOOTOK "$INSTDIR\otrs4win\Scripts\ConfigureOTRS.pl"
    ${EndIf}

SectionEnd

# install post section
Section -InstPost

    ${If} ${FileExists} "$INSTDIR\StrawberryPerl\perl\bin\perl.exe"
        GetFullPathName /SHORT $InstallDirShort $INSTDIR
        # add paths
        ${EnvVarUpdate} $0 "PATH" "A" "HKLM" "$InstallDirShort\StrawberryPerl\site\bin"
        ${EnvVarUpdate} $0 "PATH" "A" "HKLM" "$InstallDirShort\StrawberryPerl\perl\bin"
        ${EnvVarUpdate} $0 "PATH" "A" "HKLM" "$InstallDirShort\StrawberryPerl\c\bin"
    ${EndIf}

    # add common instance information
    WriteRegStr HKLM "${OTRS_RegKey_Instance}" Path                      $INSTDIR
    WriteRegStr HKLM "${OTRS_RegKey_Instance}" Installer_Version_Major   "${Installer_Version_Major}"
    WriteRegStr HKLM "${OTRS_RegKey_Instance}" Installer_Version_Minor   "${Installer_Version_Minor}"
    WriteRegStr HKLM "${OTRS_RegKey_Instance}" Installer_Version_Patch   "${Installer_Version_Patch}"
    WriteRegStr HKLM "${OTRS_RegKey_Instance}" Installer_Version         "${Installer_Version}"
    WriteRegStr HKLM "${OTRS_RegKey_Instance}" Installer_Version_Postfix "${Installer_Version_Postfix}"

    # add uninstaller
    WriteUninstaller $INSTDIR\uninstall.exe
    WriteRegStr HKLM "${Win_RegKey_Uninstall}"   DisplayName     "${OTRS_Name}"
    WriteRegStr HKLM "${Win_RegKey_Uninstall}"   DisplayIcon     $INSTDIR\otrs4win\OTRS.ico
    WriteRegStr HKLM "${Win_RegKey_Uninstall}"   Publisher       "${OTRS_Company}"
    WriteRegStr HKLM "${Win_RegKey_Uninstall}"   HelpTelephone   " +1 (415) 3660178"
    WriteRegStr HKLM "${Win_RegKey_Uninstall}"   HelpLink        "http://doc.otrs.org/"
    WriteRegStr HKLM "${Win_RegKey_Uninstall}"   URLInfoAbout    "http://${OTRS_Url}/"
    WriteRegStr HKLM "${Win_RegKey_Uninstall}"   URLUpdateInfo   "http://www.otrs.org/download/"
    WriteRegStr HKLM "${Win_RegKey_Uninstall}"   Comments        "OTRS Help Desk"
    WriteRegStr HKLM "${Win_RegKey_Uninstall}"   UninstallString $INSTDIR\uninstall.exe
    WriteRegDWORD HKLM "${Win_RegKey_Uninstall}" NoModify        1
    WriteRegDWORD HKLM "${Win_RegKey_Uninstall}" NoRepair        1

    # start the otrs services
    sleep 2000
    DetailPrint "Starting services"
    nsExec::Exec "NET START $\"Cron Service (CRONw)$\""
    nsExec::Exec "$\"$PerlExe$\" $\"$INSTDIR\OTRS\bin\otrs.Scheduler4win.pl$\" -a start"
    nsExec::Exec "NET START Apache2.2"

    # refresh the windows desktop (required for Vista's desktop)
    System::Call 'Shell32::SHChangeNotify(i 0x8000000, i 0, i 0, i 0)'

SectionEnd

# ------------------------------------------------------------ #
# uninstall sections
# ------------------------------------------------------------ #

# uninstall pre section
Section -un.UninstPre

    # stop the otrs services
    DetailPrint "Stopping services"
    nsExec::Exec "perl $\"$INSTDIR\OTRS\bin\otrs.Scheduler4win.pl$\" -a stop"
    nsExec::Exec "NET STOP $\"Cron Service (CRONw)$\""
    nsExec::Exec "NET STOP Apache2.2"
    nsExec::Exec "NET STOP MySQL"

    sleep 2000

SectionEnd

# uninstall OTRS section
Section -un.UninstOTRS

    # remove start menu entries
    Delete /REBOOTOK "$SMPROGRAMS\$StartMenuGroup\${OTRS_Name} Agent Interface.lnk"
    Delete /REBOOTOK "$SMPROGRAMS\$StartMenuGroup\${OTRS_Name} Customer Interface.lnk"
    Delete /REBOOTOK "$SMPROGRAMS\$StartMenuGroup\Tools\${OTRS_Name} Web Installer.lnk"

    # remove desktop shortcut
    Delete /REBOOTOK "$DESKTOP\${OTRS_Name} Agent Interface.lnk"

    DeleteRegValue HKLM "${OTRS_RegKey_Instance}" StartMenuGroup
    DeleteRegKey HKLM "${OTRS_RegKey_Instance}"

    # remove items from Path
    GetFullPathName /SHORT $InstallDirShort $INSTDIR
    ${un.EnvVarUpdate} $0 "PATH" "R" "HKLM" "$InstallDirShort\StrawberryPerl\site\bin"
    ${un.EnvVarUpdate} $0 "PATH" "R" "HKLM" "$InstallDirShort\StrawberryPerl\perl\bin"
    ${un.EnvVarUpdate} $0 "PATH" "R" "HKLM" "$InstallDirShort\StrawberryPerl\c\bin"

    # deregister Scheduler service (just for 3.1 and later)
    IfFileExists $INSTDIR\OTRS\bin\otrs.Scheduler4winInstaller.pl 0 +2
        NSExec::ExecToLog "perl $\"$INSTDIR\OTRS\bin\otrs.Scheduler4winInstaller.pl$\" -a remove"

    # delete the OTRS files
    RmDir /r /REBOOTOK $INSTDIR\OTRS

SectionEnd

# uninstall CRONw section
Section -un.UninstCRONw

    # deregister CRONw as service
    NSExec::ExecToLog "perl $\"$INSTDIR\CRONw\cronHelper.pl$\" --remove"

    # delete the CRONw files
    RmDir /r /REBOOTOK $INSTDIR\CRONw

SectionEnd

# uninstall Apache section
Section /o -un.UninstApache UninstApache

    # deregister apache as service
    NSExec::ExecToLog '"$INSTDIR\Apache\bin\httpd.exe" -k uninstall'

    # remove the apache service from the firewall exeption list
    SimpleFC::RemoveApplication "$INSTDIR\Apache\bin\httpd.exe"
    Pop $0

    # delete the Apache files
    RmDir /r /REBOOTOK $INSTDIR\Apache

SectionEnd

# uninstall MySQL section
Section /o -un.UninstMySQL UninstMySQL

    # deregister mysql as service
    NSExec::ExecToLog '"$INSTDIR\MySQL\bin\mysqld"  --remove MySQL'

    # delete the MySQL files
    RmDir /r /REBOOTOK $INSTDIR\MySQL

SectionEnd

# uninstall StrawberryPerl section
Section -un.UninstStrawberryPerl

    # delete the StrawberryPerl files
    RmDir /r /REBOOTOK $INSTDIR\StrawberryPerl

SectionEnd

# uninstall post section
Section -un.UninstPost

    # remove start menu
    Delete /REBOOTOK "$SMPROGRAMS\$StartMenuGroup\Tools\Uninstall ${OTRS_Name}.lnk"
    Delete /REBOOTOK "$SMPROGRAMS\$StartMenuGroup\Tools\${OTRS_Name} Services Start.lnk"
    Delete /REBOOTOK "$SMPROGRAMS\$StartMenuGroup\Tools\${OTRS_Name} Services Stop.lnk"
    Delete /REBOOTOK "$SMPROGRAMS\$StartMenuGroup\Tools\${OTRS_Name} Services Restart.lnk"
    sleep 1000  # sleep one second to give the OS time to unlock the directory
    RmDir /r /REBOOTOK $SMPROGRAMS\$StartMenuGroup\Tools
    sleep 2000  # sleep two second to give the OS time to unlock the directory
    RmDir /r /REBOOTOK $SMPROGRAMS\$StartMenuGroup

    # remove uninstaller
    DeleteRegKey HKLM "${Win_RegKey_Uninstall}"
    Delete /REBOOTOK $INSTDIR\uninstall.exe

    # remove common instance information
    DeleteRegValue HKLM "${OTRS_RegKey_Instance}" Path
    DeleteRegKey   HKLM "${OTRS_RegKey_Instance}"
    DeleteRegKey   HKLM "${OTRS_RegKey}"

    # delete install directory
    sleep 1000  # sleep one second to give the OS time to unlock the directory
    RmDir /r /REBOOTOK $INSTDIR

    # refresh the windows desktop (required for Vista's desktop)
    System::Call 'Shell32::SHChangeNotify(i 0x8000000, i 0, i 0, i 0)'

SectionEnd

# ------------------------------------------------------------ #
# install functions
# ------------------------------------------------------------ #

# installer init function
Function .onInit

    InitPluginsDir

    Call InstCheckAlreadyRunning
    Call InstCheckAlreadyInstalled
    Call InstCheckActiveStatePerl
    Call InstCheckMySQLAlreadyInstalled
    Call InstCheckWebServerAlreadyInstalled

    # base path for OTRS installation
    # take root of program files directory
    ${GetRoot} $PROGRAMFILES $R0
    StrCpy $ToInstallDir "$R0\otrs\"

    # insert plugins
    !insertmacro MUI_LANGDLL_DISPLAY
    !insertmacro MULTIUSER_INIT

    # activate optional installer sections
    !insertmacro SelectSection ${InstMySQL}
    !insertmacro SelectSection ${InstApache}

    # investigate the install mode
    ClearErrors
    ${GetOptions} $CMDLINE "/U" $R0
    IfErrors 0 +3
        StrCpy $InstallMode "Normal"
        goto +2
        StrCpy $InstallMode "Unittest"

FunctionEnd

# to check if the installer is already running
Function InstCheckAlreadyRunning

    # prevent multiple instances of the installer
    System::Call 'kernel32::CreateMutexA(i 0, i 0, t "myMutex") i .r1 ?e'
    Pop $R0
    StrCmp $R0 0 +3
    MessageBox MB_OK|MB_ICONSTOP "The ${OTRS_Name} installer is already running."
    Abort

FunctionEnd

# to check if OTRS is already installed
Function InstCheckAlreadyInstalled

    ReadRegStr $R0 HKLM "${Win_RegKey_Uninstall}" "UninstallString"

    # if OTRS is already installed, make sure this is a newer version
    ${If} ${FileExists} $R0

        # read version from history
        ReadRegStr $Installed_OTRS_Major   HKLM "${OTRS_RegKey_Instance}" OTRS_Version_Major
        ReadRegStr $Installed_OTRS_Minor   HKLM "${OTRS_RegKey_Instance}" OTRS_Version_Minor
        ReadRegStr $Installed_OTRS_Patch   HKLM "${OTRS_RegKey_Instance}" OTRS_Version_Patch
        ReadRegStr $Installed_OTRS_Postfix HKLM "${OTRS_RegKey_Instance}" OTRS_Version_Postfix

        # combine to one string
        StrCpy $Installed_OTRS_Version "$Installed_OTRS_Major.$Installed_OTRS_Minor.$Installed_OTRS_Patch.$Installed_OTRS_Postfix"

        # convert to numbers so 'beta' and 'rc' will be no problem
        ${VersionConvert} $Installed_OTRS_Version "" $R0
        ${VersionConvert} ${OTRS_Version} "" $R1

        # comparison: 0 = equal, 1 = installed is newer, 2 = we are newer
        ${VersionCompare} $R0 $R1 $R0

        ${If} $R0 = 0
                MessageBox MB_OK|MB_ICONSTOP "You have already installed OTRS $Installed_OTRS_Version."
                Abort
        ${EndIf}

        ${If} $R0 = 1
                MessageBox MB_OK|MB_ICONSTOP "You have installed $Installed_OTRS_Version, which is newer than ${OTRS_Version}."
                Abort
        ${EndIf}

        ${If} $R0 = 2

            # we can only do patch level upgrades or upgrades that differ one minor
            ${If} $Installed_OTRS_Major < ${OTRS_Version_Major}
                MessageBox MB_OK|MB_ICONSTOP "You have installed $Installed_OTRS_Version. Please don't skip minor levels when upgrading."
                Abort
            ${Else}
                IntOp $MinorDifference ${OTRS_Version_Minor} - $Installed_OTRS_Minor

                # same major level
                ${If} $MinorDifference > 1
                   MessageBox MB_OK|MB_ICONSTOP "You have installed $Installed_OTRS_Version. Please don't skip minor levels when upgrading."
                   Abort
                ${EndIf}
                ${If} $MinorDifference == 1
                    StrCpy $Upgrade "minor"
                ${EndIf}
                ${If} $MinorDifference == 0
                    StrCpy $Upgrade "patch"
                ${EndIf}
            ${EndIf}
        ${EndIf}
    ${Else}
        StrCpy $Upgrade "no"
    ${EndIf}

FunctionEnd

# Usage
# Define in your script two constants:
#   NET_FRAMEWORK_DOT_MAJOR "(Major framework version)"
#   NET_FRAMEWORK_DOT_MINOR "{Minor framework version)"
#
# Call IsDotNetInstalled
# This function will abort the installation if the required version
# or higher version of the .NET Framework is not installed.  Place it in
# either your .onInit function or your first install section before
# other code.
Function IsDotNetInstalled

    StrCpy $0 "0"
    StrCpy $1 "SOFTWARE\Microsoft\.NETFramework" ;registry entry to look in.
    StrCpy $2 0

    StartEnum:
        # Enumerate the versions installed.
        EnumRegKey $3 HKLM "$1\policy" $2

        # If we don't find any versions installed, it's not here.
        StrCmp $3 "" noDotNet notEmpty

    # We found something.
    notEmpty:
        # Find out if the RegKey starts with 'v'.
        # If it doesn't, goto the next key.
        StrCpy $4 $3 1 0
        StrCmp $4 "v" +1 goNext
        StrCpy $4 $3 1 1

        # It starts with 'v'.  Now check to see how the installed major version
        # relates to our required major version.
        # If it's equal check the minor version, if it's greater,
        # we found a good RegKey.
        IntCmp $4 ${NET_FRAMEWORK_DOT_MAJOR} +1 goNext yesDotNetReg
        # Check the minor version.  If it's equal or greater to our requested
        # version then we're good.
        StrCpy $4 $3 1 3
        IntCmp $4 ${NET_FRAMEWORK_DOT_MINOR} yesDotNetReg goNext yesDotNetReg

    goNext:
        # Go to the next RegKey.
        IntOp $2 $2 + 1
        goto StartEnum

    yesDotNetReg:
        # Now that we've found a good RegKey, let's make sure it's actually
        # installed by getting the install path and checking to see if the
        # mscorlib.dll exists.
        EnumRegValue $2 HKLM "$1\policy\$3" 0
        # $2 should equal whatever comes after the major and minor versions
        # (ie, v1.1.4322)
        StrCmp $2 "" noDotNet
        ReadRegStr $4 HKLM $1 "InstallRoot"
        # Hopefully the install root isn't empty.
        StrCmp $4 "" noDotNet
        # build the actuall directory path to mscorlib.dll.
        StrCpy $4 "$4$3.$2\mscorlib.dll"
        IfFileExists $4 yesDotNet noDotNet

    noDotNet:
        # Nope, something went wrong along the way.  Looks like the
        # proper .NET Framework isn't installed.
        MessageBox MB_OK|MB_ICONSTOP "You must have v${NET_FRAMEWORK_DOT_MAJOR}.${NET_FRAMEWORK_DOT_MINOR} or greater of the .NET Framework installed."
        Abort

    yesDotNet:
        # Everything checks out.  Go on with the rest of the installation.

FunctionEnd

Function InstCheckActiveStatePerl

    # check if 64-bit Perl is installed, we need 32-bit because of PerlEx
    # we need to use SetRegView64 on 64-bit OS otherwise we can not find
    # the correct regkey because the installer is a 32-bit
    # application itself
    ${If} ${FileExists} $WINDIR\SYSWOW64\*.*
        SetRegView 64
        ReadRegStr $ActiveStatePerl HKLM Software\Perl BinDir
        SetRegView 32
        ${If} ${FileExists} "$ActiveStatePerl"
                MessageBox MB_OK|MB_ICONSTOP "You have installed ActiveState Perl 64-bit. Please uninstall the 64-bit version and install the x86 version before continuing setup."
                ExecShell "open" "http://www.activestate.com/activeperl/downloads"
                Abort
        ${EndIf}
    ${EndIf}

    # check if ActiveState is installed
    ReadRegStr $ActiveStatePerl HKLM Software\Perl BinDir

    # if we have ActiveState, test its properties
    ${If} ${FileExists} "$ActiveStatePerl"

        # check if ActiveState Perl is correct version
        # ActiveState always has the two latest 'stable' perls for download
        # Right now (Nov 2013) this is 5.16 and 5.18
        # we need 5.16 - with 5.18 we have still open issues:
        # http://bugs.otrs.org/show_bug.cgi?id=9905
        # also not all 5.18 fixes are backported to OTRS 3.1.
        nsExec::ExecToStack '"$ActiveStatePerl" -MConfig -e $\"print $$Config{api_revision}$\"'
        Pop $0
        Pop $PerlMajor

        nsExec::ExecToStack '"$ActiveStatePerl" -MConfig -e $\"print $$Config{api_version}$\"'
        Pop $0
        Pop $PerlMinor

        ${If} $PerlMajor = 5
            ${If} $PerlMinor <> 16
                MessageBox MB_OK|MB_ICONSTOP "Please install ActivePerl 5.16 for x86. I found version $perlmajor.$perlminor."
                ExecShell "open" "http://www.activestate.com/activeperl/downloads"
                Abort
            ${EndIf}
        ${Else}
            # different major version than 5? Really?
            MessageBox MB_OK|MB_ICONSTOP "Please install ActivePerl 5.16 for x86. I found version $perlmajor.$perlminor."
            ExecShell "open" "http://www.activestate.com/activeperl/downloads"
            Abort
        ${EndIf}

        # check if the minimum required version of .NET Framework is installed
        Call IsDotNetInstalled
    ${Else}
           DetailPrint "No ActiveState perl found"
    ${EndIf}

FunctionEnd

# to check if MySQL is already installed
Function InstCheckMySQLAlreadyInstalled

    ${If} ${TCPPortOpen} 3306
        StrCpy $MySQLInstalled 1
    ${EndIf}

FunctionEnd

# to check if port 80 is available - non-fatal
Function InstCheckWebServerAlreadyInstalled

    ${If} ${TCPPortOpen} 80
#    MessageBox MB_OK "Port 80 is already in use. You probably already have a web server installed. OTRS brings it's own Apache instance and can only run on ports 80 or 443 (HTTPS). Make sure you configure your server so this causes no issues."
    ${EndIf}

FunctionEnd

Function Questions
    ${NSD_CreateLabel} 120u 171u 95u 9u $(questions)
    Pop $hCtl_label_Questions
    SetCtlColors $hCtl_label_Questions "" "${MUI_BGCOLOR}"

    ${NSD_CreateLink} 120u 180u 66u 12u "www.otrs.com"
    Pop $hCtl_btn_OTRSLink
    ${NSD_AddStyle} $hCtl_btn_OTRSLink ${WS_VISIBLE}
    SetCtlColors $hCtl_btn_OTRSLink "0x31596B" "${MUI_BGCOLOR}"
    ${NSD_OnClick} $hCtl_btn_OTRSLink onClickOTRSLink

    # set different text for finish page the installer
    # did a upgrade of the OTRS System
    ${IfNot} $Upgrade == "no"
        # the variable can be found in the Finish.nsh
        # of NSIS and the expression ${WM_SETTEXT} 0 "STR:[Text]" sets the
        # new text for the label
        SendMessage $mui.FinishPage.Text ${WM_SETTEXT} 0 "STR:$(mui_finishpage_text_upgrade)"
    ${EndIf}
FunctionEnd

Function onClickOTRSLink

    Pop $0
    ExecShell "open" "http://www.otrs.com"

    FunctionEnd

Function DirectoryHide

    ${If} $Upgrade != "no"
         # set install dir from registry
         ReadRegStr $INSTDIR HKLM "${OTRS_RegKey_Instance}" "Path"
         Abort
    ${EndIf}

FunctionEnd

# to check if install directory is OK
Function InstInstallationDirValidate

    ${If} $Upgrade == "no"

        StrCpy $INSTDIR $ToInstallDir

        # make sure $INSTDIR path is either empty or does not exist.
        Push $0
        ${DirState} "$INSTDIR" $0

        ${If} $0 == 1   #folder is full.  (other values: 0: empty, -1: not found)
            MessageBox MB_OK|MB_ICONEXCLAMATION "Directory not empty! Please select another directory."
            Abort
        ${EndIf}

        Pop $0

        # Check if path is not in Program Files, ActiveState perl gets in trouble there.
        # Also, it is difficult to for instance modify Config.pm there.
        ${If} ${FileExists} $WINDIR\SYSWOW64\*.*
            # On 64-bit systems check both directories
            ${StrStr} $1 "$INSTDIR" "$PROGRAMFILES32"
            ${StrStr} $2 "$INSTDIR" "$PROGRAMFILES64"
        ${Else}
            # On 32-bit systems check just Program Files
            ${StrStr} $1 "$INSTDIR" "$PROGRAMFILES"
            StrCpy $2 ''
        ${EndIf}

        # StrStr returns an empty string if there was no match
        ${If} $1 != ''
        ${OrIf} $2 != ''
            MessageBox MB_OK|MB_ICONEXCLAMATION "Don't install OTRS in Program Files directory! Please select another directory."
            Abort
        ${EndIf}
        Pop $1
        Pop $2

    ${EndIf}

FunctionEnd


Function InstStartWeb
# after completion launch the web installer for a new install
# or the agent interface for upgrade (possibly even package manager?)

    ${If} $Upgrade == "no"

        # write a .json file to indicate we already had the License page
        CreateDirectory $INSTDIR\OTRS\var\tmp
        FileOpen $9 "$INSTDIR\OTRS\var\tmp\installer.json" w ;Opens an empty file for writing
        FileWrite $9 "{$MySQLConfig $\"SkipLicense$\":1,$\"SkipLog$\":1}$\n"
        FileClose $9 ;Closes the filled file

        # open the web installer
        ExecShell "open" "http://localhost/otrs/installer.pl"
    ${Else}
        ExecShell "open" "http://localhost/otrs/index.pl"
    ${EndIf}

FunctionEnd

Function CancelAndLaunchSite

    # Cancel was pressed, the user wants to go to ActiveState to download ActivePerl
    # this opens http://www.activestate.com/activeperl/downloads but I can change the URL if needed
    ExecShell "open" "http://www.activestate.com/activeperl/downloads"
    Quit

FunctionEnd

# ------------------------------------------------------------ #
# uninstall functions
# ------------------------------------------------------------ #

# uninstaller init function
Function un.onInit

    InitPluginsDir

    Call un.UninstCheckAlreadyRunning

    !insertmacro MUI_STARTMENU_GETFOLDER Application $StartMenuGroup
    !insertmacro MULTIUSER_UNINIT

    ReadRegStr $INSTDIR HKLM "${OTRS_RegKey_Instance}" Path

    # activate optional uninstaller sections
    !insertmacro SelectSection ${UninstApache}
    !insertmacro SelectSection ${UninstMySQL}

FunctionEnd

# to check if the uninstaller is already running
Function un.UninstCheckAlreadyRunning

    # prevent multiple instances of the uninstaller
    System::Call 'kernel32::CreateMutexA(i 0, i 0, t "myMutex") i .r1 ?e'
    Pop $R0
    StrCmp $R0 0 +3
    MessageBox MB_OK|MB_ICONSTOP "The ${OTRS_Name} uninstaller is already running."
    Abort

FunctionEnd
