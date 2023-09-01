@echo off
echo version: 0.0.1-dev

set SCRIPTPACKER="script\packer.ps1"
echo %*
powershell -ExecutionPolicy Bypass -File %SCRIPTPACKER% %*
