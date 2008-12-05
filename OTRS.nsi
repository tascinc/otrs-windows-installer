# --
# OTRS.nsi - a script to generate the otrs4win installer
# Copyright (C) 2001-2008 OTRS AG, http://otrs.org/
# --
# $Id: OTRS.nsi,v 1.26 2008-12-05 17:03:33 mh Exp $
# --
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
# --

# ------------------------------------------------------------ #
# define general information
# ------------------------------------------------------------ #

!define Installer_Home            "C:\otrs4win"
!define Installer_Home_Nsis       "${Installer_Home}\otrs4win"
!define Installer_Version_Major   2
!define Installer_Version_Minor   0
!define Installer_Version_Patch   0
!define Installer_Version_Jointer "-"
!define Installer_Version_Postfix "beta3"

!define OTRS_Name            "OTRS"
!define OTRS_Version_Major   2
!define OTRS_Version_Minor   3
!define OTRS_Version_Patch   3
#!define OTRS_Version_Jointer "-"
#!define OTRS_Version_Postfix "beta1"
!define OTRS_Version_Jointer ""
!define OTRS_Version_Postfix ""
!define OTRS_Company         "OTRS AG"
!define OTRS_Url             "www.otrs.com"
!define OTRS_Instance_Number 1

!define OTRS_Version         "${OTRS_Version_Major}.${OTRS_Version_Minor}.${OTRS_Version_Patch}"
!define OTRS_Instance        "Instance-${OTRS_Instance_Number}"
!define OTRS_RegKey          "SOFTWARE\${OTRS_Name}"
!define OTRS_RegKey_Instance "${OTRS_RegKey}\${OTRS_Instance}"

!define Installer_Version "${Installer_Version_Major}.${Installer_Version_Minor}.${Installer_Version_Patch}"
!define Win_RegKey_Uninstall "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\${OTRS_Name}"

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

Name         "${OTRS_Name} ${OTRS_Version} ${OTRS_Version_Postfix}"
OutFile      "${Installer_Home}\otrs-${OTRS_Version}${OTRS_Version_Jointer}${OTRS_Version_Postfix}-win-installer-${Installer_Version}${Installer_Version_Jointer}${Installer_Version_Postfix}.exe"
BrandingText "otrs4win installer - version ${Installer_Version} ${Installer_Version_Postfix}"

InstallDir $PROGRAMFILES32\${OTRS_Name}
InstallDirRegKey HKLM "${OTRS_RegKey_Instance}" Path
var InstallDirShort

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
!define MUI_ICON   "${Installer_Home_Nsis}\Graphics\Icons\OTRSInstall.ico"
!define MUI_UNICON "${Installer_Home_Nsis}\Graphics\Icons\OTRSUninstall.ico"

# gui header images
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_RIGHT
!define MUI_HEADERIMAGE_BITMAP   "${Installer_Home_Nsis}\Graphics\Header\OTRSInstall.bmp"
!define MUI_HEADERIMAGE_UNBITMAP "${Installer_Home_Nsis}\Graphics\Header\OTRSUninstall.bmp"

# ------------------------------------------------------------ #
# load required modules
# ------------------------------------------------------------ #

!include MultiUser.nsh
!include Sections.nsh
!include MUI2.nsh
!include FileFunc.nsh

!insertmacro "DirState"

# ------------------------------------------------------------ #
# installer pages
# ------------------------------------------------------------ #

# welcome page
!define MUI_WELCOMEFINISHPAGE_BITMAP "${Installer_Home_Nsis}\Graphics\Wizard\OTRSInstall.bmp"
!insertmacro MUI_PAGE_WELCOME

# license page (GPL v2)
!insertmacro MUI_PAGE_LICENSE "${Installer_Home_Nsis}\Licenses\GNU_License_v2.rtf"

# license page (GPL v1 for dmake)
!insertmacro MUI_PAGE_LICENSE "${Installer_Home_Nsis}\Licenses\GNU_License_v1.rtf"

# license page (Apache v2)
!insertmacro MUI_PAGE_LICENSE "${Installer_Home_Nsis}\Licenses\Apache_License_v2.rtf"

# directory page
!define MUI_PAGE_CUSTOMFUNCTION_LEAVE InstInstallationDirValidate
!insertmacro MUI_PAGE_DIRECTORY

# start menu page
Var StartMenuGroup
!define MUI_STARTMENUPAGE_REGISTRY_ROOT HKLM
!define MUI_STARTMENUPAGE_NODISABLE
!define MUI_STARTMENUPAGE_REGISTRY_KEY       "${OTRS_RegKey_Instance}"
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME StartMenuGroup
!define MUI_STARTMENUPAGE_DEFAULTFOLDER      "${OTRS_Name}"
!insertmacro MUI_PAGE_STARTMENU Application $StartMenuGroup

# install page
ShowInstDetails NeverShow
!define MUI_PAGE_CUSTOMFUNCTION_PRE InstSectionsSet
!insertmacro MUI_PAGE_INSTFILES

# finish page
!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_FUNCTION  InstStartWebInstaller
!define MUI_FINISHPAGE_RUN_TEXT      $(mui_finishpage_run_text)
!define MUI_FINISHPAGE_LINK          "powered by ${OTRS_Company}"
!define MUI_FINISHPAGE_LINK_LOCATION "http://${OTRS_Url}"
!insertmacro MUI_PAGE_FINISH

# ------------------------------------------------------------ #
# uninstaller pages
# ------------------------------------------------------------ #

# welcome page
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "${Installer_Home_Nsis}\Graphics\Wizard\OTRSUninstall.bmp"
!insertmacro MUI_UNPAGE_WELCOME

# confirm page
!insertmacro MUI_UNPAGE_CONFIRM

# uninstall page
ShowUninstDetails NeverShow
!define MUI_PAGE_CUSTOMFUNCTION_PRE un.UninstSectionsSet
!insertmacro MUI_UNPAGE_INSTFILES

# finish page
!define MUI_UNFINISHPAGE_LINK          "powered by ${OTRS_Company}"
!define MUI_UNFINISHPAGE_LINK_LOCATION "http://${OTRS_Url}"
!insertmacro MUI_UNPAGE_FINISH

# ------------------------------------------------------------ #
# load languages
# ------------------------------------------------------------ #

# installer languages
!insertmacro MUI_LANGUAGE English
!insertmacro MUI_LANGUAGE German
!insertmacro MUI_LANGUAGE Spanish
!insertmacro MUI_LANGUAGE French
!insertmacro MUI_LANGUAGE Greek
!insertmacro MUI_LANGUAGE Italian
!insertmacro MUI_LANGUAGE Russian

# english strings
LangString mui_finishpage_run_text ${LANG_ENGLISH} "Continue with Web-Installer"

# german strings
LangString mui_finishpage_run_text ${LANG_GERMAN} "Weiter mit Web-Installer"

# spanish strings
LangString mui_finishpage_run_text ${LANG_SPANISH} "Continue with Web-Installer"

# frensh strings
LangString mui_finishpage_run_text ${LANG_FRENCH} "Continue with Web-Installer"

# greek strings
LangString mui_finishpage_run_text ${LANG_GREEK} "Continue with Web-Installer"

# italian strings
LangString mui_finishpage_run_text ${LANG_ITALIAN} "Continue with Web-Installer"

# russian strings
LangString mui_finishpage_run_text ${LANG_RUSSIAN} "Continue with Web-Installer"

# ------------------------------------------------------------ #
# install sections
# ------------------------------------------------------------ #

# install pre section
Section -InstPre

    # install the icon files
    SetOutPath $INSTDIR\otrs4win
    File /r "${Installer_Home_Nsis}\Graphics\Icons\OTRS.ico"
    File /r "${Installer_Home_Nsis}\Graphics\Icons\OTRSInstall.ico"
    File /r "${Installer_Home_Nsis}\Graphics\Icons\OTRSUninstall.ico"
    File /r "${Installer_Home_Nsis}\Graphics\Icons\OTRSServices.ico"

    # install the helper scripts
    File /r "${Installer_Home_Nsis}\Scripts"

    # delete the CVS directory
    sleep 1000  # sleep one second to give the OS time to unlock the directory
    RmDir /r /REBOOTOK $INSTDIR\otrs4win\Scripts\CVS

SectionEnd

# install StrawberryPerl section
Section -InstStrawberryPerl

    # install StrawberryPerl files
    SetOutPath $INSTDIR
    File /r "${Installer_Home}\StrawberryPerl"

    # configure StrawberryPerl
    GetFullPathName /SHORT $InstallDirShort $INSTDIR
    ExecWait "$\"$INSTDIR\StrawberryPerl\perl\bin\perl.exe$\" $\"$INSTDIR\otrs4win\Scripts\ConfigureStrawberryPerl.pl$\" -d $\"$InstallDirShort$\""

    # remove the helper script
    sleep 1000  # sleep one second to give the OS time to unlock the file
    Delete /REBOOTOK "$INSTDIR\otrs4win\Scripts\ConfigureStrawberryPerl.pl"

SectionEnd

# install CRONw section
Section -InstCRONw

    # install CRONw files
    SetOutPath $INSTDIR
    File /r "${Installer_Home}\CRONw"

    # configure CRONw
    GetFullPathName /SHORT $InstallDirShort $INSTDIR
    ExecWait "$\"$INSTDIR\StrawberryPerl\perl\bin\perl.exe$\" $\"$INSTDIR\otrs4win\Scripts\ConfigureCRONw.pl$\" -d $\"$InstallDirShort$\""

    # register CRONw as service
    ExecWait "$\"$INSTDIR\StrawberryPerl\perl\bin\perl.exe$\" $\"$INSTDIR\CRONw\cronHelper.pl$\" --install"

    # remove the helper script
    sleep 1000  # sleep one second to give the OS time to unlock the file
    Delete /REBOOTOK "$INSTDIR\otrs4win\Scripts\ConfigureCRONw.pl"

SectionEnd

# install MySQL section
Section /o -InstMySQL InstMySQL

    # install MySQL files
    SetOutPath $INSTDIR
    File /r "${Installer_Home}\MySQL"

    # Copy my-medium.ini to my.ini
    CopyFiles /SILENT /FILESONLY $INSTDIR\MySQL\my-medium.ini $INSTDIR\MySQL\my.ini 5

    # configure the mysql server
    GetFullPathName /SHORT $InstallDirShort $INSTDIR
    ExecWait "$\"$INSTDIR\StrawberryPerl\perl\bin\perl.exe$\" $\"$INSTDIR\otrs4win\Scripts\ConfigureMySQL.pl$\" -d $\"$InstallDirShort$\""

    # register mysql as service
    ExecWait '"$INSTDIR\MySQL\bin\mysqld-nt.exe" --install MySQL --defaults-file="$INSTDIR\MySQL\my.ini"'

    # remove the helper script
    sleep 1000  # sleep one second to give the OS time to unlock the file
    Delete /REBOOTOK "$INSTDIR\otrs4win\Scripts\ConfigureMySQL.pl"

SectionEnd

# install Apache section
Section /o -InstApache InstApache

    # install Apache files
    SetOutPath $INSTDIR
    File /r "${Installer_Home}\Apache"

    # configure apache
    GetFullPathName /SHORT $InstallDirShort $INSTDIR
    ExecWait "$\"$INSTDIR\StrawberryPerl\perl\bin\perl.exe$\" $\"$INSTDIR\otrs4win\Scripts\ConfigureApache.pl$\" -d $\"$InstallDirShort$\""

    # register apache as service
    ExecWait '"$INSTDIR\Apache\bin\httpd.exe" -k install'

    # add the apache service to the firewall exection list
    SimpleFC::AddApplication "Apache HTTP Server" "$INSTDIR\Apache\bin\httpd.exe" 0 2 "" 1
    Pop $0

    # remove the helper script
    sleep 1000  # sleep one second to give the OS time to unlock the file
    Delete /REBOOTOK "$INSTDIR\otrs4win\Scripts\ConfigureApache.pl"

SectionEnd

# install OTRS section
Section -InstOTRS

    # install OTRS files
    SetOutPath $INSTDIR
    File /r "${Installer_Home}\OTRS"

    # Copy Config.pm.dist to Config.pm
    CopyFiles /SILENT /FILESONLY $INSTDIR\OTRS\Kernel\Config.pm.dist $INSTDIR\OTRS\Kernel\Config.pm 5

    # Copy GenericAgent.pm.dist to GenericAgent.pm
    CopyFiles /SILENT /FILESONLY $INSTDIR\OTRS\Kernel\Config\GenericAgent.pm.dist $INSTDIR\OTRS\Kernel\Config\GenericAgent.pm 2

    # configure OTRS
    GetFullPathName /SHORT $InstallDirShort $INSTDIR
    ExecWait "$\"$INSTDIR\StrawberryPerl\perl\bin\perl.exe$\" $\"$INSTDIR\otrs4win\Scripts\ConfigureOTRS.pl$\" -d $\"$InstallDirShort$\""

    # add common otrs information
    WriteRegStr HKLM "${OTRS_RegKey_Instance}" OTRS_Version_Major   "${OTRS_Version_Major}"
    WriteRegStr HKLM "${OTRS_RegKey_Instance}" OTRS_Version_Minor   "${OTRS_Version_Minor}"
    WriteRegStr HKLM "${OTRS_RegKey_Instance}" OTRS_Version_Patch   "${OTRS_Version_Patch}"
    WriteRegStr HKLM "${OTRS_RegKey_Instance}" OTRS_Version_Postfix "${OTRS_Version_Postfix}"
    WriteRegStr HKLM "${OTRS_RegKey_Instance}" OTRS_Instance_Number "${OTRS_Instance_Number}"

    # create start menu entries
    !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
    SetOutPath $SMPROGRAMS\$StartMenuGroup
    CreateShortcut "$SMPROGRAMS\$StartMenuGroup\${OTRS_Name} Agent-Interface.lnk"     "http://localhost/otrs/index.pl"     "" "$INSTDIR\otrs4win\OTRS.ico"
    CreateShortcut "$SMPROGRAMS\$StartMenuGroup\${OTRS_Name} Customer-Interface.lnk"  "http://localhost/otrs/customer.pl"  "" "$INSTDIR\otrs4win\OTRS.ico"
    SetOutPath $SMPROGRAMS\$StartMenuGroup\Tools
    CreateShortcut "$SMPROGRAMS\$StartMenuGroup\Tools\${OTRS_Name} Web-Installer.lnk" "http://localhost/otrs/installer.pl" "" "$INSTDIR\otrs4win\OTRS.ico"
    !insertmacro MUI_STARTMENU_WRITE_END

    # create desktop shortcut
    createShortCut "$DESKTOP\${OTRS_Name} Agent-Interface.lnk" "http://localhost/otrs/index.pl" "" "$INSTDIR\otrs4win\OTRS.ico"

#    # create quicklaunch shortcut
#    createShortCut "$QUICKLAUNCH\${OTRS_Name} Agent-Interface.lnk" "http://localhost/otrs/index.pl" "" "$INSTDIR\otrs4win\OTRS.ico"

    # remove the helper script
    sleep 1000  # sleep one second to give the OS time to unlock the file
    Delete /REBOOTOK "$INSTDIR\otrs4win\Scripts\ConfigureOTRS.pl"

SectionEnd

# install post section
Section -InstPost

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
    WriteRegStr HKLM "${Win_RegKey_Uninstall}"   DisplayIcon     $INSTDIR\otrs4win\OTRSInstall.ico
    WriteRegStr HKLM "${Win_RegKey_Uninstall}"   Publisher       "${OTRS_Company}"
    WriteRegStr HKLM "${Win_RegKey_Uninstall}"   HelpTelephone   "+49 6172 681988-0"
    WriteRegStr HKLM "${Win_RegKey_Uninstall}"   HelpLink        "http://doc.otrs.org/"
    WriteRegStr HKLM "${Win_RegKey_Uninstall}"   URLInfoAbout    "http://${OTRS_Url}/"
    WriteRegStr HKLM "${Win_RegKey_Uninstall}"   URLUpdateInfo   "http://www.otrs.org/download/"
    WriteRegStr HKLM "${Win_RegKey_Uninstall}"   Comments        "Open Ticket Request System"
    WriteRegStr HKLM "${Win_RegKey_Uninstall}"   UninstallString $INSTDIR\uninstall.exe
    WriteRegDWORD HKLM "${Win_RegKey_Uninstall}" NoModify        1
    WriteRegDWORD HKLM "${Win_RegKey_Uninstall}" NoRepair        1

    # create start menu entry for the uninstaller
    !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
    SetOutPath $SMPROGRAMS\$StartMenuGroup\Tools
    CreateShortcut "$SMPROGRAMS\$StartMenuGroup\Tools\Uninstall ${OTRS_Name}.lnk"        "$INSTDIR\uninstall.exe"
    CreateShortcut "$SMPROGRAMS\$StartMenuGroup\Tools\${OTRS_Name} Services Start.lnk"   "$INSTDIR\otrs4win\Scripts\OTRSServicesStart.bat"   "" "$INSTDIR\otrs4win\OTRSServices.ico"
    CreateShortcut "$SMPROGRAMS\$StartMenuGroup\Tools\${OTRS_Name} Services Stop.lnk"    "$INSTDIR\otrs4win\Scripts\OTRSServicesStop.bat"    "" "$INSTDIR\otrs4win\OTRSServices.ico"
    CreateShortcut "$SMPROGRAMS\$StartMenuGroup\Tools\${OTRS_Name} Services Restart.lnk" "$INSTDIR\otrs4win\Scripts\OTRSServicesRestart.bat" "" "$INSTDIR\otrs4win\OTRSServices.ico"
    !insertmacro MUI_STARTMENU_WRITE_END

    # if InstApache is selected

        # copy mod_perl.so to the apache modules directory
        CopyFiles /SILENT /FILESONLY $INSTDIR\StrawberryPerl\perl\mod_perl.so $INSTDIR\Apache\modules\mod_perl.so 125
    # endif

    # start the otrs services
    sleep 2000
    ExecWait "$INSTDIR\otrs4win\Scripts\OTRSServicesStart.bat"

    # refresh the windows desktop (required for Vista's desktop)
    System::Call 'Shell32::SHChangeNotify(i 0x8000000, i 0, i 0, i 0)'

SectionEnd

# ------------------------------------------------------------ #
# uninstall sections
# ------------------------------------------------------------ #

# uninstall pre section
Section -un.UninstPre

    # stop the otrs services
    ExecWait "$INSTDIR\otrs4win\Scripts\OTRSServicesStop.bat"
    sleep 2000

SectionEnd

# uninstall OTRS section
Section -un.UninstOTRS

    # remove start menu entries
    Delete /REBOOTOK "$SMPROGRAMS\$StartMenuGroup\${OTRS_Name} Agent-Interface.lnk"
    Delete /REBOOTOK "$SMPROGRAMS\$StartMenuGroup\${OTRS_Name} Customer-Interface.lnk"
    Delete /REBOOTOK "$SMPROGRAMS\$StartMenuGroup\Tools\${OTRS_Name} Web-Installer.lnk"

    # remove desktop shortcut
    Delete /REBOOTOK "$DESKTOP\${OTRS_Name} Agent-Interface.lnk"

#    # remove quicklaunch shortcut
#    Delete /REBOOTOK "$QUICKLAUNCH\${OTRS_Name} Agent-Interface.lnk"

    DeleteRegValue HKLM "${OTRS_RegKey_Instance}" StartMenuGroup
    DeleteRegKey HKLM "${OTRS_RegKey_Instance}"

    # delete the OTRS files
    RmDir /r /REBOOTOK $INSTDIR\OTRS

SectionEnd

# uninstall CRONw section
Section -un.UninstCRONw

    # register CRONw as service
    ExecWait "$\"$INSTDIR\StrawberryPerl\perl\bin\perl.exe$\" $\"$INSTDIR\CRONw\cronHelper.pl$\" --remove"

    # delete the CRONw files
    RmDir /r /REBOOTOK $INSTDIR\CRONw

SectionEnd

# uninstall Apache section
Section /o -un.UninstApache UninstApache

    # deregister apache as service
    ExecWait '"$INSTDIR\Apache\bin\httpd.exe" -k uninstall'

    # remove the apache service from the firewall exection list
    SimpleFC::RemoveApplication "$INSTDIR\Apache\bin\httpd.exe"
    Pop $0

    # delete the Apache files
    RmDir /r /REBOOTOK $INSTDIR\Apache

SectionEnd

# uninstall MySQL section
Section /o -un.UninstMySQL UninstMySQL

    # deregister mysql as service
    ExecWait '"$INSTDIR\MySQL\bin\mysqld-nt"  --remove MySQL'

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

    # insert language plugin
    !insertmacro MUI_LANGDLL_DISPLAY

    # insert multiuser plugin
    !insertmacro MULTIUSER_INIT

FunctionEnd

# to set the installer selections
Function InstSectionsSet

    !insertmacro SelectSection ${InstMySQL}
    !insertmacro SelectSection ${InstApache}

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
    IfFileExists $R0 +1 NotInstalled
    MessageBox MB_OK|MB_ICONSTOP "${OTRS_Name} is already installed."
    Abort

    NotInstalled:

FunctionEnd

# to check if install directory is empty
Function InstInstallationDirValidate

    #make sure $INSTDIR path is either empty or does not exist.
    Push $0
    ${DirState} "$INSTDIR" $0

    ${If} $0 == 1   #folder is full.  (other values: 0: empty, -1: not found)
        MessageBox MB_OK|MB_ICONEXCLAMATION "Directory not empty! Please select another directory."
        Abort
    ${EndIf}

    Pop $0

FunctionEnd

# to open the webinstaller after the installation
Function InstStartWebInstaller

    ExecShell "open" "http://localhost/otrs/installer.pl"

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

FunctionEnd

# to set the uninstaller selections
Function un.UninstSectionsSet

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
