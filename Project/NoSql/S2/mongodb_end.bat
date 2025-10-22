@echo off
echo ==========================================
echo Stopping all MongoDB processes
echo ==========================================
taskkill /f /im mongod.exe >nul 2>&1
taskkill /f /im mongos.exe >nul 2>&1
echo All MongoDB instances stopped.
pause
