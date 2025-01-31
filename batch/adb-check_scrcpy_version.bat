@echo off

echo.
echo Latest release:

setlocal enabledelayedexpansion

set "repo=Genymobile/scrcpy"
set "apiUrl=https://api.github.com/repos/%repo%/releases/latest"

:: Download the latest release information from GitHub API
curl -s %apiUrl% > release_info.json

:: Extract the download URLs for Windows x64 ZIP files
for /f "tokens=*" %%i in ('findstr /i "win64" release_info.json') do (
    echo    %%i
)

:: Clean up the temporary JSON file
del release_info.json

endlocal

echo.
echo Current version:
for /f "delims=" %%i in ('scrcpy.exe -v') do (
    echo    %%i
    goto :end
)
:end
echo.

timeout 7