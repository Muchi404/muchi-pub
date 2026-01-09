# Set console colors
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.UI.RawUI.ForegroundColor = "White"
Clear-Host

$BasePath = "C:\Program Files\Twitch Recorder"
$MotherFolder = Join-Path $BasePath "DONT DELETE"
$RootPath = Join-Path $BasePath "Streamers"

if (-not (Test-Path $MotherFolder)) { throw "Mother folder not found: $MotherFolder" }

Function Setup-StreamerFolder {
    param($StreamerName)

    $NewFolder = Join-Path $RootPath $StreamerName

    if (-not (Test-Path $NewFolder)) {
        New-Item -Path $NewFolder -ItemType Directory | Out-Null
    }

    $FilesToCopy = @(".gitignore", "LICENSE", "README.md", "twitch-recorder.py")
    foreach ($File in $FilesToCopy) {
        Copy-Item -Path (Join-Path $MotherFolder $File) -Destination $NewFolder -Force
    }

    $MotherConfig = Join-Path $MotherFolder "config.py"
    $NewConfig = Join-Path $NewFolder "config.py"
    $ConfigContent = Get-Content $MotherConfig -Raw
    $ConfigContent = $ConfigContent -replace 'username\s*=\s*".*?"', 'username = "REPLACEME"'
    Set-Content -Path $NewConfig -Value $ConfigContent -Encoding UTF8

    return $NewFolder
}

Function Run-Recorder {
    param($Folder)
    & python "$Folder\twitch-recorder.py"
}

$StreamerFolder = Setup-StreamerFolder -StreamerName "REPLACEME"
Run-Recorder -Folder $StreamerFolder