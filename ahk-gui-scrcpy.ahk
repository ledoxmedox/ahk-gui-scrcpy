#NoTrayIcon
#NoEnv
#SingleInstance, Force
SetWorkingDir %A_ScriptDir%

; Auto download if scrcpy not exist
if !FileExist("scrcpy.exe")
{
    Run, powershell -ExecutionPolicy Bypass -file "update-scrcpy.ps1"
}

; Define a percent sign variable to prevent AHK errors
pc := "%"

; 1. Define paths
dirPath = %A_ScriptDir%\batch
ps1Path = %A_ScriptDir%\update-scrcpy.ps1
bat1 = %dirPath%\adb-unlock_wireless.bat
bat2 = %dirPath%\adb-unlock.bat
bat3 = %dirPath%\adb-check_battery_percentage_wireless.bat
bat4 = %dirPath%\adb-check_battery_percentage.bat
bat5 = %dirPath%\adb-check_volume.bat
bat6 = %dirPath%\adb-check_scrcpy_version.bat

; 2. Create the "batch" folder if it doesn't exist
if !FileExist(dirPath)
    FileCreateDir, %dirPath%

; 3. Create the .ps1 file
if !FileExist(ps1Path)
{
    FileAppend, $repo = "Genymobile/scrcpy"`n, %ps1Path%
    FileAppend, $path = "$PSScriptRoot"`n, %ps1Path%
    FileAppend, $tempExtractPath = Join-Path -Path $path -ChildPath "temp"`n, %ps1Path%
    FileAppend, $apiUrl = "https://api.github.com/repos/$repo/releases/latest"`n, %ps1Path%
    FileAppend, Stop-Process -Force -Name scrcpy -ErrorAction SilentlyContinue`n, %ps1Path%
    FileAppend, $release = Invoke-RestMethod -Uri $apiUrl`n, %ps1Path%
    FileAppend, $asset = $release.assets | Where-Object { $_.name -match "win64.*\.zip$" }`n, %ps1Path%
    FileAppend, if ($asset -ne $null) {`n, %ps1Path%
    FileAppend,     $downloadUrl = $asset.browser_download_url`n, %ps1Path%
    FileAppend,     $zipFilePath = Join-Path -Path $path -ChildPath $asset.name`n, %ps1Path%
    FileAppend,     Invoke-WebRequest -Uri $downloadUrl -OutFile $zipFilePath`n, %ps1Path%
    FileAppend,     if (-not (Test-Path -Path $tempExtractPath)) { New-Item -ItemType Directory -Path $tempExtractPath | Out-Null }`n, %ps1Path%
    FileAppend,     Expand-Archive -Path $zipFilePath -DestinationPath $tempExtractPath -Force`n, %ps1Path%
    FileAppend,     $versionedFolder = Get-ChildItem -Path $tempExtractPath -Directory | Where-Object { $_.Name -match "^scrcpy-" }`n, %ps1Path%
    FileAppend,     if ($versionedFolder) {`n, %ps1Path%
    FileAppend,         $sourceFolder = $versionedFolder.FullName`n, %ps1Path%
    FileAppend,         Get-ChildItem -Path $sourceFolder | Move-Item -Destination $path -Force`n, %ps1Path%
    FileAppend,     }`n, %ps1Path%
    FileAppend,     Remove-Item -Path $tempExtractPath -Recurse -Force`n, %ps1Path%
    FileAppend,     Remove-Item -Path $zipFilePath -Force`n, %ps1Path%
    FileAppend, }`n, %ps1Path%
}

; 4. Create Batch Files
if !FileExist(bat1)
    FileAppend, adb -s %pc%1 shell "sleep 0.5; input swipe 500 1250 500 500 50; sleep 0.5; input text ''; input keyevent 66"`n, %bat1%

if !FileExist(bat2)
    FileAppend, adb shell "input keyevent 26; sleep 0.5; input swipe 500 1250 500 500 50; sleep 0.5; input text ''; input keyevent 66"`n, %bat2%

if !FileExist(bat3)
{
    FileAppend, @echo off`n, %bat3%
    FileAppend, echo.`n, %bat3%
    FileAppend, adb -s %pc%1 shell dumpsys battery | findstr /r /c:level`n, %bat3%
    FileAppend, timeout 5`n, %bat3%
}

if !FileExist(bat4)
{
    FileAppend, @echo off`n, %bat4%
    FileAppend, echo.`n, %bat4%
    FileAppend, adb shell dumpsys battery | findstr /r /c:level`n, %bat4%
    FileAppend, timeout 5`n, %bat4%
}

if !FileExist(bat5)
{
    FileAppend, @echo off`n, %bat5%
    FileAppend, adb shell cmd media_session volume --get`n, %bat5%
    FileAppend, timeout 5`n, %bat5%
}

if !FileExist(bat6)
{
    FileAppend, @echo off`n, %bat6%
    FileAppend, echo.`n, %bat6%
    FileAppend, echo Latest release:`n, %bat6%
    FileAppend, setlocal enabledelayedexpansion`n, %bat6%
    FileAppend, set "repo=Genymobile/scrcpy"`n, %bat6%
    FileAppend, set "apiUrl=https://api.github.com/repos/%pc%repo%pc%/releases/latest"`n, %bat6%
    FileAppend, curl -s %pc%apiUrl%pc% > release_info.json`n, %bat6%
    FileAppend, for /f "tokens=*" %pc%%pc%i in ('findstr /i "win64" release_info.json') do (`n, %bat6%
    FileAppend,     echo    %pc%%pc%i`n, %bat6%
    FileAppend, )`n, %bat6%
    FileAppend, del release_info.json`n, %bat6%
    FileAppend, endlocal`n, %bat6%
    FileAppend, echo.`n, %bat6%
    FileAppend, echo Current version:`n, %bat6%
    FileAppend, for /f "delims=" %pc%%pc%i in ('scrcpy.exe -v') do (`n, %bat6%
    FileAppend,     echo    %pc%%pc%i`n, %bat6%
    FileAppend,     goto :end`n, %bat6%
    FileAppend, )`n, %bat6%
    FileAppend, :end`n, %bat6%
    FileAppend, echo.`n, %bat6%
    FileAppend, timeout 7`n, %bat6%
}

IniFile := A_ScriptDir . "\settings.ini"

; Create .ini file if file doesn't exist
if !FileExist(IniFile)
{
    IniWrite, 192.168.1.21, %IniFile%, Settings, DeviceIP
    IniWrite, 0, %IniFile%, Settings, WirelessMode
    IniWrite, 0, %IniFile%, Settings, AudioToggle
    IniWrite, "--no-power-on --power-off-on-close", %IniFile%, Settings, WiredCommandLine
    IniWrite, "--no-power-on --power-off-on-close --no-mouse-hover --video-buffer=30 --audio-output-buffer=30 --video-bit-rate=6M --max-size=1280 --max-fps=60", %IniFile%, Settings, WirelessCommandLine
}

; Now safely read the values (they will use defaults only if key is missing)
IniRead, SavedIP, %IniFile%, Settings, DeviceIP, 192.168.1.21
IniRead, SavedWirelessMode, %IniFile%, Settings, WirelessMode, 0
IniRead, SavedAudioToggle, %IniFile%, Settings, AudioToggle, 1
IniRead, SavedWiredArgs, %IniFile%, Settings, WiredCommandLine, --no-power-on --power-off-on-close
IniRead, SavedWirelessArgs, %IniFile%, Settings, WirelessCommandLine, --no-power-on --power-off-on-close

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

Gui, Add, Checkbox, x10 vEditMode, Checkbox 0
GuiControl,, EditMode, % "Edit Mode"

Gui, Add, Edit, x40  w101 vDeviceIP, %SavedIP%

Gui, Add, Checkbox, x56 w66 vWirelessMode Checked%SavedWirelessMode%,
GuiControl,, WirelessMode, % "Wireless"

Gui, Add, Checkbox, x56 w66 vAudioToggle Checked%SavedAudioToggle%, Audio On
GuiControl,, AudioToggle, % "Audio"

Gui, Add, Button, x10 w157 gButton2, % "scrcpy"
Gui, Add, Button, x10 w157 gButton3, % "adb (unlock)"
Gui, Add, Button, x10 w157 gButton5, % "adb (battery%)"
Gui, Add, Button, x10 w111 gButton6, % "adb (set volume)"
Gui, Add, Button, w38 y211 x10 gButtonPrevious, % "|<<" 
Gui, Add, Button, w38 y211 x69 gButtonPlayPause, % ">||"
Gui, Add, Button, w38 y211 x127 gButtonNext, % ">>|"
Gui, Add, Edit, w41 y178 x124 vMyEdit,
Gui, Add, UpDown, vMyUpDown Range0-15,

Gui, Show, xCenter x0, %title%
return
	
runCmd:
	{
		GuiControlGet, Checked,,EditMode
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
		GuiControlGet, Checked,,EditMode
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
		GuiControlGet, Checked,,EditMode
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
		GuiControlGet, Checked,,EditMode
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
		GuiControlGet, Checked,,EditMode
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
		GuiControlGet, Checked,,EditMode
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
		GuiControlGet, Checked,,EditMode
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

Button2:
    Gui, Submit, NoHide

    ; Re-read args from INI in case user edited settings.ini manually
    IniRead, WiredArgs, %IniFile%, Settings, WiredCommandLine, --no-power-on --power-off-on-close
    IniRead, WirelessArgs, %IniFile%, Settings, WirelessCommandLine, --no-power-on --power-off-on-close

    ; Save current GUI settings
    IniWrite, %DeviceIP%, %IniFile%, Settings, DeviceIP
    IniWrite, %WirelessMode%, %IniFile%, Settings, WirelessMode
    IniWrite, %AudioToggle%, %IniFile%, Settings, AudioToggle

    if (EditMode = 1) {
        Run, notepad "settings.ini"
        return
    }

    ; Build command
    if (WirelessMode = 1) {
        if (DeviceIP = "") {
            MsgBox, 48, Error, Please enter a Device IP for wireless mode!
            return
        }
		cmd := "adb tcpip 5555"
        cmd := "scrcpy --tcpip=" . DeviceIP . " " . WirelessArgs
    } else {
        cmd := "scrcpy " . WiredArgs
    }

    ; Audio toggle
    if (AudioToggle = 0) {
        cmd .= " --no-audio"
    }

	RunWait, taskkill /f /im scrcpy.exe
    Run, %cmd%
return

Button3:
    Gui, Submit, NoHide
    if (WirelessMode = 1) {
        batchFile := "batch\adb-unlock_wireless.bat"
    } else {
        batchFile := "batch\adb-unlock.bat"
    }

    if (EditMode = 1) {
        Run, notepad %batchFile%
    } else {
        IniWrite, %DeviceIP%, %IniFile%, Settings, DeviceIP
        Run, %batchFile% "%DeviceIP%"
    }
return
	
Button5:
    Gui, Submit, NoHide
    if (WirelessMode = 1) {
        batchFile := "batch\adb-check_battery_percentage_wireless.bat"
    } else {
        batchFile := "batch\adb-check_battery_percentage.bat"
    }

    if (EditMode = 1) {
        Run, notepad %batchFile%
    } else {
        IniWrite, %DeviceIP%, %IniFile%, Settings, DeviceIP
        Run, %batchFile% "%DeviceIP%"
    }
return
	
Button6:
	{
		GuiControlGet, Checked,,EditMode
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
	
ButtonPrevious:
	{
		GuiControlGet, Checked,,EditMode
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
		GuiControlGet, Checked,,EditMode
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
		GuiControlGet, Checked,,EditMode
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
	IniWrite, %WirelessMode%, %IniFile%, Settings, WirelessMode
	IniWrite, %AudioToggle%, %IniFile%, Settings, AudioToggle
	run, taskkill /f /im adb.exe
	run, taskkill /f /im scrcpy.exe
	ExitApp
	return

