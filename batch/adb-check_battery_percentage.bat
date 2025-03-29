@echo off
echo.
adb shell dumpsys battery | findstr /r /c:level
timeout 5