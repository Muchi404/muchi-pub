# Define URL and download target
$AioUrl = "https://github.com/abbodi1406/vcredist/releases/latest/download/VisualCppRedist_AIO_x86_x64.exe"
$TempDir = Join-Path $env:TEMP "VCRedistAIO_$(Get-Random)"
$InstallerName = "VisualCppRedist_AIO_x86_x64.exe"
$InstallerPath = Join-Path $TempDir $InstallerName

# Create temp folder
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

Write-Host "Downloading VisualCppRedist AIO from GitHub..." -ForegroundColor Cyan

function Download-With-BITS {
    try {
        Start-BitsTransfer -Source $AioUrl -Destination $InstallerPath -ErrorAction Stop
        return $true
    } catch {
        Write-Host "BITS download failed: $_" -ForegroundColor Yellow
        return $false
    }
}

function Download-With-InvokeWebRequest {
    try {
        Invoke-WebRequest -Uri $AioUrl -OutFile $InstallerPath -UseBasicParsing -TimeoutSec 300 -ErrorAction Stop
        return $true
    } catch {
        Write-Host "Invoke-WebRequest failed: $_" -ForegroundColor Red
        return $false
    }
}

# Attempt download using BITS first, fallback to Invoke-WebRequest
$success = $false
if (Get-Command Start-BitsTransfer -ErrorAction SilentlyContinue) {
    $success = Download-With-BITS
}

if (-not $success) {
    Write-Host "Falling back to Invoke-WebRequest..." -ForegroundColor Yellow
    $success = Download-With-InvokeWebRequest
}

if (-not $success) {
    Write-Host "ERROR: Download failed using all methods. Exiting." -ForegroundColor Red
    exit 1
}

Write-Host "Download complete: $InstallerPath" -ForegroundColor Green

# Launch installer (interactive)
Write-Host "Launching the AIO installer..." -ForegroundColor Cyan
Start-Process -FilePath $InstallerPath

Write-Host "Installer launched. Script exiting..." -ForegroundColor Yellow
exit 0
