#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

VERSION = 1

#SingleInstance Force
#NoTrayIcon

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

EnvGet, LOCALAPPDATA, LOCALAPPDATA
appDataPath = %LOCALAPPDATA%\Sandboxie Shortcut Creator

logFilePath = %appDataPath%\Install.log
regKey = HKEY_CURRENT_USER\SOFTWARE\Classes\*\shell\sandboxshortcut

RegDelete, %regKey%

If !FileExist(appDataPath)
    FileCreateDir, %appDataPath%

FormatTime, timeString,, yyyy-MM-dd HH:mm:ss
FileAppend, [%timeString%] Deleted registry key at %regKey%`n, %logFilePath%

MsgBox, 64, Successful, Removed completely
