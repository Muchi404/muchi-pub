# Ask user for new OS name
$osName = Read-Host "Enter new OS name"

# Apply it using bcdedit
bcdedit /set description "$osName"

# Optional confirmation
Write-Host "OS name set to: $osName"