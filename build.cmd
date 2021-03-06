@echo off
setlocal
cd /D "%~dp0"
cls

call build_config.cmd

if not exist ".\tmp\" mkdir ".\tmp"

echo ------------------------------------------------------------------------------
"%NASM%\nasm.exe" -f obj -O0 -o ".\tmp\main.obj" ".\src\main.asm"

rem echo ------------------------------------------------------------------------------
"%BIN%\wcc.exe" -2 -bc -d0 -ecc -ms -s -fo=.\tmp\functions.obj .\src\functions.c

echo ------------------------------------------------------------------------------
"%BIN%\wlink.exe" system dos name .\build\C\AGI2.EXE file .\tmp\main.obj file .\tmp\functions.obj

pause
