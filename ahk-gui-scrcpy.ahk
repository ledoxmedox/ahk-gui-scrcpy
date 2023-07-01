#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

Gui, +AlwaysOnTop 

title= 

#SingleInstance, Force
Menu, Tray, MainWindow 
Menu, AppMenu2, Add, @cmd, run1
Menu, AppMenu2, Add, Close All`tCtrl+W, run2
Menu, AppMenu2, Add, Shortcuts, run3
Menu, AppMenu2, Add, Edit this ahk, run4
Menu, AppMenu2, Add, Open Directory, run5
Menu, AppMenu2, Add, About, run99
Menu, MyMenuBar, Add, &File, :Tray
Menu, MyMenuBar, Add, &?, :AppMenu2

Gui, Menu, MyMenuBar
Gui, Add, Checkbox, vMyVariable, Checkbox  0
GuiControl,, Myvariable, edit mode
Gui, Add, Button, w170 gButton1, adb (start/restart)
Gui, Add, Button, w170 gButton2, scrcpy (usb)
Gui, Add, Button, w170 gButton3, scrcpy (tcp/ip)
Gui, Add, Button, w170 gButton4, scrcpy (audio only)
Gui, Add, Button, w170 gButton7, adb (set volume)
Gui, Add, Button, w170 gButton8, adb (battery percentage)
Gui, Add, Text, w170 h30 Center gMove, click here to drag
Gui, Show, xCenter x0, %title%
return

Move:
	PostMessage, 0xA1, 2,,, A 
	Return

run1:
	run, cmd %A_ScriptDir%
	Return

run2:
	run, taskkill /f /im adb.exe
	run, taskkill /f /im scrcpy.exe
	ExitApp
	Return
	
run3:
	run, "https://github.com/Genymobile/scrcpy/blob/master/doc/shortcuts.md"
	Return
	
run4:
	run, notepad %A_ScriptName%
	Return
	
run5:
	run, %A_ScriptDir%
	Return
	
run99:
	MsgBox, hi 
	Return

Button1:
	{
		GuiControlGet, Checked,,MyVariable
		if (checked == 0)
		{
			run,"batch\start_restart_adb.bat"
			return
		}
		else
		{
			run, notepad "batch\start_restart_adb.bat"
			return
		}
	}

Button2:
	{
		GuiControlGet, Checked,,MyVariable
		if (checked == 0)
		{
			run,"batch\scrcpy_usb.bat"
			return
		}
		else
		{
			run, notepad "batch\scrcpy_usb.bat"
			return
		}
	}

Button3:
	{
		GuiControlGet, Checked,,MyVariable
		if (checked == 0)
		{
			run,"batch\scrcpy_tcpip.bat"
			return
		}
		else
		{
			run, notepad "batch\scrcpy_tcpip.bat"
			return
		}
	}
	
Button4:
	{
		GuiControlGet, Checked,,MyVariable
		if (checked == 0)
		{
			run,"batch\scrcpy_audio.bat"
			return
		}
		else
		{
			run, notepad "batch\scrcpy_audio.bat"
			return
		}
	}

Button7:
	{
		GuiControlGet, Checked,,MyVariable
		if (checked == 0)
		{
			run,"batch\set_volume_adb.bat"
			return
		}
		else
		{
			run, notepad "batch\set_volume_adb.bat"
			return
		}
	}
	
Button8:
	{
		GuiControlGet, Checked,,MyVariable
		if (checked == 0)
		{
			run,"batch\check_battery_percentage.bat"
			return
		}
		else
		{
			run, notepad "batch\check_battery_percentage.bat"
			return
		}
	}

return

guiclose:
	run, taskkill /f /im adb.exe
	run, taskkill /f /im scrcpy.exe
	ExitApp
	return