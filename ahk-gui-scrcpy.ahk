#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

Gui, +AlwaysOnTop 
title=

#SingleInstance, Force
Menu, Tray, MainWindow 
Menu, AppMenu2, Add, cmd, runCmd
Menu, AppMenu2, Add, terminate all`tCtrl+W, guiclose
Menu, AppMenu2, Add, open directory, runOpenDirectory
Menu, AppMenu2, Add, check current volume, runCheckCurrentVolume
Menu, AppMenu2, Add, check scrcpy version, runCheckScrcpyVersion
Menu, AppMenu2, Add, about, runAboutAhk

Menu, MyMenuBar, Add, &file, :Tray
Menu, MyMenuBar, Add, &things, :AppMenu2
Gui, Menu, MyMenuBar

Gui, Add, Checkbox, vMyVariable, Checkbox 0
GuiControl,, Myvariable, % "edit mode"
Gui, Add, Button, w157 gButton1, % "adb (start/restart)"
Gui, Add, Button, w157 gButton2, % "scrcpy (usb)"
Gui, Add, Button, w157 gButton3, % "scrcpy (tcp/ip)"
Gui, Add, Button, w157 gButton4, % "scrcpy (audio only)"
Gui, Add, Button, w111 gButton5, % "adb (set volume)"
Gui, Add, Button, w157 gButton6, % "adb (battery%)"
Gui, Add, Button, w38 y199 x10 gButtonPrevious, % "|<<" 
Gui, Add, Button, w38 y199 x69 gButtonPlayPause, % ">||"
Gui, Add, Button, w38 y199 x129 gButtonNext, % ">>|"

Gui, Add, Edit, w41 y142 x125 vMyEdit,
Gui, Add, UpDown, vMyUpDown Range0-15,

Gui, Show, xCenter x0, %title%
return

runCmd:
	run, cmd %A_ScriptDir%
	Return
	
runOpenDirectory:
	run, %A_ScriptDir%
	Return

runCheckCurrentVolume:
	run, "batch\adb-check_volume.bat"
	Return

runCheckScrcpyVersion:
	run, "batch\adb-check_scrcpy_version.bat"
	Return
	
runAboutAhk:
	MsgBox, test123
	Return

Button1:
	{
		GuiControlGet, Checked,,MyVariable
		if (checked == 0)
		{
			run,"batch\adb-start_restart.bat"
			return
		}
		else
		{
			run, notepad "batch\adb-start_restart.bat"
			return
		}
	}

Button2:
	{
		GuiControlGet, Checked,,MyVariable
		if (checked == 0)
		{
			run,"batch\scrcpy-usb.bat"
			return
		}
		else
		{
			run, notepad "batch\scrcpy-usb.bat"
			return
		}
	}

Button3:
	{
		GuiControlGet, Checked,,MyVariable
		if (checked == 0)
		{
			run,"batch\scrcpy-tcpip.bat"
			return
		}
		else
		{
			run, notepad "batch\scrcpy-tcpip.bat"
			return
		}
	}
	
Button4:
	{
		GuiControlGet, Checked,,MyVariable
		if (checked == 0)
		{
			run,"batch\scrcpy-audio.bat"
			return
		}
		else
		{
			run, notepad "batch\scrcpy-audio.bat"
			return
		}
	}

Button5:	
	{
		GuiControlGet, Checked,,MyVariable
		if (checked == 0)
		{
			Gui, Submit, NoHide
			run, adb shell cmd media_session volume --show --stream 3 --set %MyUpDown%
			return
		}
		else
		{
			return
		}
	}
	
Button6:
	{
		GuiControlGet, Checked,,MyVariable
		if (checked == 0)
		{
			run,"batch\adb-check_battery_percentage.bat"
			return
		}
		else
		{
			run, notepad "batch\adb-check_battery_percentage.bat"
			return
		}
	}

ButtonPrevious:
	{
		GuiControlGet, Checked,,MyVariable
		if (checked == 0)
		{
			run, adb shell cmd media_session dispatch previous
			Return
		}
		else
		{
			return
		}
	}
	

ButtonNext:
	{
		GuiControlGet, Checked,,MyVariable
		if (checked == 0)
		{
	run, adb shell cmd media_session dispatch next
	Return
			}
		else
		{
		return
		}
	}
	

ButtonPlayPause:
	{
		GuiControlGet, Checked,,MyVariable
		if (checked == 0)
		{
	run, adb shell input keyevent 85
	Return
			}
		else
		{
		return
		}
	}
	

return

guiclose:
	run, taskkill /f /im adb.exe
	run, taskkill /f /im scrcpy.exe
	ExitApp
	return