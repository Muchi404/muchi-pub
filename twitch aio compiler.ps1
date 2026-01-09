$ErrorActionPreference = 'Stop'

# =========================
# GLOBALS
# =========================
$Temp   = "C:\Windows\Temp"
$OutDir = "$env:USERPROFILE\Desktop\aio stream recorders"
# =========================
# PRECHECKS
# =========================
Function Check-Prerequisites {
    Write-Host "Checking prerequisites..." -ForegroundColor Cyan

    # --- Winget check ---
    $winget = Get-Command winget -ErrorAction SilentlyContinue
    if (-not $winget) {
        Write-Host "Winget is not installed or not available in PATH." -ForegroundColor Yellow
        Write-Host "Please install or update 'App Installer' via Microsoft Store: https://aka.ms/getwinget" -ForegroundColor Yellow
        throw "Winget is required for this script to proceed."
    }

    # --- PS2EXE check ---
    $ps2exe = Get-Command Invoke-PS2EXE -ErrorAction SilentlyContinue
    if (-not $ps2exe) {
        Write-Host "PS2EXE module not found. Installing..." -ForegroundColor Cyan
        try {
            Install-Module -Name PS2EXE -Scope CurrentUser -Force -AllowClobber
            Write-Host "PS2EXE installed successfully."
        } catch {
            throw "Failed to install PS2EXE: $($_.Exception.Message)"
        }
    } else {
        Write-Host "PS2EXE found."
    }

    # --- ImageMagick check ---
    $magick = Get-Command magick -ErrorAction SilentlyContinue
    if (-not $magick) {
        Write-Host "ImageMagick is not installed." -ForegroundColor Yellow
        Write-Host "You can install it via winget:" -ForegroundColor Yellow
        Write-Host "winget install ImageMagick.Q16" -ForegroundColor Yellow
        throw "ImageMagick is required for ICO conversion."
    } else {
        Write-Host "ImageMagick found."
    }

    Write-Host "All prerequisites OK." -ForegroundColor Green
	start-sleep 2
	Clear-Host
}
# =========================
Function Get-StreamerName {
    Read-Host "Twitch username"
}
# =========================
Function Save-StreamerScript {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Streamer
    )

    $TemplateUrl  = "https://raw.githubusercontent.com/Muchi404/muchi-pub/main/temp.ps1"
    $TargetFolder  = "C:\Program Files\Twitch Recorder"
    $TemplatePath  = Join-Path $TargetFolder "temp.ps1"
    $TempPs1Path   = Join-Path "C:\Windows\Temp" "$Streamer.ps1"

    # Ensure Program Files folder exists
    if (-not (Test-Path $TargetFolder)) {
        New-Item -Path $TargetFolder -ItemType Directory -Force | Out-Null
    }

    # Download template if it doesn't exist
    if (-not (Test-Path $TemplatePath)) {
        Write-Host "Downloading template PS1..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $TemplateUrl -OutFile $TemplatePath -UseBasicParsing -ErrorAction Stop
        Write-Host "Template saved to $TemplatePath" -ForegroundColor Green
    } else {
        Write-Host "Template already exists: $TemplatePath" -ForegroundColor Yellow
    }

    # Copy template to temp and replace streamer placeholder
    Copy-Item -Path $TemplatePath -Destination $TempPs1Path -Force
    $Content = Get-Content $TempPs1Path -Raw
    $Content = $Content -replace "REPLACEME", $Streamer
    Set-Content -Path $TempPs1Path -Value $Content -Encoding UTF8 -Force

    # Verify
    if (-not (Test-Path $TempPs1Path)) { throw "Failed to prepare PS1 for $Streamer" }

    Write-Host "Streamer PS1 ready: $TempPs1Path" -ForegroundColor Green
    return $TempPs1Path
}
# =========================
Function Download-StreamerPNG {
    param($Streamer)

    $PngPath = Join-Path $Temp "$Streamer.png"
    $ApiUrl  = "https://api.ivr.fi/v2/twitch/user?login=$Streamer"

    $UserData = Invoke-RestMethod -Uri $ApiUrl -Method GET
    $pfpUrl = $UserData.logo -replace '\d+x\d+', '70x70'

    Invoke-WebRequest -Uri $pfpUrl -OutFile $PngPath

    if (-not (Test-Path $PngPath)) { throw "PNG was not downloaded" }

    Write-Host "Downloaded Twitch PNG: $PngPath"
    return $PngPath
}
# =========================
Function Convert-PNGtoICO {
    param($PngPath, $Streamer)

    $IcoPath = Join-Path $Temp "$Streamer.ico"

    # Use ImageMagick (magick must be in PATH)
    & magick convert $PngPath -define icon:auto-resize=256,128,64,48,32,16 $IcoPath

    if (-not (Test-Path $IcoPath)) { throw "ICO conversion failed" }

    Write-Host "Converted ICO: $IcoPath"
    return $IcoPath
}
# =========================
Function Compile-StreamerExe {
    param($Streamer)

    $Ps1Path = Join-Path $Temp "$Streamer.ps1"
    $IcoPath = Join-Path $Temp "$Streamer.ico"
    $ExePath = Join-Path $Temp "$Streamer.exe"
    $CompilerPath = Join-Path $Temp "compiler.ps1"
    $LogPath = Join-Path $Temp "ps2exe.log"

    if (-not (Test-Path $Ps1Path)) { throw "PS1 missing" }
    if (-not (Test-Path $IcoPath)) { throw "ICO missing" }

    # Create compiler script
    $CompilerScript = "Invoke-PS2EXE `"$Ps1Path`" `"$ExePath`" -icon `"$IcoPath`" -Version `"1.0.0`" -copyright `"Muchi @ muchi.online`""
    Set-Content -Path $CompilerPath -Value $CompilerScript -Encoding UTF8 -Force

    if (-not (Test-Path $CompilerPath)) { throw "compiler.ps1 was not created" }

    # Run compiler
    Push-Location $Temp
    & powershell -ExecutionPolicy Bypass -File $CompilerPath *> $LogPath
    Pop-Location

    if (-not (Test-Path $ExePath)) {
        Write-Host "---- PS2EXE OUTPUT ----" -ForegroundColor Yellow
        Get-Content $LogPath
        throw "EXE was not created"
    }

    Write-Host "EXE compiled: $ExePath"
    return $ExePath
}
# =========================
Function Move-FinalExe {
    param($ExePath)

    if (-not (Test-Path $OutDir)) {
        New-Item -ItemType Directory -Path $OutDir | Out-Null
    }

    Move-Item -Path $ExePath -Destination $OutDir -Force
    Write-Host "Moved EXE to: $OutDir"
}
# =========================
Function Clear-WindowsTemp {
    Write-Host "Cleaning up" -ForegroundColor Cyan

    $TempPath = "C:\Windows\Temp"

    Get-ChildItem -Path $TempPath -Force -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
        try {
            if ($_.PSIsContainer) {
                Remove-Item $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
            } else {
                Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
            }
        } catch {
            # Ignore errors for files in use
        }
    }

    Write-Host "Clean up successful!" -ForegroundColor Green
}

# =========================
Function Run-Compiler {
    try {
		Check-Prerequisites
        $Streamer = Get-StreamerName
        if (-not $Streamer) { throw "No streamer name provided" }

        $Ps1Path = Save-StreamerScript -Streamer $Streamer
        $PngPath = Download-StreamerPNG -Streamer $Streamer
        $IcoPath = Convert-PNGtoICO -PngPath $PngPath -Streamer $Streamer
        $ExePath = Compile-StreamerExe -Streamer $Streamer
        Move-FinalExe -ExePath $ExePath
		Clear-WindowsTemp

        Write-Host "All done!" -ForegroundColor Green
    } catch {
        Write-Host "FAILED: $($_.Exception.Message)" -ForegroundColor Red
    }
}
# =========================
Run-Compiler
