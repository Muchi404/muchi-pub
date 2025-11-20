# Paths
$FFmpegPath = "C:\ffmpeg"
$TwitchRecorderPath = "C:\Program Files\Twitch Recorder"
$VODsPath = "C:\VODs"
$Desktop = [Environment]::GetFolderPath("Desktop")
$ShortcutPath = Join-Path $Desktop "VODs.lnk"

Function Check-Winget {
    Get-Command winget -ErrorAction SilentlyContinue
}

Function Download-File($Url, $OutFile) {
    try {
        Start-BitsTransfer -Source $Url -Destination $OutFile -ErrorAction Stop
    } catch {
        Start-Sleep 1
        Start-BitsTransfer -Source $Url -Destination $OutFile
    }
}

Function Install-Python {
    Write-Output "Installing Python..."
    winget install Python.Python.3 --silent --accept-package-agreements --accept-source-agreements
}

Function Check-Python {
    $Python3 = Get-Command python3 -ErrorAction SilentlyContinue
    $Python  = Get-Command python  -ErrorAction SilentlyContinue

    if ($Python3 -or $Python) { return }

    Write-Output "Python not found."
    Install-Python
}

Function Check-Requests {
    try {
        & python -c "import requests" 2>$null
        if ($LASTEXITCODE -eq 0) { return }
    } catch {}

    Write-Output "Installing Python 'requests' module..."
    & python -m pip install requests --quiet
}

Function Install-Streamlink {
    Write-Output "Installing Streamlink..."
    winget install Streamlink --silent --accept-package-agreements --accept-source-agreements
}

Function Check-Streamlink {
    if (Get-Command streamlink -ErrorAction SilentlyContinue) { return }

    Write-Output "Streamlink not found."
    Install-Streamlink
}

Function Check-FFmpeg {
    if (Test-Path $FFmpegPath) { return }

    Write-Output "FFMPEG not found. Downloading..."

    $zip = "$env:TEMP\ffmpeg.zip"
    Download-File "https://www.dropbox.com/scl/fi/ykpfgt7hatzvj9jezwgpo/ffmpeg.zip?rlkey=0o37frqtvxbpjv9wa981mbqkb&dl=1" $zip

    try {
        Expand-Archive -Path $zip -DestinationPath $FFmpegPath -Force
        Remove-Item $zip -Force
        Start-Process cmd.exe '/c setx /m PATH "C:\ffmpeg\bin;%PATH%"' -Verb RunAs -Wait
    } catch {
        Write-Output "FFMPEG install failed."
    }
}

Function Check-TwitchRecorder {
    if (Test-Path $TwitchRecorderPath) { return }

    Write-Output "Twitch Recorder not found. Downloading..."

    $zip = "$env:TEMP\Twitch-Recorder.zip"
    $tmp = "$env:TEMP\Twitch-Recorder-Tmp"

    if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }

    Download-File "https://www.dropbox.com/scl/fi/ntewgh6doitr90ujveg0x/Twitch-Recorder.zip?rlkey=xok3e2gpjoo2a9h564inceu1x&dl=1" $zip

    try {
        Expand-Archive -Path $zip -DestinationPath $tmp -Force

        $inner = Get-ChildItem $tmp | Where-Object { $_.PSIsContainer } | Select-Object -First 1

        New-Item -ItemType Directory -Path $TwitchRecorderPath -Force | Out-Null
        if ($inner) {
            Move-Item (Join-Path $inner.FullName "*") $TwitchRecorderPath -Force
        } else {
            Expand-Archive -Path $zip -DestinationPath $TwitchRecorderPath -Force
        }

        Remove-Item $zip -Force
        Remove-Item $tmp -Recurse -Force

    } catch {
        Write-Output "Twitch Recorder install failed."
    }
}

Function Setup-VODsShortcut {

    if (-not (Test-Path $VODsPath)) {
        New-Item -ItemType Directory -Force -Path $VODsPath | Out-Null
    }

    $IconFolder = Join-Path $TwitchRecorderPath "DONT DELETE"
    if (-not (Test-Path $IconFolder)) {
        New-Item -ItemType Directory -Force -Path $IconFolder | Out-Null
    }

    $IconPath = Join-Path $IconFolder "twitch.ico"
    if (-not (Test-Path $IconPath)) {
        Download-File "https://raw.githubusercontent.com/Muchi404/muchi-pub/main/twitch.ico" $IconPath
    }

    $Shell = New-Object -ComObject WScript.Shell
    $Shortcut = $Shell.CreateShortcut($ShortcutPath)
    $Shortcut.TargetPath = $VODsPath
    $Shortcut.IconLocation = $IconPath
    $Shortcut.Save()
}

Function Start-MTR {
    Clear-Host

    if (-not (Check-Winget)) {
        Write-Output "Winget is required."
        return
    }

    Check-Streamlink
    Start-Sleep 1
    Clear-Host

    Check-Python
    Start-Sleep 1
    Clear-Host

    Check-Requests
    Start-Sleep 1
    Clear-Host

    Check-FFmpeg
    Start-Sleep 1
    Clear-Host

    Check-TwitchRecorder
    Start-Sleep 1
    Clear-Host

    Setup-VODsShortcut
    Start-Sleep 1
    Clear-Host

    Write-Output "Checks complete. Launching Muchi Twitch Recorder!"
    Start-Sleep 2

    try {
        $remote = "$env:TEMP\mtr.ps1"
        Download-File "https://raw.githubusercontent.com/Muchi404/muchi-pub/main/Muchi%20Twitch%20Recorder.ps1" $remote
        Invoke-Expression (Get-Content $remote -Raw)
    } catch {
        Write-Output "Failed to launch recorder."
    }
}

Start-MTR
