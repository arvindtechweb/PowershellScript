@ECHO OFF
cls
:Password
echo If Ready to proceed
echo Please Enter password to activate program.
set/p "input=>"
if %input%==welcome goto YES

:NO
echo incorrect Password
Pause
goto Password

:YES
PowerShell.exe -Command "& '%~dpn0.ps1'"
PAUSE
