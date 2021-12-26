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

executePath := NormalizePath("SandboxieShortcutCreator.exe")
logFilePath = %appDataPath%\Install.log

If !FileExist(appDataPath)
    FileCreateDir, %appDataPath%

;; Initial
args := ParseCArgs()
debug := args["--debug"] OR args["-d"]

LogFile(type, message)
{
  Global logFilePath
  StringUpper, type, type
  FormatTime, timeString,, yyyy-MM-dd HH:mm:ss
  FileAppend, [%timeString%][%type%] %message%`n, %logFilePath%
}

WriteRegKey(regKey)
{
  Global debug, executePath
  RegWrite, REG_SZ, %regKey%, , Create &shortcut
  RegWrite, REG_SZ, %regKey%, Icon, "C:\Program Files\Sandboxie\Start.exe"
  
  regKeyCommand = %regKey%\command
  
  If debug
    RegWrite, REG_SZ, %regKeyCommand%, , "%executePath%" "`%1" --debug
  Else
    RegWrite, REG_SZ, %regKeyCommand%, , "%executePath%" "`%1"
}

if !FileExist(executePath) ; if not found main program FileAppend
{
    MsgBox, 16, App Panic!, Please place this file in same directory of SandboxieShortcutCreator.exe
	ExitApp
}

regKey = HKEY_CURRENT_USER\SOFTWARE\Classes\*\shell\sandboxshortcut
WriteRegKey(regKey)
LogFile("install", Format("Created registry key at {}.", regKey))

regKey = HKEY_CURRENT_USER\SOFTWARE\Classes\lnkfile\shell\sandboxshortcut
WriteRegKey(regKey)
LogFile("install", Format("Created registry key at {}.", regKey))

MsgBox, 64, Successful, Install completed
