@echo off
echo set volume (adb)
echo 0 = muted
echo 8 = half
echo 15 = max
SET /P number= input number : 
adb shell cmd media_session volume --stream 3 --set %number%
