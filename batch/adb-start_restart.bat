@echo off
adb kill-server
adb start-server
adb tcpip 5555
adb connect 192.168.1.21
timeout 5