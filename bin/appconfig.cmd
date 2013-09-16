@ECHO OFF
Set appdir=%~dp0
IF NOT "%~f0" == "~f0" GOTO :WinNT
@ruby "%appdir%appconfig" %1 %2 %3 %4 %5 %6 %7 %8 %9
GOTO :EOF
:WinNT
@ruby "%appdir%appconfig" %*
popd