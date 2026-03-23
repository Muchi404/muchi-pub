#╔══╗══╗╔═╗═╗╔═══╗╔═╗╔═╗╔═╗"
#║*   *║║*║*║║*║*║║*╚╝*║╠-╣"
#║ ║ ║ ║║*║*║║*╚═╣║*╔╗*║║*║"
#╚═╩═╩═╝╚═══╝╚═══╝╚═╝╚═╝╚═╝"


# Create icon directory
$installPath = "C:\Program Files\Muchility"
New-Item -ItemType Directory -Path $installPath -Force | Out-Null

# Download icon
$iconPath = Join-Path $installPath "muchi.ico"
Invoke-WebRequest "https://raw.githubusercontent.com/Muchi404/muchi-pub/refs/heads/main/muchi.ico" -OutFile $iconPath

# Create shortcut
$desktop = [Environment]::GetFolderPath("Desktop")
$shortcutPath = Join-Path $desktop "Muchility.lnk"

$wsh = New-Object -ComObject WScript.Shell
$shortcut = $wsh.CreateShortcut($shortcutPath)

$shortcut.TargetPath = "powershell.exe"
$shortcut.Arguments = '-NoProfile -ExecutionPolicy Bypass -Command "iwr -useb ''https://muchi.online/app'' | iex"'
$shortcut.IconLocation = $iconPath
$shortcut.WorkingDirectory = $installPath

$shortcut.Save()
