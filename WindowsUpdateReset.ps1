# Run as Administrator
If (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process -FilePath "powershell" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

# Stop Windows Update Services
$services = @("bits", "wuauserv", "appidsvc", "cryptsvc")
foreach ($service in $services) {
    Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
}

# Flush DNS and Delete Update Cache
ipconfig /flushdns
Remove-Item "$env:ALLUSERSPROFILE\Microsoft\Network\Downloader\qmgr*.dat" -Force -ErrorAction SilentlyContinue
Remove-Item "$env:SystemRoot\Logs\WindowsUpdate\*" -Force -Recurse -ErrorAction SilentlyContinue

# Rename Update Cache Folders
$folders = @("$env:SystemRoot\winsxs\pending.xml", "$env:SystemRoot\SoftwareDistribution", "$env:SystemRoot\system32\Catroot2")
foreach ($folder in $folders) {
    If (Test-Path $folder) {
        Rename-Item -Path $folder -NewName "$($folder).bak" -Force -ErrorAction SilentlyContinue
    }
}

# Reset Windows Update Policies
$regPaths = @(
    "HKCU:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\WindowsUpdate",
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\WindowsUpdate"
)
foreach ($path in $regPaths) {
    Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
}

# Refresh Group Policies
gpupdate /force

# Reset Windows Update Services Security Descriptors
sc.exe sdset bits "D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)"
sc.exe sdset wuauserv "D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)"

# Re-register Windows Update Components
$dlls = @(
    "atl.dll", "urlmon.dll", "mshtml.dll", "shdocvw.dll", "browseui.dll", "jscript.dll", "vbscript.dll", "scrrun.dll",
    "msxml.dll", "msxml3.dll", "msxml6.dll", "actxprxy.dll", "softpub.dll", "wintrust.dll", "dssenh.dll", "rsaenh.dll",
    "gpkcsp.dll", "sccbase.dll", "slbcsp.dll", "cryptdlg.dll", "oleaut32.dll", "ole32.dll", "shell32.dll", "initpki.dll",
    "wuapi.dll", "wuaueng.dll", "wuaueng1.dll", "wucltui.dll", "wups.dll", "wups2.dll", "wuweb.dll", "qmgr.dll",
    "qmgrprxy.dll", "wucltux.dll", "muweb.dll", "wuwebv.dll", "wudriver.dll"
)
foreach ($dll in $dlls) {
    regsvr32.exe /s $dll
}

# Reset Network Settings
netsh winsock reset
netsh winsock reset proxy

# Set Services to Auto Start
foreach ($service in $services) {
    Set-Service -Name $service -StartupType Automatic
}

# Start Windows Update Services
foreach ($service in $services) {
    Start-Service -Name $service -ErrorAction SilentlyContinue
}

# Restart Computer with Countdown
Write-Host "It is required to restart the computer to finish resetting Windows Update."
Write-Host "Please save and close anything open now, before the computer is restarted."

for ($i = 30; $i -ge 0; $i--) {
    Write-Host "Restarting in $i seconds..." -NoNewline
    Start-Sleep -Seconds 1
    Write-Host "`r" -NoNewline
}

Restart-Computer -Force
