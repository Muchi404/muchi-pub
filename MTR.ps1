# Set Console Colors
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.UI.RawUI.ForegroundColor = "White"
Clear-Host

# Colors
$green = [ConsoleColor]::Green
$yellow = [ConsoleColor]::Yellow
$red = [ConsoleColor]::Red
$white = [ConsoleColor]::White

Function Write-Color($text, $color = $white) {
    $old = $Host.UI.RawUI.ForegroundColor
    $Host.UI.RawUI.ForegroundColor = $color
    Write-Host $text
    $Host.UI.RawUI.ForegroundColor = $old
}

# Paths
$FFmpegPath = "C:\ffmpeg"
$TwitchRecorderPath = "C:\Program Files\Twitch Recorder"
$VODsPath = "C:\VODs"
$Desktop = [Environment]::GetFolderPath("Desktop")
$ShortcutPath = Join-Path $Desktop "VODs.lnk"

Clear-Host
Write-Color "Checking For Package Managers..." $yellow
Start-Sleep 1
$HasWinget = (Get-Command winget -ErrorAction SilentlyContinue)
$HasChoco = (Get-Command choco -ErrorAction SilentlyContinue)

if (-not $HasWinget -and -not $HasChoco) {
    Write-Color "`nNeither Winget Nor Chocolatey Is Installed.`nPlease Install One Of Them And Re-Run This Script." $red
    Start-Sleep 4
    exit
}

Start-Sleep 1
Clear-Host
Write-Color "Checking For Python..." $yellow
Start-Sleep 1
$PythonInstalled = (Get-Command python -ErrorAction SilentlyContinue)
if (-not $PythonInstalled) {
    Write-Color "Python Not Found, Installing..." $red
    if ($HasWinget) {
        winget install Python.Python.3 --silent
    } elseif ($HasChoco) {
        choco install python -y
    }
    Start-Sleep 3
} else {
    Write-Color "Python Is Already Installed." $green
    Start-Sleep 2
}

Clear-Host
Write-Color "Checking For Streamlink..." $yellow
Start-Sleep 1
$StreamlinkInstalled = (Get-Command streamlink -ErrorAction SilentlyContinue)
if (-not $StreamlinkInstalled) {
    Write-Color "Streamlink Not Found, Installing..." $red
    if ($HasWinget) {
        winget install Streamlink --silent
    } elseif ($HasChoco) {
        choco install streamlink -y
    }
    Start-Sleep 3
} else {
    Write-Color "Streamlink Is Already Installed." $green
    Start-Sleep 2
}

Clear-Host
Write-Color "Checking For FFMPEG Folder..." $yellow
Start-Sleep 1
if (-not (Test-Path $FFmpegPath)) {
    Write-Color "FFMPEG Not Found, Downloading And Installing..." $red
    $FFmpegZip = "$env:TEMP\ffmpeg.zip"
    try {
        Invoke-WebRequest -Uri "https://www.dropbox.com/scl/fi/ykpfgt7hatzvj9jezwgpo/ffmpeg.zip?rlkey=0o37frqtvxbpjv9wa981mbqkb&st=gc164ye5&dl=1" -OutFile $FFmpegZip -ErrorAction Stop
    } catch {
        Write-Color "Failed To Download FFMPEG. Check Connection Or Link." $red
        Start-Sleep 4
        exit
    }
    Expand-Archive -Path $FFmpegZip -DestinationPath $FFmpegPath -Force
    Remove-Item $FFmpegZip -Force
    Start-Process -FilePath "cmd.exe" -ArgumentList '/c setx /m PATH "C:\ffmpeg\bin;%PATH%"' -Verb RunAs -Wait
    Write-Color "FFMPEG Installed Successfully." $green
    Start-Sleep 2
} else {
    Write-Color "FFMPEG Already Installed." $green
    Start-Sleep 2
}

Clear-Host
Write-Color "Checking For Twitch Recorder Folder..." $yellow
Start-Sleep 1
if (-not (Test-Path $TwitchRecorderPath)) {
    Write-Color "Twitch Recorder Not Found, Downloading..." $red
    $TRZip = "$env:TEMP\Twitch-Recorder.zip"
    try {
        Invoke-WebRequest -Uri "https://www.dropbox.com/scl/fi/ntewgh6doitr90ujveg0x/Twitch-Recorder.zip?rlkey=xok3e2gpjoo2a9h564inceu1x&st=git3ytvs&dl=1" -OutFile $TRZip -ErrorAction Stop
    } catch {
        Write-Color "Failed To Download Twitch Recorder Zip." $red
        Start-Sleep 4
        exit
    }

    $TempExtract = "$env:TEMP\Twitch-Recorder-Tmp"
    if (Test-Path $TempExtract) { Remove-Item $TempExtract -Recurse -Force }
    Expand-Archive -Path $TRZip -DestinationPath $TempExtract -Force

    $InnerFolder = Get-ChildItem $TempExtract | Where-Object { $_.PSIsContainer } | Select-Object -First 1
    if ($InnerFolder) {
        New-Item -ItemType Directory -Force -Path $TwitchRecorderPath | Out-Null
        Move-Item -Path (Join-Path $InnerFolder.FullName "*") -Destination $TwitchRecorderPath -Force
    } else {
        Expand-Archive -Path $TRZip -DestinationPath $TwitchRecorderPath -Force
    }

    Remove-Item $TRZip -Force
    Remove-Item $TempExtract -Recurse -Force
    Write-Color "Twitch Recorder Installed Successfully." $green
    Start-Sleep 2
} else {
    Write-Color "Twitch Recorder Already Installed." $green
    Start-Sleep 2
}

Clear-Host
Write-Color "Creating VODs Folder And Desktop Shortcut..." $yellow
Start-Sleep 1

# Ensure C:\VODs exists
if (-not (Test-Path $VODsPath)) {
    New-Item -ItemType Directory -Force -Path $VODsPath | Out-Null
    Write-Color "Created Folder: C:\VODs" $green
    Start-Sleep 1
}

# Ensure DONT DELETE folder exists
$IconFolder = Join-Path $TwitchRecorderPath "DONT DELETE"
if (-not (Test-Path $IconFolder)) {
    New-Item -ItemType Directory -Force -Path $IconFolder | Out-Null
}

# Download twitch.ico if it doesn't exist
$IconPath = Join-Path $IconFolder "twitch.ico"
if (-not (Test-Path $IconPath)) {
    try {
        Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Muchi404/muchi-pub/main/twitch.ico" -OutFile $IconPath -ErrorAction Stop
        Write-Color "Downloaded twitch.ico to $IconFolder" $green
        Start-Sleep 1
    } catch {
        Write-Color "Failed To Download twitch.ico" $red
        Start-Sleep 3
    }
}

# Create desktop shortcut
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = $VODsPath
$Shortcut.IconLocation = $IconPath
$Shortcut.Save()

Write-Color "Desktop Shortcut To VODs Created Successfully." $green
Start-Sleep 2

Clear-Host
Write-Color "Muchi Twitch Recorder Starting.." $yellow
Start-Sleep 2
try {
    Invoke-Expression (Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/Muchi404/muchi-pub/main/Muchi%20Twitch%20Recorder.ps1").Content
} catch {
    Write-Color "Failed To Launch Muchi Twitch Recorder Script." $red
    Start-Sleep 4
}

