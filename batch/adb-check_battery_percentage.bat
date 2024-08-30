@echo off
adb connect 192.168.1.21
echo.
adb shell dumpsys battery | findstr /r /c:level
timeout 5