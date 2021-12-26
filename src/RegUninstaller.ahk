#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

VERSION = 1.1

#SingleInstance Force
#NoTrayIcon

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

EnvGet, LOCALAPPDATA, LOCALAPPDATA
appDataPath = %LOCALAPPDATA%\Sandboxie Shortcut Creator
logFilePath = %appDataPath%\Install.log

If !FileExist(appDataPath)
    FileCreateDir, %appDataPath%

LogFile(type, message)
{
  Global logFilePath
  StringUpper, type, type
  FormatTime, timeString,, yyyy-MM-dd HH:mm:ss
  FileAppend, [%timeString%][%type%] %message%`n, %logFilePath%
}

regKey = HKEY_CURRENT_USER\SOFTWARE\Classes\*\shell\sandboxshortcut
RegDelete, %regKey%
LogFile("uninstall", Format("Deleted registry key at {}.", regKey))

regKey = HKEY_CURRENT_USER\SOFTWARE\Classes\lnkfile\shell\sandboxshortcut
RegDelete, %regKey%
LogFile("uninstall", Format("Deleted registry key at {}.", regKey))

MsgBox, 64, Successful, Removed completely
