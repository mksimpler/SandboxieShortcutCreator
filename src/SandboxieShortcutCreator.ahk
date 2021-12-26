#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

VERSION = 1.1

#SingleInstance Force
#NoTrayIcon

;; Import
NormalizePath(path)
{
  cc := DllCall("GetFullPathName", "str", path, "uint", 0, "ptr", 0, "ptr", 0, "uint")
  VarSetCapacity(buf, cc*2)
  DllCall("GetFullPathName", "str", path, "uint", cc, "str", buf, "ptr", 0)
  return buf
}

;; Import
ParseCArgs(options:=False)
{
  P_Args := Array()
  P_Args["_"] := Array()
  markedFlag := False
  For index, element in A_Args
  {
    isFlag := False
    If SubStr(element, 1, 1) == "-"
      isFlag = %element%
    If isFlag
    {
      markedFlag = %element%
      P_Args[isFlag] := True
    }
    Else
    {
      If markedFlag
        P_Args[markedFlag] := element
      Else
        P_Args["_"].Push(element)
        
      markedFlag := False
    }
  }
  If options AND options.Count()
  {
    For key, element in options
    {
      If !P_Args[key]
        P_Args[key] := element
    }
  }
  return P_Args
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

EnvGet, LOCALAPPDATA, LOCALAPPDATA
appDataPath = %LOCALAPPDATA%\Sandboxie Shortcut Creator

WriteSetting(sandboxiePath, settingPath)
{
  Global appDataPath
  
  If !FileExist(appDataPath)
    FileCreateDir, %appDataPath%

  settingPath = %appDataPath%\%settingPath%
  IniWrite, %sandboxiePath%, %settingPath%, General, StartPath
}

ReadSetting(settingPath, section, key)
{
  Global appDataPath

  settingPath = %appDataPath%\%settingPath%
  If !FileExist(settingPath)
    Return
  
  IniRead, output, %settingPath%, %section%, %key%
  Return output
}

ReadSettingSanboxiePath(settingPath)
{
  Return ReadSetting(settingPath, "General", "StartPath")
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Initial
args := ParseCArgs()
debug := args["--debug"] OR args["-d"]

logFilePath = %appDataPath%\Runtime.log

If !FileExist(appDataPath)
    FileCreateDir, %appDataPath%
    
LogFile(type, message)
{
  Global logFilePath
  StringUpper, type, type
  FormatTime, timeString,, yyyy-MM-dd HH:mm:ss
  FileAppend, [%timeString%][%type%] %message%`n, %logFilePath%
}

LogDebug(name, message, msgbox:=False)
{
  Global debug
  If debug
  {
    If msgbox
      MsgBox, 64, Debug: %name%, %message%
    LogFile("debug", Format("[{}]{}", name, message))
  }
}

LogDebug("Working dir", A_WorkingDir)

settingPath = Setting.ini

sandboxiePath = C:\Program Files\Sandboxie\Start.exe
sandboxieConfigPath = C:\Windows\Sandboxie.ini

; Check if configure file exists
If !FileExist(sandboxieConfigPath)
{
  MsgBox, 16, Sandboxie not found, Please install or reinstall Sandboxie.
  ExitApp
}

; Check if execute file exists
sandboxiePathInConfig := ReadSettingSanboxiePath(settingPath)
If !!sandboxiePathInConfig
  sandboxiePath = %sandboxiePathInConfig%
  
If !FileExist(sandboxiePath)
{
  MsgBox, 64, Start.exe not found, Please select Sandboxie execute file.
  FileSelectFile, sandboxiePath, 1, C:\Program Files, C:\Program Filesa\Sandboxie\Start.exe, Start.exe
  
  If !sandboxiePath
  {
    MsgBox, 16, Sandboxie not found, Please install or reinstall Sandboxie.
    ExitApp
  }
  Else
  {
	WriteSetting(sandboxiePath, settingPath)
  }
}

LogDebug("info", Format("Run parameters`n    %1: {}`n    --debug: {}", A_Args[1], A_Args[2]))
executePath := NormalizePath(A_Args[1])

If !executePath
  ExitApp

LstBoxValues = ||

; Read Sandboxie configure file
IniRead, Sections, %sandboxieConfigPath%
For i, v in StrSplit(Sections, "`n")
{
  If !InStr(v, "GlobalSettings") AND !InStr(v, "UserSettings")
  {
    If (LstBoxValues == "||")
	  LstBoxValues = %v%
	Else
	  LstBoxValues = %LstBoxValues%|%v%
  }
}

Gui, +AlwaysOnTop -MaximizeBox -MinimizeBox
Gui, Margin, 25, 25
Gui, Add, Text, w150, Select sandbox which to create shortcut to
Gui, Add, ListBox, y+10 vLstBox r10 w150 Sort Choose1, %LstBoxValues%
Gui, Add, Checkbox, y+10 vChkBoxAsk, Ask each time
Gui, Add, Button, vBtnOK w60 gBtnOKClicked, OK
Gui, Add, Button, x+m wp gBtnCancelClicked, Cancel

Gui, Show, Center, Sandboxie
Return

BtnOKClicked:
  Gui, Submit
  
  If (ChkBoxAsk == 1)
  {
    boxName = __ask__
  }
  Else
  {
	boxName = %LstBox%
  }
  
  iconPath = %executePath%
  shortcutPath = %executePath% @%boxName%.lnk

  SplitPath, executePath,, workingDir, ext, filename
  If (ext == "lnk")
  {
    LogFile("verbose", Format("Target is shortcut. Shortcut: {}", executePath))
    shortcutPath = %workingDir%\%filename% @%boxName%.lnk
    
    FileGetShortcut, %executePath%, execRealPath, execWorkingDir
    executePath = %execRealPath%
    iconPath = %execRealPath%
    workingDir = %execWorkingDir%
  }
  
  args = /box:%boxName% "%executePath%"
  LogDebug("Info shortcut", Format("args: {}`n    dir: {}", args, workingDir))

  FileCreateShortcut, "%sandboxiePath%", %shortcutPath%, %workingDir%, %args%, , %iconPath%
  LogFile("info", Format("Shortcut created.`n    Target: {}`n    Box: {}`n    Location: {}", executePath, boxName, shortcutPath))
  
  ExitApp

BtnCancelClicked:
GuiClose:
  ExitApp
