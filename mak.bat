@echo off
echo version: 0.0.1-dev

set SCRIPTPACKER="script\packer.ps1"
set SCRIPTDOWNLOAD="script\downloader.ps1"
set EMULATOR="build\visualboyadvance\visualboyadvance-m.exe"
set OUTPUT="dist\%game-title%.exe"

if "%1" == "--help" goto :help
if "%1" == "clean" goto :clean


:init
if not exist dist md dist
if not exist build md build
powershell -ExecutionPolicy Bypass -File %SCRIPTDOWNLOAD%
goto :main

:clean
echo -----
echo clean
echo -----
echo remove build folder
if exist build rd /s /q build

echo remove dist folder
if exist dist rd /s /q dist
goto :end

:build
echo -----
echo build
echo -----

powershell -ExecutionPolicy Bypass -File %SCRIPTPACKER% %2 %3 %4
goto :end

:help
echo help
goto :end

:main
if "%1" == "build" goto :build
if "%1" == "" goto :help
goto :end

:end
