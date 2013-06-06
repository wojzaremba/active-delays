@echo off

setlocal

set MOSEKBINPATH=%~d0%~p0
set PYTHONBASE=%MOSEKBINPATH..\python\2

if "%MOSEKLM_LICENSE_FILE%" EQU "" (set "MOSEKLM_LICENSE_FILE=%MOSEKBINPATH%..\..\..\..\licenses\mosek.lic")
set PYTHONPATH=%PYTHONBASE%
set PATH=%PATH%;%MOSEKBINPATH%

set PYTHON=%MOSEKBINPATH%..\python-2.6.2\python.exe

"%PYTHON%" "%MOSEKBINPATH%\moseki.py" %*
endlocal
echo on
