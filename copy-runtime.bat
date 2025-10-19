@echo off
rem copy-runtime.bat — validate and copy FMOD / vcpkg runtime DLLs into the exe dir
rem Usage: run from repository root or build folder

setlocal

rem Resolve project root from script location
set SCRIPT_DIR=%~dp0
if "%SCRIPT_DIR:~-1%"=="\" set SCRIPT_DIR=%SCRIPT_DIR:~0,-1%
set PROJECT_ROOT=%SCRIPT_DIR%

rem Default paths (adjust if your layout differs)
set BUILD_DIR=%PROJECT_ROOT%\build
set FMOD_BIN=%BUILD_DIR%\src\fmod\api\bin\x64
set VCPKG_BIN=C:\vcpkg\installed\x64-windows\bin

rem Find zandronum.exe under build
for /f "delims=" %%I in ('where /R "%BUILD_DIR%" zandronum.exe 2^>nul') do set EXE_PATH=%%I
if not defined EXE_PATH (
  echo ERROR: zandronum.exe not found under %BUILD_DIR%.
  echo Run the build first and then re-run this script.
  exit /b 1
)

for %%I in ("%EXE_PATH%") do set EXE_DIR=%%~dpI

echo EXE_DIR=%EXE_DIR%
echo FMOD_BIN=%FMOD_BIN%
echo VCPKG_BIN=%VCPKG_BIN%

rem Copy FMOD runtime DLLs if present
if exist "%FMOD_BIN%\fmodex64.dll" (
  echo Copying fmodex64.dll
  copy /Y "%FMOD_BIN%\fmodex64.dll" "%EXE_DIR%" >nul
) else (
  echo Warning: fmodex64.dll not found in %FMOD_BIN%. Place FMOD Ex 4.44.64 runtime DLLs there.
)

if exist "%FMOD_BIN%\fmodexL64.dll" (
  echo Copying fmodexL64.dll
  copy /Y "%FMOD_BIN%\fmodexL64.dll" "%EXE_DIR%" >nul
) else (
  echo Note: fmodexL64.dll not found (lite/debug variant).
)

rem Copy Fluidsynth runtime DLL
if exist "%VCPKG_BIN%\libfluidsynth-3.dll" (
  echo Copying libfluidsynth-3.dll
  copy /Y "%VCPKG_BIN%\libfluidsynth-3.dll" "%EXE_DIR%" >nul
) else (
  echo Warning: libfluidsynth-3.dll not found in %VCPKG_BIN%. Install fluidsynth via vcpkg or adjust VCPKG_BIN.
)

rem Copy sqlite3.dll if present
if exist "%VCPKG_BIN%\sqlite3.dll" (
  echo Copying sqlite3.dll
  copy /Y "%VCPKG_BIN%\sqlite3.dll" "%EXE_DIR%" >nul
) else (
  echo Warning: sqlite3.dll not found in %VCPKG_BIN%.
)

echo Done. Run: "%EXE_DIR%zandronum.exe -logfile console"
endlocal
