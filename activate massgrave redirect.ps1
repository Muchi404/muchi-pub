# Variables
$url = "https://raw.githubusercontent.com/Muchi404/muchi-pub/main/MAS_AIO.cmd"
$downloadPath = "C:\Windows\Temp\MAS_AIO.cmd"
$shortcutPath = [Environment]::GetFolderPath("Desktop") + "\HWID Activate.lnk"

# Download the file
Invoke-WebRequest -Uri $url -OutFile $downloadPath

# Create a WScript.Shell COM object
$wsh = New-Object -ComObject WScript.Shell

# Create the shortcut
$shortcut = $wsh.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $downloadPath
$shortcut.Arguments = "/hwid"
$shortcut.WorkingDirectory = "C:\Windows\Temp"
$shortcut.Save()

# Launch the shortcut
Start-Process $shortcutPath
