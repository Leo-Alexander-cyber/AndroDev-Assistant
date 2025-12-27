; AndroDev Assistant Setup Script
; Using NSIS 3.x

; Define application information
!define APP_NAME "AndroDev Assistant"
!define APP_VERSION "1.0.0"
!define APP_PUBLISHER "AndroDev Team"
!define APP_WEBSITE "https://example.com"
!define APP_ID "{A1B2C3D4-E5F6-G7H8-I9J0-K1L2M3N4O5P6}"
!define INSTALL_DIR "$PROGRAMFILES64\${APP_NAME}"

; Include necessary NSIS modules
!include "MUI2.nsh"
!include "x64.nsh"
!include "LogicLib.nsh"
!include "FileFunc.nsh"
!include "GetParameters.nsh"

; Set installer compression (LZMA for best compression, 7z also available)
SetCompressor LZMA

; Installer name and output file
Name "${APP_NAME} ${APP_VERSION}"
OutFile "AndroDev_Assistant_${APP_VERSION}_Setup.exe"

; Default installation directory
InstallDir "${INSTALL_DIR}"

; Request execution level (admin rights only when necessary)
RequestExecutionLevel admin

; Installer pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

; Include modular components
!include "modules/lang.nsh"
!include "modules/detect.nsh"
!include "modules/deps.nsh"
!include "modules/env.nsh"
!include "modules/security.nsh"
!include "modules/update.nsh"
!include "modules/uninstall.nsh"
!include "modules/utils.nsh"

; ------ Variables ------
Var LogFile

; ------ Installer Initialization ------
Function .onInit
    ; Initialize language
    Call InitLanguage
    
    ; Create log file
    Call CreateLogFile
    
    ; Parse command line
    Call ParseCommandLine
    
    ; Check system compatibility
    Call CheckSystemCompatibility
    
    ; Check admin rights if needed
    Call CheckAdminRights
    
    ; Verify installer signature
    Call VerifyInstallerSignature
    
    ; Detect existing installation
    Call DetectExistingInstallation
    
    ; Handle version conflicts
    StrCmp $IsInstalled 1 0 +2
    Call HandleVersionConflict
    
    ; Initialize dependencies
    Call InitDeps
    
    ; Initialize update mechanism
    Call InitUpdate
FunctionEnd

; ------ Main Installation Sections ------

; Main application files
Section "Main Program" SEC_MAIN
    SectionIn RO
    
    ; Create installation directory
    CreateDirectory "$INSTDIR"
    SetOutPath "$INSTDIR"
    
    ; Add main executable
    File "AndroDev_Assistant\build\AndroDev_Assistant.exe"
    
    ; Add all Qt dependency DLLs
    File "AndroDev_Assistant\build\*.dll"
    
    ; Add plugin directories
    CreateDirectory "$INSTDIR\generic"
    SetOutPath "$INSTDIR\generic"
    File "AndroDev_Assistant\build\generic\*.dll"
    
    CreateDirectory "$INSTDIR\iconengines"
    SetOutPath "$INSTDIR\iconengines"
    File "AndroDev_Assistant\build\iconengines\*.dll"
    
    CreateDirectory "$INSTDIR\imageformats"
    SetOutPath "$INSTDIR\imageformats"
    File "AndroDev_Assistant\build\imageformats\*.dll"
    
    CreateDirectory "$INSTDIR\networkinformation"
    SetOutPath "$INSTDIR\networkinformation"
    File "AndroDev_Assistant\build\networkinformation\*.dll"
    
    CreateDirectory "$INSTDIR\platforms"
    SetOutPath "$INSTDIR\platforms"
    File "AndroDev_Assistant\build\platforms\*.dll"
    
    CreateDirectory "$INSTDIR\tls"
    SetOutPath "$INSTDIR\tls"
    File "AndroDev_Assistant\build\tls\*.dll"
    
    CreateDirectory "$INSTDIR\translations"
    SetOutPath "$INSTDIR\translations"
    File "AndroDev_Assistant\build\translations\*.qm"
    
    ; Add ADB files (if not detected)
    CreateDirectory "$INSTDIR\platform-tools"
    SetOutPath "$INSTDIR\platform-tools"
    File /nonfatal "adb.exe"
    File /nonfatal "AdbWinApi.dll"
    File /nonfatal "AdbWinUsbApi.dll"
    
    ; Restore main directory
    SetOutPath "$INSTDIR"
    
    ; Create shortcuts
    CreateShortcut "$DESKTOP\${APP_NAME}.lnk" "$INSTDIR\AndroDev_Assistant.exe" "" "" "0" "" "" "${APP_NAME}"
    
    CreateDirectory "$SMPROGRAMS\${APP_NAME}"
    CreateShortcut "$SMPROGRAMS\${APP_NAME}\${APP_NAME}.lnk" "$INSTDIR\AndroDev_Assistant.exe" "" "" "0" "" "" "${APP_NAME}"
    CreateShortcut "$SMPROGRAMS\${APP_NAME}\Uninstall ${APP_NAME}.lnk" "$INSTDIR\uninstall.exe" "" "" "0" "" "" "Uninstall ${APP_NAME}"
    
    ; Write uninstaller
    WriteUninstaller "$INSTDIR\uninstall.exe"
    
    ; Write registry entries
    WriteRegStr HKLM "${REG_APP_KEY}" "DisplayName" "${APP_NAME}"
    WriteRegStr HKLM "${REG_APP_KEY}" "DisplayVersion" "${APP_VERSION}"
    WriteRegStr HKLM "${REG_APP_KEY}" "Publisher" "${APP_PUBLISHER}"
    WriteRegStr HKLM "${REG_APP_KEY}" "URLInfoAbout" "${APP_WEBSITE}"
    WriteRegStr HKLM "${REG_APP_KEY}" "InstallPath" "$INSTDIR"
    WriteRegStr HKLM "${REG_APP_KEY}" "Version" "${APP_VERSION}"
    
    WriteRegStr HKLM "${REG_UNINSTALL_KEY}" "DisplayName" "${APP_NAME}"
    WriteRegStr HKLM "${REG_UNINSTALL_KEY}" "DisplayVersion" "${APP_VERSION}"
    WriteRegStr HKLM "${REG_UNINSTALL_KEY}" "Publisher" "${APP_PUBLISHER}"
    WriteRegStr HKLM "${REG_UNINSTALL_KEY}" "URLInfoAbout" "${APP_WEBSITE}"
    WriteRegStr HKLM "${REG_UNINSTALL_KEY}" "UninstallString" '"$INSTDIR\uninstall.exe"'
    WriteRegStr HKLM "${REG_UNINSTALL_KEY}" "InstallLocation" "$INSTDIR"
    WriteRegDWORD HKLM "${REG_UNINSTALL_KEY}" "NoModify" 1
    WriteRegDWORD HKLM "${REG_UNINSTALL_KEY}" "NoRepair" 1
    
    ; Create version backup for rollback
    Call CreateVersionBackup
    
    ; Show progress
    Call ShowProgress 50
SectionEnd

; ADB Tools
Section "ADB Tools" SEC_ADB
    SectionIn 1 2 3
    
    ; Install ADB if not detected
    Call InstallADB
    
    ; Show progress
    Call ShowProgress 60
SectionEnd

; Android SDK Components
Section "Android SDK Components" SEC_SDK
    SectionIn 1 2 3
    
    ; Install SDK components if needed
    Call InstallSDKComponents
    
    ; Show progress
    Call ShowProgress 70
SectionEnd

; File Associations
Section "File Associations (.apk/.aab)" SEC_FILE_ASSOC
    SectionIn 1 2 3
    
    ; Register file associations
    Call RegisterAPKAssociation
    Call RegisterAABAssociation
    
    ; Show progress
    Call ShowProgress 80
SectionEnd

; Windows Service Integration
Section "Windows Service Integration" SEC_SERVICE
    SectionIn 1 2
    
    ; Register Windows service
    Call RegisterService
    
    ; Show progress
    Call ShowProgress 90
SectionEnd

; Environment Configuration
Section "Environment Configuration" SEC_ENV
    SectionIn 1 2 3
    
    ; Update system PATH
    Call UpdateSystemPath
    
    ; Show progress
    Call ShowProgress 100
SectionEnd

; ------ Uninstall Section ------
Section "Uninstall" SEC_UNINSTALL
    ; Initialize uninstall
    Call InitUninstall
    
    ; Perform full uninstall
    Call PerformFullUninstall
    
    ; Uninstall finish
    Call UninstallFinish
SectionEnd

; ------ Installer Finish ------
Function .onInstSuccess
    ; Verify file integrity
    Call VerifyFileIntegrity
    
    ; Apply least privilege
    Call ApplyLeastPrivilege
    
    ; Show success message
    DetailPrint "${MSG_INSTALL_SUCCESS}"
FunctionEnd

Function .onInstFailed
    ; Show failure message
    DetailPrint "${MSG_INSTALL_FAILED}"
    
    ; Write to log
    Push "Installation failed!"
    Call WriteLog
FunctionEnd

; ------ Language Settings ------
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "SimpChinese"

; ------ Component Descriptions ------
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${SEC_MAIN} "${COMP_DESC_MAIN}"
    !insertmacro MUI_DESCRIPTION_TEXT ${SEC_ADB} "${COMP_DESC_ADB}"
    !insertmacro MUI_DESCRIPTION_TEXT ${SEC_SDK} "${COMP_DESC_SDK}"
    !insertmacro MUI_DESCRIPTION_TEXT ${SEC_FILE_ASSOC} "${COMP_DESC_FILE_ASSOC}"
    !insertmacro MUI_DESCRIPTION_TEXT ${SEC_SERVICE} "${COMP_DESC_SERVICE}"
    !insertmacro MUI_DESCRIPTION_TEXT ${SEC_ENV} "Environment configuration (PATH updates)"
!insertmacro MUI_FUNCTION_DESCRIPTION_END

; ------ Finish Page Settings ------
!define MUI_FINISHPAGE_RUN "$INSTDIR\AndroDev_Assistant.exe"
!define MUI_FINISHPAGE_RUN_TEXT "Run ${APP_NAME}"
!define MUI_FINISHPAGE_SHOWREADME "$INSTDIR\README.txt"
!define MUI_FINISHPAGE_SHOWREADME_TEXT "View README"
!define MUI_FINISHPAGE_BUTTON "Finish"
