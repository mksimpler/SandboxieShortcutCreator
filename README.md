# Sandboxie Shortcut Creator

Simple script to make Windows shortcut working with Sandboxie more convienient.

---

## How to use

Right-click on any file or program you want to create shortcut that working inside Sandboxie and choose entry "Create shortcut".

![screenshot_01](/screenshots/screenshot_01.png)

Choose sandbox that file or program will be opened inside.

## How to build for yourself

1. First, make sure you have installed Autohotkey (https://www.autohotkey.com/).
2. Clone this then run **build.bat**.  
   If you have custom icon, then run build as:

> build.bat \<path-to-ico-file\>  
> Example: build.bat .\icon.ico

The compiled files will be in **".\build"** folder.

## Install

1. First download script in [releases](https://github.com/mksimpler/SandboxieShortcutCreator/releases) page..
2. Extract anywhre in your computer.
3. Run RegInstaller.exe to add right-click context menu in File Explorer.

## Uninstall

1. Find your extract directory when you installed the script and run RegUninstaller.exe.
2. You can delete leftover log files at  **"%USERPROFILE%\AppData\Local\Sandboxie Shortcut Creator\"**.
