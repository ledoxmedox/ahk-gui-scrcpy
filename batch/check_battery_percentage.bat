@echo off
adb connect 192.168.1.98
adb shell dumpsys battery | findstr /r /c:level
timeout 5