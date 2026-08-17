@echo off
setlocal
cd /d "%~dp0"
if not exist "%~dp0Fahrschul_Tracker_Windows.html" (
 echo Fehler: HTML-Datei fehlt. Bitte ZIP komplett entpacken.
 pause
 exit /b 1
)
start "" "%~dp0Fahrschul_Tracker_Windows.html"
