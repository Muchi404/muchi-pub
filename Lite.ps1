#╔══╗══╗╔═╗═╗╔═══╗╔═╗╔═╗╔═╗"
#║*   *║║*║*║║*║*║║*╚╝*║╠-╣"
#║ ║ ║ ║║*║*║║*╚═╣║*╔╗*║║*║"
#╚═╩═╩═╝╚═══╝╚═══╝╚═╝╚═╝╚═╝"


function Get-MuVer {
    $url = "https://raw.githubusercontent.com/Muchi404/Muchi-pub/main/muchiver.txt"
    try {
        $muver = (Invoke-WebRequest -Uri $url -UseBasicParsing -ErrorAction Stop).Content.Trim()
        return $muver
    } catch {
        Write-Error "Failed to retrieve version from GitHub. Ensure you have internet access and try again."
        exit 1
    }
}

$muver = Get-MuVer

function Check-PS2EXE {
    try {
        Get-Command ps2exe -ErrorAction Stop | Out-Null
        return $true
    } catch {
        return $false
    }
}

function Install-PS2EXE {
    try {
        Install-Module -Name ps2exe -Force -Scope CurrentUser -ErrorAction Stop > $null 2>&1
    } catch {
        Write-Error "Failed to install ps2exe module. Ensure you have internet access and try again."
        exit 1
    }
}

function Compile-And-Run {
    $TempDir = "C:\windows\temp"
    if (!(Test-Path -Path $TempDir)) { New-Item -ItemType Directory -Path $TempDir -Force > $null 2>&1 }

    $RunScriptUrl = "https://raw.githubusercontent.com/Muchi404/Muchi-pub/main/Muchility.ps1"
    $IconUrl = "https://raw.githubusercontent.com/Muchi404/Muchi-pub/main/muchi.ico"
    $RunScriptPath = Join-Path $TempDir "Muchility.ps1"
    $IconPath = Join-Path $TempDir "Muchi.ico"
    $OutputExe = Join-Path $TempDir "Muchility.exe"
    $DesktopPath = [Environment]::GetFolderPath("Desktop")
    $FinalExePath = Join-Path $DesktopPath "Muchility.exe"

    try {
        Invoke-WebRequest -Uri $RunScriptUrl -OutFile $RunScriptPath -UseBasicParsing -ErrorAction Stop
        Invoke-WebRequest -Uri $IconUrl -OutFile $IconPath -UseBasicParsing -ErrorAction Stop
    } catch {
        Write-Error "Failed to download required files. Ensure you have internet access and try again."
        exit 1
    }

    if (!(Test-Path -Path $RunScriptPath) -or !(Test-Path -Path $IconPath)) {
        Write-Error "Required files are missing after download. Check the URLs and try again."
        exit 1
    }

    try {
        ps2exe $RunScriptPath $OutputExe -iconFile $IconPath `
            -Version $muver -Description "Muchility Created By Muchi @ muchi.online" `
            -Copyright "Muchi @ muchi.online" -Product "Muchility" `
    } catch {
        Write-Error "Compilation failed. Ensure ps2exe is installed correctly."
        exit 1
    }

    Move-Item -Path $OutputExe -Destination $FinalExePath -Force > $null 2>&1
    Remove-Item -Path $TempDir -Recurse -Force > $null 2>&1
    Start-Process -FilePath $FinalExePath > $null 2>&1
    exit
}

function Close-Muchility {
    $process = Get-Process -Name "muchility" -ErrorAction SilentlyContinue
    if ($process) {
        Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
        return $true
    } else {
        return $false
    }
}

# Main Execution
if (Close-Muchility) {
    # Handle successful process closure if needed
}

if (-not (Check-PS2EXE)) { Install-PS2EXE }

Close-Muchility > $null 2>&1
Compile-And-Run > $null 2>&1







