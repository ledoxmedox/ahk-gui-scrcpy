@echo off
adb kill-server
adb start-server
adb tcpip 5555
adb connect %1%
timeout 5