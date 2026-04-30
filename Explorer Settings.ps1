$url = "https://raw.githubusercontent.com/Muchi404/muchi-pub/refs/heads/main/Explorer%20Settings.reg"
$file = "$env:TEMP\ExplorerSettings.reg"

# Download
Invoke-WebRequest -Uri $url -OutFile $file

# Import registry file
Start-Process reg.exe -ArgumentList "import `"$file`"" -Wait -NoNewWindow

# Restart Explorer
Stop-Process -Name explorer -Force
Start-Process explorer