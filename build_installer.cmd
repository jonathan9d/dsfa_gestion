@echo off
REM ============================================================
REM  Construit l'application Windows puis genere l'installeur.
REM  Resultat : build\installer\DSFA_Gestion_Setup_1.2.0.exe
REM ============================================================
setlocal
cd /d "%~dp0"

echo [1/2] Build Flutter Windows (release)...
call flutter build windows --release
if errorlevel 1 (
  echo Echec du build Flutter.
  exit /b 1
)

echo.
echo [2/2] Generation de l'installeur (Inno Setup)...
set "ISCC=C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
if not exist "%ISCC%" (
  set "ISCC=iscc"
)
"%ISCC%" "installer\dsfa_gestion.iss"
if errorlevel 1 (
  echo Echec de la compilation de l'installeur. Inno Setup 6 est-il installe ?
  exit /b 1
)

echo.
echo Termine. Installeur : build\installer\DSFA_Gestion_Setup_1.2.0.exe
endlocal
