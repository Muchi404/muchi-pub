# ==========================
#  MUCHI HUB (PowerShell)
# ==========================

$Apps = [ordered]@{
    "1" = "Muchility (Tweaks)"
    "2" = "Twitch Recorder"
    "3" = "Apex Legends Performance Mode"
    "4" = "Microsoft Redists AIO Installer"
    "5" = "Upgrade Windows Edition (Home > Pro)"
    "6" = "Spotify (No Ads)"
    "7" = "Debloat Windows"
    "8" = "Reset Windows Update (If Bugged)"
}

# --------------------------
#   SCRIPT LINKS
# --------------------------
$Links = @{
    "1" = "muchi.online/app"
    "2" = "muchi.online/twitch"
    "3" = "muchi.online/apex"
    "4" = "muchi.online/redists"
    "5" = "muchi.online/upgrade"
    "6" = "muchi.online/spotify"
    "7" = "muchi.online/debloat"
    "8" = "muchi.online/updatereset"
}

# ==========================
#        MENU
# ==========================
# Set black background and clear screen
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.UI.RawUI.ForegroundColor = "White"
Clear-Host

Write-Host ""
Write-Host "===== MUCHI HUB =====" -ForegroundColor Cyan
Write-Host ""

# Display menu with colors
foreach ($Key in ($Apps.Keys | Sort-Object {[int]$_})) {
    Write-Host "$Key) $($Apps[$Key])" -ForegroundColor Yellow
}
Write-Host ""

# Prompt user
$Choice = Read-Host "Select An Option"

# Run selected script
if ($Links.ContainsKey($Choice) -and $Links[$Choice]) {

    $Cmd = "iwr -useb `"$($Links[$Choice])`" | iex"
    Start-Process powershell.exe "-NoExit -ExecutionPolicy Bypass -Command $Cmd"
}
else {
    Write-Host ""
    Write-Host "Invalid or Missing Link`n" -ForegroundColor Red
    pause
}
