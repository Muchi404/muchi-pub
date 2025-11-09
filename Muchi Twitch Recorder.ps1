# Set console colors
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.UI.RawUI.ForegroundColor = "White"
Clear-Host

# Paths
$BasePath = Join-Path $env:SystemDrive "Program Files\Twitch Recorder"
$MotherFolder = Join-Path $BasePath "DONT DELETE"
$RootPath = Join-Path $BasePath "Streamers"

if (-not (Test-Path $MotherFolder)) { throw "Mother folder not found: $MotherFolder" }

# --- Function to create streamer folder and config ---
Function Setup-StreamerFolder {
    param($StreamerName)

    $NewFolder = Join-Path $RootPath $StreamerName

    if (-not (Test-Path $NewFolder)) {
        New-Item -Path $NewFolder -ItemType Directory | Out-Null
        Write-Host "$StreamerName folder created" -ForegroundColor Green
    } else {
        Write-Host "$StreamerName folder selected" -ForegroundColor Yellow
    }

    # Copy base files (no log file)
    $FilesToCopy = @(".gitignore", "LICENSE", "README.md", "twitch-recorder.py")
    foreach ($File in $FilesToCopy) {
        Copy-Item -Path (Join-Path $MotherFolder $File) -Destination $NewFolder -Force
    }

    # Update config.py with streamer
    $MotherConfig = Join-Path $MotherFolder "config.py"
    $NewConfig = Join-Path $NewFolder "config.py"
    $ConfigContent = Get-Content $MotherConfig -Raw
    $ConfigContent = $ConfigContent -replace 'username\s*=\s*".*?"', "username = `"$StreamerName`""
    Set-Content -Path $NewConfig -Value $ConfigContent -Encoding UTF8

    return $NewFolder
}

# --- Function to run twitch-recorder.py ---
Function Run-Recorder {
    param($Folder)
    Write-Host "Starting Twitch recorder..." -ForegroundColor Cyan
    & python "$Folder\twitch-recorder.py"
    Write-Host "Twitch recorder finished." -ForegroundColor Green
}

# --- Main loop ---
Do {
    Clear-Host
    $StreamerName = Read-Host "Enter Streamer Name (or Q to quit)"
    if ($StreamerName.ToUpper() -eq "Q") { break }

    Clear-Host
    $NewFolder = Setup-StreamerFolder -StreamerName $StreamerName
    Run-Recorder -Folder $NewFolder

    Write-Host "`nDone. Press any key to search another streamer or Q to quit." -ForegroundColor White
    $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").Character
    if ($key.ToUpper() -eq "Q") { break }

} While ($true)
