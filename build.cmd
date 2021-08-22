@echo off
setlocal
cd /D "%~dp0"

call build_config.cmd

if not exist ".\tmp\" mkdir ".\tmp"

"%NASM%\nasm.exe" -f obj -O0 -o ".\tmp\agi2.obj" ".\src\agi2.asm"
"%BIN%\wlink.exe" system dos name .\build\C\AGI2.EXE file .\tmp\agi2.obj

pause
