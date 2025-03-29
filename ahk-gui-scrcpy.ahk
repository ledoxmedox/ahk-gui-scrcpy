#NoTrayIcon
#SingleInstance, Force

IniFile := A_ScriptDir . "\settings.ini"
IniRead, SavedIP, %IniFile%, Settings, DeviceIP, 

Gui, +AlwaysOnTop
title=

Menu, Tray, MainWindow 
Menu, AppMenu2, Add, cmd, runCmd
Menu, AppMenu2, Add, terminate all`tCtrl+W, runTerminateAll
Menu, AppMenu2, Add, open directory, runOpenDirectory
Menu, AppMenu2, Add, install/update latest scrcpy, runUpdateScrcpy
Menu, AppMenu2, Add, check current volume, runCheckCurrentVolume
Menu, AppMenu2, Add, check scrcpy version, runCheckScrcpyVersion
Menu, AppMenu2, Add, about, runAboutAhk

Menu, MyMenuBar, Add, &file, :Tray
Menu, MyMenuBar, Add, &things, :AppMenu2
Gui, Menu, MyMenuBar

Gui, Add, Checkbox, x10 vMyVariable, Checkbox 0
GuiControl,, Myvariable, % "edit mode"

Gui, Add, Edit, x10 w157 vDeviceIP, %SavedIP%
Gui, Add, Button, x10 w157 gButton1, % "adb (start/restart)"
Gui, Add, Button, x10 w157 gButton2, % "scrcpy (usb)"
Gui, Add, Button, x10 w157 gButton3, % "scrcpy (tcp/ip)"
Gui, Add, Button, x10 w157 gButton4, % "scrcpy (audio only)"
Gui, Add, Button, x10 w111 gButton5, % "adb (set volume)"
Gui, Add, Button, x10 w157 gButton6, % "adb (battery%)"
Gui, Add, Button, w38 y223 x10 gButtonPrevious, % "|<<" 
Gui, Add, Button, w38 y223 x69 gButtonPlayPause, % ">||"
Gui, Add, Button, w38 y223 x129 gButtonNext, % ">>|"
Gui, Add, Edit, w41 y169 x125 vMyEdit,
Gui, Add, UpDown, vMyUpDown Range0-15,

Gui, Show, xCenter x0, %title%
return
	
runCmd:
	{
		GuiControlGet, Checked,,MyVariable
		if (checked == 0)
		{
			run, cmd %A_ScriptDir%
			return
		}
		else
		{
			return
		}
	}
	
runTerminateAll:
	{
		GuiControlGet, Checked,,MyVariable
		if (checked == 0)
		{
			run, taskkill /f /im adb.exe
			run, taskkill /f /im scrcpy.exe
			ExitApp
			return
		}
		else
		{
			return
		}
	}

runOpenDirectory:
	{
		GuiControlGet, Checked,,MyVariable
		if (checked == 0)
		{
			run, %A_ScriptDir%
			return
		}
		else
		{
			return
		}
	}

runUpdateScrcpy:
	{
		GuiControlGet, Checked,,MyVariable
		if (checked == 0)
		{
			run, powershell -ExecutionPolicy Bypass -file "update-scrcpy.ps1"
			return
		}
		else
		{
			run, notepad "update-scrcpy.ps1"
			return
		}
	}
	
runCheckCurrentVolume:
	{
		GuiControlGet, Checked,,MyVariable
		if (checked == 0)
		{
			run, "batch\adb-check_volume.bat"
			return
		}
		else
		{
			run, notepad "batch\adb-check_volume.bat"
			return
		}
	}

runCheckScrcpyVersion:
	{
		GuiControlGet, Checked,,MyVariable
		if (checked == 0)
		{
			run, "batch\adb-check_scrcpy_version.bat"
			return
		}
		else
		{
			run, notepad "batch\adb-check_scrcpy_version.bat"
			return
		}
	}


runAboutAhk:
	{
		GuiControlGet, Checked,,MyVariable
		if (checked == 0)
		{
			MsgBox, test123
			return
		}
		else
		{
			return
		}
	}

Button1:
	{
		GuiControlGet, Checked,,MyVariable
		if (checked == 0)
		{
			Gui, Submit, NoHide
			IniWrite, %DeviceIP%, %IniFile%, Settings, DeviceIP
			Run, batch\adb-start_restart.bat %DeviceIP%
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
	Gui, Submit, NoHide
	IniWrite, %DeviceIP%, %IniFile%, Settings, DeviceIP
	run, taskkill /f /im adb.exe
	run, taskkill /f /im scrcpy.exe
	ExitApp
	return

