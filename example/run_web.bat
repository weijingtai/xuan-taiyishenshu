@echo off
REM Launch the example app in Chrome with a persistent user-data-dir.
REM This ensures OPFS/IndexedDB storage survives browser restarts,
REM so API keys and other user data are retained.
REM
REM Usage:
REM   run_web.bat                  default port 7357
REM   run_web.bat 8080             custom port

setlocal

set PORT=7357
if not "%~1"=="" set PORT=%~1

set SCRIPT_DIR=%~dp0
set PROFILE_DIR=%SCRIPT_DIR%\.chrome-profile

cd /d "%SCRIPT_DIR%"

flutter run -d chrome --web-port=%PORT% --web-browser-flag="--user-data-dir=%PROFILE_DIR%" --web-browser-flag="--disable-web-security"
