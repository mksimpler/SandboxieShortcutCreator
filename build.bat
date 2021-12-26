@echo OFF

set VERSION=1.0

:: "build" folder to contain compiled files
if not exist .\build (
  mkdir build
)

:: Compile main script
if [%1] == [] (
  ahk2exe /in .\src\SandboxieShortcutCreator.ahk /out .\build\SandboxieShortcutCreator.exe
) else (
  :: Run this if user has passed custom icon for main script
  ahk2exe /icon %1 /in .\src\SandboxieShortcutCreator.ahk /out .\build\SandboxieShortcutCreator.exe
)

:: Compile installer
ahk2exe /in .\src\RegInstaller.ahk /out .\build\RegInstaller.exe
ahk2exe /in .\src\RegUninstaller.ahk /out .\build\RegUninstaller.exe
echo .\RegInstaller.exe --debug > .\build\RegInstallerDebug.bat

:: "dist" folder to contain distributing files
if not exist .\dist (
  mkdir dist
)

:: Make zip
if exist "%PROGRAMFILES(X86)%" (
  tar.exe -C .\build -cf .\dist\SandboxieShortcutCreator_x64_%VERSION%.zip SandboxieShortcutCreator.exe RegInstaller.exe RegUninstaller.exe
) else (
  tar.exe -C .\build -cf .\dist\SandboxieShortcutCreator_x86_%VERSION%.zip SandboxieShortcutCreator.exe RegInstaller.exe RegUninstaller.exe
)


echo Build completed.
