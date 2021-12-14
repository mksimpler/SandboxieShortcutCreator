#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

VERSION = 1

#SingleInstance Force
#NoTrayIcon

NormalizePath(path)
{
  cc := DllCall("GetFullPathName", "str", path, "uint", 0, "ptr", 0, "ptr", 0, "uint")
  VarSetCapacity(buf, cc*2)
  DllCall("GetFullPathName", "str", path, "uint", cc, "str", buf, "ptr", 0)
  return buf
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

EnvGet, LOCALAPPDATA, LOCALAPPDATA
appDataPath = %LOCALAPPDATA%\Sandboxie Shortcut Creator

executePath := NormalizePath("SandboxieShortcutCreator.exe")
logFilePath = %appDataPath%\Install.log

regKey = HKEY_CURRENT_USER\SOFTWARE\Classes\*\shell\sandboxshortcut

if !FileExist(executePath) ; if not found main program FileAppend
{
    MsgBox, 16, App Panic!, Please place this file in same directory of SandboxieShortcutCreator.exe
	ExitApp
}

regKeyCommand = %regKey%\command

RegWrite, REG_SZ, %regKey%, , Create &shortcut
RegWrite, REG_SZ, %regKey%, Icon, "C:\Program Files\Sandboxie\Start.exe"
RegWrite, REG_SZ, %regKeyCommand%, , "%executePath%" "`%1"

If !FileExist(appDataPath)
    FileCreateDir, %appDataPath%

FormatTime, timeString,, yyyy-MM-dd HH:mm:ss
FileAppend, [%timeString%] Created registry key at %regKey%`n, %logFilePath%

MsgBox, 64, Successful, Install completed
