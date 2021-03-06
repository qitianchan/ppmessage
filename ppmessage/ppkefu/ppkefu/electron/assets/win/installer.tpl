!define APP_NAME "<%= name %>"
!define APP_DIR "${APP_NAME}"

Name "${APP_NAME}"

!include "MUI2.nsh"
!define MUI_ICON "icon.ico"

!addplugindir .
!include "nsProcess.nsh"


# define the resulting installer's name
OutFile "<%= out %>\${APP_NAME}-setup.exe"

# set the installation directory
InstallDir "$PROGRAMFILES\${APP_NAME}\"

# interface settings
           
!define MUI_FINISHPAGE_RUN_TEXT "Start ${APP_NAME}"
!define MUI_FINISHPAGE_RUN "$INSTDIR\${APP_NAME}.exe"

# app dialogs
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY               
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_LANGUAGE "SimpChinese"
!insertmacro MUI_LANGUAGE "TradChinese"
!insertmacro MUI_LANGUAGE "English"


# default section start
Section
  SetShellVarContext all

  # delete the installed files
  RMDir /r $INSTDIR

  # define the path to which the installer should install
  SetOutPath $INSTDIR

  # specify the files to go in the output path
  File /r "<%= appPath %>\*"

  # specify icon to go in the output path
  File "icon.ico"

  # create the uninstaller
  WriteUninstaller "$INSTDIR\Uninstall ${APP_NAME}.exe"

  # create shortcuts in the start menu and on the desktop
  CreateDirectory "$SMPROGRAMS\${APP_DIR}"
  CreateShortCut "$SMPROGRAMS\${APP_DIR}\${APP_NAME}.lnk" "$INSTDIR\${APP_NAME}.exe"
  CreateShortCut "$SMPROGRAMS\${APP_DIR}\Uninstall ${APP_NAME}.lnk" "$INSTDIR\Uninstall ${APP_NAME}.exe"
  CreateShortCut "$DESKTOP\${APP_NAME}.lnk" "$INSTDIR\${APP_NAME}.exe"

  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" \
                   "DisplayName" "${APP_NAME}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" \
                   "UninstallString" "$INSTDIR\Uninstall ${APP_NAME}.exe"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" \
                   "DisplayIcon" "$INSTDIR\icon.ico"
SectionEnd

# create a section to define what the uninstaller does
Section "Uninstall"

  ${nsProcess::FindProcess} "${APP_NAME}.exe" $R0

  ${If} $R0 == 0
      DetailPrint "${APP_NAME} is running. Closing it down..."
      ${nsProcess::KillProcess} "${APP_NAME}.exe" $R0
      DetailPrint "Waiting for ${APP_NAME} to close."
      Sleep 2000
  ${EndIf}

  ${nsProcess::Unload}

  SetShellVarContext all

  # delete the installed files
  RMDir /r $INSTDIR

  # delete the shortcuts
  delete "$SMPROGRAMS\${APP_DIR}\${APP_NAME}.lnk"
  delete "$SMPROGRAMS\${APP_DIR}\Uninstall ${APP_NAME}.lnk"
  rmDir  "$SMPROGRAMS\${APP_DIR}"
  delete "$DESKTOP\${APP_NAME}.lnk"


  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}"
SectionEnd

Function .onInit

	;Language selection dialog

	Push ""
	Push ${LANG_TRADCHINESE}
	Push "Traditional Chinese"
	Push ${LANG_SIMPCHINESE}
	Push "Simplified Chinese"
	Push ${LANG_ENGLISH}
	Push "English"
	Push A ; A means auto count languages
	       ; for the auto count to work the first empty push (Push "") must remain
	LangDLL::LangDialog "Installer Language" "Please select the language of the installer"

	Pop $LANGUAGE
	StrCmp $LANGUAGE "cancel" 0 +2
		Abort
FunctionEnd