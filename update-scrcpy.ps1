$repo = "Genymobile/scrcpy"
$path = "$PSScriptRoot"
$tempExtractPath = Join-Path -Path $path -ChildPath "temp"
$apiUrl = "https://api.github.com/repos/$repo/releases/latest"

# Get the latest release info
$release = Invoke-RestMethod -Uri $apiUrl

# Find the Windows x64 zip file
$asset = $release.assets | Where-Object { $_.name -match "win64.*\.zip$" }

if ($asset -ne $null) {
    $downloadUrl = $asset.browser_download_url
    $zipFilePath = Join-Path -Path $path -ChildPath $asset.name

    # Download the file
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipFilePath

    # Ensure temp extract path exists
    if (-not (Test-Path -Path $tempExtractPath)) {
        New-Item -ItemType Directory -Path $tempExtractPath | Out-Null
    }

    # Extract the ZIP file to the temp folder
    Expand-Archive -Path $zipFilePath -DestinationPath $tempExtractPath -Force

    # Find the extracted "scrcpy-*" folder
    $versionedFolder = Get-ChildItem -Path $tempExtractPath -Directory | Where-Object { $_.Name -match "^scrcpy-" }

    if ($versionedFolder) {
        $sourceFolder = $versionedFolder.FullName

        # Move all extracted files to $path
        Get-ChildItem -Path $sourceFolder | Move-Item -Destination $path -Force
    }

    # Cleanup: Remove temp extracted folder and ZIP file
    Remove-Item -Path $tempExtractPath -Recurse -Force
    Remove-Item -Path $zipFilePath -Force
}