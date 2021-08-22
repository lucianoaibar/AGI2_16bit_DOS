@echo off
setlocal

cd /D "%~dp0build"
start dosbox.exe -noconsole
cd /D "%~dp0"
