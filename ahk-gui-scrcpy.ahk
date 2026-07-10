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
    FileAppend, `n, %ps1Path%
    FileAppend, Write-Host "Closing scrcpy and ADB to unlock files..."`n, %ps1Path%
    FileAppend, # Kill scrcpy and adb so files can be overwritten`n, %ps1Path%
    FileAppend, Stop-Process -Force -Name scrcpy -ErrorAction SilentlyContinue`n, %ps1Path%
    FileAppend, Stop-Process -Force -Name adb -ErrorAction SilentlyContinue`n, %ps1Path%
    FileAppend, `n, %ps1Path%
    FileAppend, # Give the system a second to fully release the file locks`n, %ps1Path%
    FileAppend, Start-Sleep -Seconds 1`n, %ps1Path%
    FileAppend, `n, %ps1Path%
    FileAppend, # 1. Get the version tag by checking where the "latest" link redirects`n, %ps1Path%
    FileAppend, $url = "https://github.com/$repo/releases/latest"`n, %ps1Path%
    FileAppend, try {`n, %ps1Path%
    FileAppend,     $request = Invoke-WebRequest -Uri $url -MaximumRedirection 5 -UserAgent "Mozilla/5.0"`n, %ps1Path%
    FileAppend,     $finalUri = $request.BaseResponse.ResponseUri.ToString()`n, %ps1Path%
    FileAppend,     `n, %ps1Path%
    FileAppend,     # Extract the tag (e.g., v2.4) from the URL`n, %ps1Path%
    FileAppend,     $tag = $finalUri.Split('/')[-1]`n, %ps1Path%
    FileAppend,     `n, %ps1Path%
    FileAppend,     if (-not $tag) { throw "Could not determine version tag." }`n, %ps1Path%
    FileAppend,     `n, %ps1Path%
    FileAppend,     # 2. Construct the download URL manually to bypass API limits`n, %ps1Path%
    FileAppend,     $zipFileName = "scrcpy-win64-$tag.zip"`n, %ps1Path%
    FileAppend,     $downloadUrl = "https://github.com/$repo/releases/download/$tag/$zipFileName"`n, %ps1Path%
    FileAppend,     $zipFilePath = Join-Path -Path $path -ChildPath $zipFileName`n, %ps1Path%
    FileAppend, `n, %ps1Path%
    FileAppend,     Write-Host "Detected latest version: $tag"`n, %ps1Path%
    FileAppend,     Write-Host "Downloading: $zipFileName"`n, %ps1Path%
    FileAppend, `n, %ps1Path%
    FileAppend,     # 3. Download the file`n, %ps1Path%
    FileAppend,     Invoke-WebRequest -Uri $downloadUrl -OutFile $zipFilePath -UserAgent "Mozilla/5.0"`n, %ps1Path%
    FileAppend, `n, %ps1Path%
    FileAppend,     # 4. Extraction`n, %ps1Path%
    FileAppend,     if (-not (Test-Path -Path $tempExtractPath)) { New-Item -ItemType Directory -Path $tempExtractPath | Out-Null }`n, %ps1Path%
    FileAppend,     Expand-Archive -Path $zipFilePath -DestinationPath $tempExtractPath -Force`n, %ps1Path%
    FileAppend, `n, %ps1Path%
    FileAppend,     # 5. Move files`n, %ps1Path%
    FileAppend,     # The zip contains a folder like "scrcpy-win64-v2.4", we find that folder first`n, %ps1Path%
    FileAppend,     $versionedFolder = Get-ChildItem -Path $tempExtractPath -Directory | Where-Object { $_.Name -match "scrcpy-win64" }`n, %ps1Path%
    FileAppend,     `n, %ps1Path%
    FileAppend,     if ($versionedFolder) {`n, %ps1Path%
    FileAppend,         $sourceFolder = $versionedFolder.FullName`n, %ps1Path%
    FileAppend,         Write-Host "Updating files in $path..."`n, %ps1Path%
    FileAppend,         # Move-Item -Force will overwrite existing files`n, %ps1Path%
    FileAppend,         Get-ChildItem -Path $sourceFolder | Move-Item -Destination $path -Force`n, %ps1Path%
    FileAppend,     }`n, %ps1Path%
    FileAppend, `n, %ps1Path%
    FileAppend,     # 6. Cleanup`n, %ps1Path%
    FileAppend,     Remove-Item -Path $tempExtractPath -Recurse -Force`n, %ps1Path%
    FileAppend,     Remove-Item -Path $zipFilePath -Force`n, %ps1Path%
    FileAppend,     `n, %ps1Path%
    FileAppend,     Write-Host "Successfully updated to $tag and restarted ADB environment." -ForegroundColor Green`n, %ps1Path%
    FileAppend, `n, %ps1Path%
    FileAppend, } catch {`n, %ps1Path%
    FileAppend,     Write-Error "Failed to update: $($_.Exception.Message)"`n, %ps1Path%
    FileAppend, }`n, %ps1Path%
    FileAppend, `n, %ps1Path%
    FileAppend, pause`n, %ps1Path%
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
    FileAppend, setlocal enabledelayedexpansion`n, %bat6%
    FileAppend, echo.`n, %bat6%
    FileAppend, echo Checking versions (Bypassing API)...`n, %bat6%
    FileAppend, :: 1. Get the LATEST version tag from GitHub`n, %bat6%
    FileAppend, for /f "delims=" %pc%%pc%a in ('curl -Ls -o NUL -w %pc%%pc%{url_effective} https://github.com/Genymobile/scrcpy/releases/latest') do (`n, %bat6%
    FileAppend,     set "full_url=%pc%%pc%a"`n, %bat6%
    FileAppend,     for %pc%%pc%b in ("!full_url:/=" "!") do set "latest=%pc%%pc%~b"`n, %bat6%
    FileAppend, )`n, %bat6%
    FileAppend, :: 2. Get the CURRENT local version from the .exe`n, %bat6%
    FileAppend, set "current=Not Found"`n, %bat6%
    FileAppend, if exist "scrcpy.exe" (`n, %bat6%
    FileAppend,     for /f "tokens=2" %pc%%pc%v in ('scrcpy.exe -v 2^>nul ^| findstr /B "scrcpy"') do (`n, %bat6%
    FileAppend,         set "current=v%pc%%pc%v"`n, %bat6%
    FileAppend,     )`n, %bat6%
    FileAppend, )`n, %bat6%
    FileAppend, :: 3. Display Results`n, %bat6%
    FileAppend, echo.`n, %bat6%
    FileAppend, echo Latest release:  !latest!`n, %bat6%
    FileAppend, echo Current version: !current!`n, %bat6%
    FileAppend, echo.`n, %bat6%
    FileAppend, :: 4. Compare and Notify`n, %bat6%
    FileAppend, if "!latest!"=="!current!" (`n, %bat6%
    FileAppend,     echo [Status] You are up to date.`n, %bat6%
    FileAppend, ) else (`n, %bat6%
    FileAppend,     if "!current!"=="Not Found" (`n, %bat6%
    FileAppend,         echo [Status] scrcpy is not installed in this folder.`n, %bat6%
    FileAppend,     ) else (`n, %bat6%
    FileAppend,         echo [Status] Update available! Run your PowerShell update script.`n, %bat6%
    FileAppend,     )`n, %bat6%
    FileAppend, )`n, %bat6%
    FileAppend, echo.`n, %bat6%
    FileAppend, timeout /t 7`n, %bat6%
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

