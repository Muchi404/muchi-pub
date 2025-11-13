#╔══╗══╗╔═╗═╗╔═══╗╔═╗╔═╗╔═╗
#║     ║║ ║ ║║ ║ ║║ ╚╝ ║╠-╣
#║ ║ ║ ║║ ║ ║║ ╚═╣║ ╔╗ ║║ ║
#╚═╩═╩═╝╚═══╝╚═══╝╚═╝╚═╝╚═╝

# Check if script is running as Administrator
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Try {
        Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
        Exit
    }
    Catch {
        Write-Host "Failed to run as Administrator. Please rerun with elevated privileges."
        Exit
    }
}


# Set window title and color scheme 
$Host.UI.RawUI.WindowTitle = "Muchility"
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.PrivateData.ProgressBackgroundColor = "Black"
$Host.PrivateData.ProgressForegroundColor = "White"
Clear-Host





#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


function Show-Apply-All-Menu {
	Clear-Host
    Show-Header
    Write-Host "Apply All Menu:" -ForegroundColor Yellow
	Write-Host "1. Reset All To Default Settings"
	Write-Host "2. Apply All Recommended Settings"
	Write-Host "0. Back to Main Menu"
    
    Write-Host ""
    $choice = Read-Host "Select an option"

    switch ($choice) {
		"1" { Default-All }
		"2" { Recommended-All }
		"0" { Show-MuchilityMainMenu }
		
        default {
            Write-Host "Invalid selection. Please try again." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
}


function Default-All {
    Set-DefaultPrivacySettings *> $null
    Write-Host "Privacy settings have been reset to default."
    Start-Sleep -Seconds 2
    Clear-Host

    Set-DefaultHKCURegistry *> $null
    Write-Host "HKCU registry defaults applied."
    Start-Sleep -Seconds 2
    Clear-Host

    Set-DefaultHKLMRegistry *> $null
    Write-Host "HKLM registry defaults applied."
    Start-Sleep -Seconds 2
    Clear-Host

    Set-DefaultPowerSettings *> $null
    Write-Host "Power settings restored to default."
    Start-Sleep -Seconds 2
    Clear-Host

    Set-DefaultUpdateSettings *> $null
    Write-Host "Update settings reset to default."
    Start-Sleep -Seconds 2
    Clear-Host

    Set-DefaultServices *> $null
    Write-Host "Default services configured."
    Start-Sleep -Seconds 2
    Clear-Host

    Enable-ScheduledTasks *> $null
    Write-Host "Scheduled tasks enabled."
    Start-Sleep -Seconds 2
    Clear-Host
}


function Recommended-All {
    Set-RecommendedPrivacySettings *> $null
    Write-Host "Privacy settings optimized."
    Start-Sleep -Seconds 2
    Clear-Host

    Set-RecommendedHKCURegistry *> $null
    Write-Host "HKCU registry configured to recommended settings."
    Start-Sleep -Seconds 2
    Clear-Host

    Set-RecommendedHKLMRegistry *> $null
    Write-Host "HKLM registry configured to recommended settings."
    Start-Sleep -Seconds 2
    Clear-Host

    Set-RecommendedPowerSettings *> $null
    Write-Host "Power settings optimized to recommended settings."
    Start-Sleep -Seconds 2
    Clear-Host

    Set-RecommendedUpdateSettings *> $null
    Write-Host "Update settings optimized."
    Start-Sleep -Seconds 2
    Clear-Host

    Set-ServiceStartup *> $null
    Write-Host "Services configured to recommended settings."
    Start-Sleep -Seconds 2
    Clear-Host

    Disable-ScheduledTasks *> $null
    Write-Host "Scheduled tasks disabled."
    Start-Sleep -Seconds 2
    Clear-Host
}





# START OF MENU FUNCTIONS
$script:loop = $true





# Header
function Show-Header {
	$Host.UI.RawUI.WindowTitle = "Muchility" + " (Administrator)" 
    Clear-Host
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "                 MUCHILITY                  " -ForegroundColor Yellow
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "" 
    Write-Host "NO LIABILITY ACCEPTED, PROCEED WITH CAUTION!" -ForegroundColor Black -BackgroundColor Red
    Write-Host ""
}


# Main Menu
function Show-MuchilityMainMenu {
	Clear-Host
    Show-Header
    Write-Host "Muchility Main Menu:" -ForegroundColor Yellow
    Write-Host "1. Software & Apps"
    Write-Host "2. Privacy & Security"
    Write-Host "3. Windows Updates"
    Write-Host "4. Optimize Registry"
    Write-Host "5. Tasks & Services"
    Write-Host "6. Power Settings"
	Write-Host "7. System Repair"
	Write-Host "8. Clear Temp + Prefetch"
	Write-Host "9. Apply All Settings"
    Write-Host ""
    $choice = Read-Host "Select an option"

    switch ($choice) {
        "1" { Show-SoftwareMenu }
        "2" { Show-PrivacySecurityMenu }
        "3" { Show-WindowsUpdateMenu }
        "4" { Show-OptimizeRegistryMenu }
        "5" { Show-TasksServicesMenu }
        "6" { Show-PowerSettingsMenu }
		"7" { System-Repair }
		"8" { Clear-Temp }
		"9" { Show-Apply-All-Menu }
		
        default {
            Write-Host "Invalid selection. Please try again." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
}





#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
# 														1. Software & Apps


Function Show-SoftwareMenu {
    Clear-Host
	Show-Header
    Write-Host "=== Software & Apps Menu ===" -ForegroundColor Cyan
    Write-Host "1. Install Microsoft Store (If Missing)"
    Write-Host "2. Uninstall One Drive"
    Write-Host "3. Disable Windows App Annoyances"
	Write-Host "4. Muchi's Debloat "
    Write-Host "0. Back to Main Menu"
    
	Write-Host ""
    $choice = Read-Host "Select an option"
    switch ($choice) {
		"1" { Install-Store }  
        "2" { RemoveAndUninstall-OneDrive } 
        "3" { Set-AppsRegistry } 
		"4" { Write-Host "Muchi's Debloater started in background." -ForegroundColor Yellow
		Start-Job -ScriptBlock { Muchi-Debloater } | Out-Null}
        "0" { Show-MuchilityMainMenu }
        default { Write-Host "Selected: $choice"; Show-SoftwareMenu }
    }
}





# Install the Microsoft Store
function Install-Store {
    Clear-Host
    # Check for internet connection
    if (-not (Test-InternetConnection)) {
        Write-Host "No internet connection detected. Please connect to the internet and try again." -BackgroundColor Red
        
        return
    }

    # If internet connection is available, continue with installation
    Show-Header
    Write-Host "Installing Microsoft Store . . ."
    Try {
        wsreset -i -ErrorAction SilentlyContinue
        Show-Header
        Write-Host "Microsoft Store is being installed silently in the background." -BackgroundColor Green
        Write-Host "Please allow a few minutes for it to install and use it to reinstall the necessary apps manually."
    }
    Catch {
        Show-Header
        Write-Host "An error occurred while trying to install the Microsoft Store. Please try again later." -BackgroundColor Red
    }
    
}


# Removes OneDrive
Function RemoveAndUninstall-OneDrive {
    # Stop OneDrive if running
    Stop-Process -Force -Name OneDrive -ErrorAction SilentlyContinue | Out-Null

    # Remove OneDrive shortcuts and setup files
    $paths = @(
        "C:\Users\Default\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk",
        "C:\Users\Default\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.exe",
        "C:\Windows\System32\OneDriveSetup.exe",
        "C:\Windows\SysWOW64\OneDriveSetup.exe"
    )
    $paths | ForEach-Object { Remove-Item $_ -ErrorAction SilentlyContinue }

    # Uninstall OneDrive (Windows 10)
    Start-Process -FilePath "C:\Windows\SysWOW64\OneDriveSetup.exe" -ArgumentList "/uninstall" -WindowStyle Hidden -Wait -ErrorAction SilentlyContinue

    # Unregister scheduled tasks for OneDrive
    Get-ScheduledTask | Where-Object { $_.TaskName -match 'OneDrive' } | Unregister-ScheduledTask -Confirm:$false

    # Uninstall OneDrive (Windows 11)
    Start-Process -FilePath "C:\Windows\System32\OneDriveSetup.exe" -ArgumentList "/uninstall" -WindowStyle Hidden -Wait -ErrorAction SilentlyContinue
	
	Write-Host "Removed OneDrive!" -ForegroundColor Green
	Start-Sleep -Seconds 2
}


# Apply registry mods to prevent reinstallation and disable features
Function Set-AppsRegistry {
    # Disable Windows Copilot system-wide
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Value 1 -Type DWord

    # Prevents Dev Home Installation
    Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\DevHomeUpdate" -Recurse -Force -ErrorAction SilentlyContinue

    # Prevents New Outlook for Windows Installation
    Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\OutlookUpdate" -Recurse -Force -ErrorAction SilentlyContinue

    # Prevents Chat Auto Installation
    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Communications" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Communications" -Name "ConfigureChatAutoInstall" -Value 0 -Type DWord

    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Chat" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Chat" -Name "ChatIcon" -Value 3 -Type DWord

    # Disables Cortana
    New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Value 0 -Type DWord

    # Disables OneDrive Automatic Backups of Important Folders
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\OneDrive" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\OneDrive" -Name "KFMBlockOptIn" -Value 1 -Type DWord
	
	Disable-WindowsOptionalFeature -Online -FeatureName "Recall" -NoRestart -ErrorAction SilentlyContinue
	
	Write-Host "Disabled Cortana, Copilot, Chat, Dev Home, Outlook, Recall & OneDrive Backups!" -ForegroundColor Green
	Start-Sleep -Seconds 2
}


# Muchi's Debloater
Function Muchi-Debloater {

    $MuchiDontRemove = "calculator|store|windowsnotepad|chatgpt|minecraft|nvidia|Microsoft.Xbox.TCUI|XboxGameCallableUI|XboxGamingOverlay|XboxIdentityProvider"
    $DontRemove = "AAD.brokerplugin|accountscontrol|apprep.chxapp|assignedaccess|asynctext|bioenrollment|capturepicker|cloudexperience|contentdelivery|desktopappinstaller|ecapp|edge|extension|getstarted|immersivecontrolpanel|lockapp|net.native|oobenet|parentalcontrols|PPIProjection|search|sechealth|secureas|shellexperience|startmenuexperience|terminal|vclibs|xaml|XGpuEject"

    If ($Xbox) {
        $DontRemove = "$DontRemove|Xbox"
    }

    If (-not $Allapps) {
        $DontRemove = "$DontRemove|$MuchiDontRemove"
    }

    $RemoveApps = Get-AppxPackage -AllUsers | Where-Object { $_.Name -notmatch $DontRemove }
    $RemovePrApps = Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -notmatch $DontRemove }

    ForEach ($App in $RemoveApps) {
        Remove-AppxPackage -Package $App -ErrorAction SilentlyContinue
    }

    ForEach ($PrApp in $RemovePrApps) {
        Remove-AppxProvisionedPackage -Online -PackageName $PrApp.PackageName -ErrorAction SilentlyContinue
    }
	Clear-Host
	Write-Host "Windows has been debloated!" -ForegroundColor Green
	
	Start-Sleep -Seconds 2
}





#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
# 														2. Privacy & Security


Function Show-PrivacySecurityMenu {
    Clear-Host
	Show-Header
    Write-Host "=== Privacy & Security Menu ===" -ForegroundColor Cyan
    Write-Host "1. Recommended Privacy Settings"
    Write-Host "2. Default Privacy Settings"
    Write-Host "3. Enable Windows Defender"
    Write-Host "0. Back to Main Menu"

    Write-Host ""
    $choice = Read-Host "Select an option"
    switch ($choice) {
		"1" { Set-RecommendedPrivacySettings }  
        "2" { Set-DefaultPrivacySettings } 
        "3" { Enable-WindowsDefender } 
        "0" { Show-MuchilityMainMenu }
        default { Write-Host "Selected: $choice"; Show-PrivacySecurityMenu }
    }
}





# Function to Enable Windows Defender
Function Enable-WindowsDefender {
	Show-Header
    # Enable Windows Defender services
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Sense" -Name "Start" -Value 3 -Type DWord
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WdBoot" -Name "Start" -Value 0 -Type DWord
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WdFilter" -Name "Start" -Value 0 -Type DWord
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WdNisDrv" -Name "Start" -Value 3 -Type DWord
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WdNisSvc" -Name "Start" -Value 3 -Type DWord
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WinDefend" -Name "Start" -Value 2 -Type DWord

    Write-Host "Windows Defender has been enabled." -ForegroundColor Green
    
    Start-Sleep -Seconds 2
}


# Function to Apply the Recommended Privacy Settings
Function Set-RecommendedPrivacySettings {
        Show-Header
        Write-Host "Applying Recommended Privacy Settings . . ."

    # Disable Activity History
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Value 0 -Type DWord
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Value 0 -Type DWord
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "UploadUserActivities" -Value 0 -Type DWord

    # Disable Location Tracking
    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Value "Deny" -Type String

    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" -Name "SensorPermissionState" -Value 0 -Type DWord

    New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration" -Name "Status" -Value 0 -Type DWord

    # Disable Maps AutoUpdate
    New-Item -Path "HKLM:\SYSTEM\Maps" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SYSTEM\Maps" -Name "AutoUpdateEnabled" -Value 0 -Type DWord

    # Disable Telemetry
    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Value 0 -Type DWord

    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -Type DWord
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "DoNotShowFeedbackNotifications" -Value 1 -Type DWord

    # Disable Windows Ink Workspace
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace" -Name "AllowWindowsInkWorkspace" -Value 0 -Type DWord

    # Disable Advertising ID
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" -Name "DisabledByGroupPolicy" -Value 1 -Type DWord

    # Disable Account Info
    New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation" -Name "Value" -Value "Deny" -Type String

    Write-Host "Recommended Privacy Settings Applied." -ForegroundColor Green
	
    Start-Sleep -Seconds 2

}


# Function to Apply the Default Privacy Settings
Function Set-DefaultPrivacySettings {

    Show-Header
    Write-Host "Applying Default Privacy Settings . . ."

    # Revert Activity History
    $systemPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
    Remove-ItemProperty -Path $systemPath -Name "EnableActivityFeed" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path $systemPath -Name "PublishUserActivities" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path $systemPath -Name "UploadUserActivities" -ErrorAction SilentlyContinue

    # Revert Location Tracking
    $locationPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location"
    Remove-ItemProperty -Path $locationPath -Name "Value" -ErrorAction SilentlyContinue

    $sensorPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}"
    Remove-ItemProperty -Path $sensorPath -Name "SensorPermissionState" -ErrorAction SilentlyContinue

    $lfsvcPath = "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration"
    Remove-ItemProperty -Path $lfsvcPath -Name "Status" -ErrorAction SilentlyContinue

    # Revert Maps AutoUpdate
    Set-ItemProperty -Path "HKLM:\SYSTEM\Maps" -Name "AutoUpdateEnabled" -Value 1 -Type DWord -ErrorAction SilentlyContinue

    # Revert Telemetry
    $telemetryPath1 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
    Remove-ItemProperty -Path $telemetryPath1 -Name "AllowTelemetry" -ErrorAction SilentlyContinue

    $telemetryPath2 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
    Remove-ItemProperty -Path $telemetryPath2 -Name "AllowTelemetry" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path $telemetryPath2 -Name "DoNotShowFeedbackNotifications" -ErrorAction SilentlyContinue

    # Revert Windows Ink Workspace
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace" -Name "AllowWindowsInkWorkspace" -ErrorAction SilentlyContinue

    # Revert Advertising ID
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" -Name "DisabledByGroupPolicy" -ErrorAction SilentlyContinue

    # Revert Account Info
    Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation" -Name "Value" -Value "Allow" -Type String -ErrorAction SilentlyContinue

    Show-Header
    Write-Host "Default Privacy Settings Applied." -ForegroundColor Green
	
    Start-Sleep -Seconds 2
}






#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
# 														3. Windows Updates


Function Show-WindowsUpdateMenu {
    Clear-Host
	Show-Header
    Write-Host "=== Windows Updates Menu ===" -ForegroundColor Cyan
    Write-Host "1. Recommended Update Settings"
    Write-Host "2. Default Update Settings"
    Write-Host "0. Back to Main Menu"

    Write-Host ""
    $choice = Read-Host "Select an option"
    switch ($choice) {
		"1" { Set-RecommendedUpdateSettings }  
        "2" { Set-DefaultUpdateSettings } 
        "0" { Show-MuchilityMainMenu }
        default { Write-Host "Selected: $choice"; Show-WindowsUpdateMenu }
    }
}




# Recommended Update Settings
Function Set-RecommendedUpdateSettings {

        Show-Header
        Write-Host "Applying Recommended Windows Update Settings . . ."

    # Windows Update AU settings
    $auPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
    New-Item -Path $auPath -Force | Out-Null
    Set-ItemProperty -Path $auPath -Name "NoAutoUpdate" -Value 1 -Type DWord
    Set-ItemProperty -Path $auPath -Name "AUOptions" -Value 2 -Type DWord
    Set-ItemProperty -Path $auPath -Name "AutoInstallMinorUpdates" -Value 0 -Type DWord

    # Windows Update general settings
    $wuPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
    New-Item -Path $wuPath -Force | Out-Null
    Set-ItemProperty -Path $wuPath -Name "TargetReleaseVersion" -Value 1 -Type DWord
    Set-ItemProperty -Path $wuPath -Name "TargetReleaseVersionInfo" -Value "22H2" -Type String
    Set-ItemProperty -Path $wuPath -Name "ProductVersion" -Value "Windows 10" -Type String
    Set-ItemProperty -Path $wuPath -Name "DeferFeatureUpdates" -Value 1 -Type DWord
    Set-ItemProperty -Path $wuPath -Name "DeferFeatureUpdatesPeriodInDays" -Value 365 -Type DWord
    Set-ItemProperty -Path $wuPath -Name "DeferQualityUpdates" -Value 1 -Type DWord
    Set-ItemProperty -Path $wuPath -Name "DeferQualityUpdatesPeriodInDays" -Value 7 -Type DWord

    # Delivery Optimization
    $doPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization"
    New-Item -Path $doPath -Force | Out-Null
    Set-ItemProperty -Path $doPath -Name "DODownloadMode" -Value 0 -Type DWord

        Show-Header
        Write-Host "Recommended Windows Update Settings Applied." -ForegroundColor Green
		
		Start-Sleep -Seconds 2
}


# Default Update Settings
Function Set-DefaultUpdateSettings {

    Show-Header
    Write-Host "Applying Default Windows Update Settings . . ."

    # Revert AU settings
    $auPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
    Remove-ItemProperty -Path $auPath -Name "NoAutoUpdate" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path $auPath -Name "AUOptions" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path $auPath -Name "AutoInstallMinorUpdates" -ErrorAction SilentlyContinue

    # Revert Windows Update general settings
    $wuPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
    Remove-ItemProperty -Path $wuPath -Name "TargetReleaseVersion" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path $wuPath -Name "TargetReleaseVersionInfo" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path $wuPath -Name "ProductVersion" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path $wuPath -Name "DeferFeatureUpdates" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path $wuPath -Name "DeferFeatureUpdatesPeriodInDays" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path $wuPath -Name "DeferQualityUpdates" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path $wuPath -Name "DeferQualityUpdatesPeriodInDays" -ErrorAction SilentlyContinue

    # Revert Delivery Optimization
    $doPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization"
    Remove-ItemProperty -Path $doPath -Name "DODownloadMode" -ErrorAction SilentlyContinue

    Show-Header
    Write-Host "Default Windows Update Settings Applied." -ForegroundColor Green
	
	Start-Sleep -Seconds 2
}





#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
# 														4. Optimize Registry


Function Show-OptimizeRegistryMenu {
    Clear-Host
	Show-Header
    Write-Host "=== Optimize Registry Menu ===" -ForegroundColor Cyan
    Write-Host "1. Recommended Local Machine Tweaks"
    Write-Host "2. Default Local Machine Tweaks"
    Write-Host "3. Recommended User Tweaks"
    Write-Host "4. Default User Tweaks"
    Write-Host "0. Back to Main Menu"

    Write-Host ""
    $choice = Read-Host "Select an option"
    switch ($choice) {
		"1" { Set-RecommendedHKLMRegistry }  
        "2" { Set-DefaultHKLMRegistry } 
        "3" { Set-RecommendedHKCURegistry } 
        "4" { Set-DefaultHKCURegistry } 
        "0" { Show-MuchilityMainMenu }
        default { Write-Host "Selected: $choice"; Show-OptimizeRegistryMenu }
    }
}





# Recommended HKLM
Function Set-RecommendedHKLMRegistry {

    Show-Header
	# --Application and Feature Restrictions--

# Prevent Dev Home Installation
Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\DevHomeUpdate" -Force -ErrorAction SilentlyContinue

# Prevent New Outlook for Windows Installation
Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\OutlookUpdate" -Force -ErrorAction SilentlyContinue

# Prevent Chat Auto Installation and Remove Chat Icon
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Communications" -Name "ConfigureChatAutoInstall" -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Chat" -Name "ChatIcon" -PropertyType DWord -Value 3 -Force

# Disable Enhanced Storage TCG Security Activation
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EnhancedStorageDevices" -Name "TCGSecurityActivationDisabled" -PropertyType DWord -Value 1 -Force

# Disable Cortana
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -PropertyType DWord -Value 0 -Force

# Disable Wifi-Sense
New-ItemProperty -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Name "Value" -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Name "Value" -PropertyType DWord -Value 0 -Force

# Disable Tablet Mode
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ImmersiveShell" -Name "TabletMode" -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ImmersiveShell" -Name "SignInMode" -PropertyType DWord -Value 1 -Force

# Disable Xbox GameDVR
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -PropertyType DWord -Value 0 -Force

# Disable OneDrive Automatic Backups of Important Folders
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\OneDrive" -Name "KFMBlockOptIn" -PropertyType DWord -Value 1 -Force

# Disable "Push To Install" feature
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\PushToInstall" -Name "DisablePushToInstall" -PropertyType DWord -Value 1 -Force

# Disable Windows Consumer Features
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\CloudContent" -Name "DisableConsumerAccountStateContent" -PropertyType DWord -Value 1 -Force
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\CloudContent" -Name "DisableCloudOptimizedContent" -PropertyType DWord -Value 1 -Force

# Block "Allow my organization to manage my device" pop-ups
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WorkplaceJoin" -Name "BlockAADWorkplaceJoin" -PropertyType DWord -Value 1 -Force

# --Start Menu Customization--
# Remove all pinned apps from the Start Menu
$pinnedJson = '{ "pinnedList": [] }'

New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Start" -Name "ConfigureStartPins" -PropertyType String -Value $pinnedJson -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Start" -Name "ConfigureStartPins_ProviderSet" -PropertyType DWord -Value 1 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Start" -Name "ConfigureStartPins_WinningProvider" -PropertyType String -Value "B5292708-1619-419B-9923-E5D9F3925E71" -Force

New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\providers\B5292708-1619-419B-9923-E5D9F3925E71\default\Device\Start" -Name "ConfigureStartPins" -PropertyType String -Value $pinnedJson -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\providers\B5292708-1619-419B-9923-E5D9F3925E71\default\Device\Start" -Name "ConfigureStartPins_LastWrite" -PropertyType DWord -Value 1 -Force

# --File System Settings--
# Enable long file paths
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -PropertyType DWord -Value 1 -Force

# --Multimedia and Gaming Performance--
# Multimedia apps priority
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -PropertyType DWord -Value 10 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -PropertyType DWord -Value 10 -Force

# Games task scheduling priority
$gameTaskPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
New-ItemProperty -Path $gameTaskPath -Name "GPU Priority" -PropertyType DWord -Value 8 -Force
New-ItemProperty -Path $gameTaskPath -Name "Priority" -PropertyType DWord -Value 6 -Force
New-ItemProperty -Path $gameTaskPath -Name "Scheduling Category" -PropertyType String -Value "High" -Force

# --NETWORK AND INTERNET--
# Disable "allow other network users to control or disable shared internet connection"
New-ItemProperty -Path "HKLM:\System\ControlSet001\Control\Network\SharedAccessConnection" -Name "EnableControl" -PropertyType DWord -Value 0 -Force

# --SYSTEM AND SECURITY--
# Adjust for best performance of programs
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -PropertyType DWord -Value 38 -Force

# Disable remote assistance
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -PropertyType DWord -Value 0 -Force

# --TROUBLESHOOTING--
# Disable automatic maintenance
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" -Name "MaintenanceDisabled" -PropertyType DWord -Value 1 -Force

# --SECURITY AND MAINTENANCE--
# Disable "report problems"
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" -Name "Disabled" -PropertyType DWord -Value 1 -Force

# --ACCOUNTS--
# Disable "use my sign in info after restart"
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableAutomaticRestartSignOn" -PropertyType DWord -Value 1 -Force

# --APPS--
# Disable automatic app archiving
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Appx" -Name "AllowAutomaticAppArchiving" -PropertyType DWord -Value 0 -Force

# --SYSTEM--
# Turn on hardware accelerated GPU scheduling
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -PropertyType DWord -Value 2 -Force

# Disable Storage Sense
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\StorageSense" -Name "AllowStorageSenseGlobal" -PropertyType DWord -Value 0 -Force

# --OTHER--
# Disable automatic updates for Microsoft Store apps
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore" -Name "AutoDownload" -PropertyType DWord -Value 2 -Force

# Disable background apps
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsRunInBackground" -PropertyType DWord -Value 2 -Force

# Disable Widgets / News and Interests
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\NewsAndInterests\AllowNewsAndInterests" -Name "value" -PropertyType DWord -Value 0 -Force

# --REMOVE UNWANTED FOLDERS--
# Remove 3D Objects
Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" -Force -ErrorAction SilentlyContinue

# Remove Home Folder
Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}" -Force -ErrorAction SilentlyContinue

# --DEFAULT USER MOUSE SETTINGS--
New-ItemProperty -Path "HKU\.DEFAULT\Control Panel\Mouse" -Name "MouseSpeed" -PropertyType String -Value "0" -Force
New-ItemProperty -Path "HKU\.DEFAULT\Control Panel\Mouse" -Name "MouseThreshold1" -PropertyType String -Value "0" -Force
New-ItemProperty -Path "HKU\.DEFAULT\Control Panel\Mouse" -Name "MouseThreshold2" -PropertyType String -Value "0" -Force

   
    Show-Header
    Write-Host "Recommended Local Machine Registry Settings Applied." -ForegroundColor Green
	
	Start-Sleep -Seconds 2
}


# Default HKLM
function Set-DefaultHKLMRegistry {
	Show-Header
# --Revert Application and Feature Restrictions--

# Allows Dev Home Installation
New-Item -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\DevHomeUpdate" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\DevHomeUpdate" -Name "(Default)" -Value ""

# Allows New Outlook for Windows Installation
New-Item -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\OutlookUpdate" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\OutlookUpdate" -Name "(Default)" -Value ""

# Reverts Chat Auto Installation and Restores Chat Icon
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Communications" -Name "ConfigureChatAutoInstall" -Value 1 -Type DWord
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Chat" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Chat" -Name "ChatIcon" -Value 1 -Type DWord

# Revert Enhanced Storage Devices TCG Security Activation
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EnhancedStorageDevices" -Name "TCGSecurityActivationDisabled" -ErrorAction SilentlyContinue

# Enables Cortana
Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -ErrorAction SilentlyContinue

# Re-enables WiFi-Sense
Set-ItemProperty -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Name "Value" -Value 1 -Type DWord
Set-ItemProperty -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Name "Value" -Value 1 -Type DWord

# Enables Tablet Mode
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ImmersiveShell" -Name "TabletMode" -Value 1 -Type DWord
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ImmersiveShell" -Name "SignInMode" -Value 0 -Type DWord

# Enables Xbox GameDVR
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -ErrorAction SilentlyContinue

# Enables OneDrive Automatic Backups of Important Folders
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\OneDrive" -Name "KFMBlockOptIn" -ErrorAction SilentlyContinue

# Enables "Push To Install" feature in Windows
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\PushToInstall" -Name "DisablePushToInstall" -ErrorAction SilentlyContinue

# Enables Windows Consumer Features
Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\CloudContent" -Name "DisableConsumerAccountStateContent" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\CloudContent" -Name "DisableCloudOptimizedContent" -ErrorAction SilentlyContinue

# Unblocks "Allow my organization to manage my device" pop-up message
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WorkplaceJoin" -Name "BlockAADWorkplaceJoin" -ErrorAction SilentlyContinue

# --Revert Start Menu Customization--

# Restore Default Pinned Apps to the Start Menu
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Start" -Name "ConfigureStartPins" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Start" -Name "ConfigureStartPins_ProviderSet" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Start" -Name "ConfigureStartPins_WinningProvider" -ErrorAction SilentlyContinue

Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\providers\B5292708-1619-419B-9923-E5D9F3925E71\default\Device\Start" -Name "ConfigureStartPins" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\providers\B5292708-1619-419B-9923-E5D9F3925E71\default\Device\Start" -Name "ConfigureStartPins_LastWrite" -ErrorAction SilentlyContinue

# --Revert File System Settings--

# Revert Long File Paths to Default (Disabled)
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 0 -Type DWord

# --Revert Multimedia and Gaming Performance--

# Reverts Multimedia Applications' System Responsiveness and Network Throttling Index to Default Values
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Value 20 -Type DWord
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -Type DWord

# --Revert Gaming Performance--

# Reverts Graphics Cards Priority for Gaming to Default
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "GPU Priority" -Value 2 -Type DWord

# Reverts CPU Priority for Gaming to Default
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "Priority" -Value 2 -Type DWord

# Reverts Games Scheduling Category to Default
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "Scheduling Category" -Value "Medium" -Type String
# --NETWORK AND INTERNET--
# Allow other network users to control or disable the shared internet connection
Set-ItemProperty -Path "HKLM:\System\ControlSet001\Control\Network\SharedAccessConnection" -Name "EnableControl" -Value 1 -Type DWord

# --SYSTEM AND SECURITY--
# Revert adjust for best performance of programs
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 2 -Type DWord

# Remote assistance
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Value 1 -Type DWord

# --TROUBLESHOOTING--
# Automatic maintenance
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" -Name "MaintenanceDisabled" -ErrorAction SilentlyContinue

# --ACCOUNTS--
# Use my sign in info after restart
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableAutomaticRestartSignOn" -ErrorAction SilentlyContinue

# --APPS--
# Archive apps
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Appx" -Name "AllowAutomaticAppArchiving" -ErrorAction SilentlyContinue

# --SYSTEM--
# Hardware accelerated GPU scheduling
Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -ErrorAction SilentlyContinue

# Storage Sense
Remove-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\StorageSense" -Recurse -ErrorAction SilentlyContinue

# Enable update Microsoft Store apps automatically
Remove-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore" -Recurse -ErrorAction SilentlyContinue

# --UWP APPS--
# Background apps
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsRunInBackground" -ErrorAction SilentlyContinue

# Widgets
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\NewsAndInterests\AllowNewsAndInterests" -Name "value" -Value 1 -Type DWord

# --OTHER--
# 3D Objects (restore if missing)
New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" -Force | Out-Null
New-Item -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" -Force | Out-Null

# Restores Home Folder
New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}" -Name "(Default)" -Value "CLSID_MSGraphHomeFolder"

# --MOUSE SETTINGS--
Set-ItemProperty -Path "HKU\.DEFAULT\Control Panel\Mouse" -Name "MouseSpeed" -Value "1" -Type String
Set-ItemProperty -Path "HKU\.DEFAULT\Control Panel\Mouse" -Name "MouseThreshold1" -Value "6" -Type String
Set-ItemProperty -Path "HKU\.DEFAULT\Control Panel\Mouse" -Name "MouseThreshold2" -Value "10" -Type String

Show-Header
    Write-Host "Default Local Machine Registry Settings Applied." -ForegroundColor Green
	
	Start-Sleep -Seconds 2
}


# Recommended HKCU
function Set-RecommendedHKCURegistry {
# EASE OF ACCESS - Disable Narrator
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Narrator\NoRoam" -Name "DuckAudio" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Narrator\NoRoam" -Name "WinEnterLaunchEnabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Narrator\NoRoam" -Name "ScriptingEnabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Narrator\NoRoam" -Name "OnlineServicesEnabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Narrator\NoRoam" -Name "EchoToggleKeys" -Type DWord -Value 0

# Disable Narrator settings
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Narrator" -Name "NarratorCursorHighlight" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Narrator" -Name "CoupleNarratorCursorKeyboard" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Narrator" -Name "IntonationPause" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Narrator" -Name "ReadHints" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Narrator" -Name "ErrorNotificationType" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Narrator" -Name "EchoChars" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Narrator" -Name "EchoWords" -Type DWord -Value 0

# Control Panel Accessibility
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility" -Name "Sound on Activation" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility" -Name "Warning Sounds" -Type DWord -Value 0

# High Contrast
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\HighContrast" -Name "Flags" -Type String -Value "4194"

# Keyboard Response
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\Keyboard Response" -Name "Flags" -Type String -Value "2"
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\Keyboard Response" -Name "AutoRepeatRate" -Type String -Value "0"
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\Keyboard Response" -Name "AutoRepeatDelay" -Type String -Value "0"

# Mouse Keys
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\MouseKeys" -Name "Flags" -Type String -Value "130"
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\MouseKeys" -Name "MaximumSpeed" -Type String -Value "39"
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\MouseKeys" -Name "TimeToMaximumSpeed" -Type String -Value "3000"

# Sticky Keys
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "Flags" -Type String -Value "2"

# Toggle Keys
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\ToggleKeys" -Name "Flags" -Type String -Value "34"

# Sound Sentry
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\SoundSentry" -Name "Flags" -Type String -Value "0"
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\SoundSentry" -Name "FSTextEffect" -Type String -Value "0"
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\SoundSentry" -Name "TextEffect" -Type String -Value "0"
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\SoundSentry" -Name "WindowsEffect" -Type String -Value "0"

# Slate Launch
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\SlateLaunch" -Name "ATapp" -Type String -Value ""
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\SlateLaunch" -Name "LaunchAT" -Type DWord -Value 0


# Disable enhance pointer precision / mouse fix
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Type String -Value "0"
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Type String -Value "0"
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Type String -Value "0"
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSensitivity" -Type String -Value "10"

# Hex values (binary type in registry)
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "SmoothMouseXCurve" -Type Binary -Value ([byte[]](0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
                                                                                                 0xC0,0xCC,0x0C,0x00,0x00,0x00,0x00,0x00,
                                                                                                 0x80,0x99,0x19,0x00,0x00,0x00,0x00,0x00,
                                                                                                 0x40,0x66,0x26,0x00,0x00,0x00,0x00,0x00,
                                                                                                 0x00,0x33,0x33,0x00,0x00,0x00,0x00,0x00))

Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "SmoothMouseYCurve" -Type Binary -Value ([byte[]](0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
                                                                                                 0x00,0x00,0x38,0x00,0x00,0x00,0x00,0x00,
                                                                                                 0x00,0x00,0x70,0x00,0x00,0x00,0x00,0x00,
                                                                                                 0x00,0x00,0xA8,0x00,0x00,0x00,0x00,0x00,
                                                                                                 0x00,0x00,0xE0,0x00,0x00,0x00,0x00,0x00))





# Disable locally relevant content based on language list
Set-ItemProperty -Path "HKCU:\Control Panel\International\User Profile" -Name "HttpAcceptLanguageOptOut" -Type DWord -Value 1


# Disable input personalization / contact harvesting
Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts" -Type DWord -Value 0

# Privacy policy not accepted
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -Type DWord -Value 0

# Feedback frequency never
# The registry line "PeriodInNanoSeconds"=- means it should be deleted
Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -Name "PeriodInNanoSeconds" -ErrorAction SilentlyContinue

# GAMING
# Disable Game Bar
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Type DWord -Value 0

# Disable open Xbox Game Bar with controller / Enable Game Mode
Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "UseNexusForGameBarEnabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AutoGameModeEnabled" -Type DWord -Value 1


# SYSTEM
# Disable DPI Scaling in DWM
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\DWM" -Name "UseDpiScaling" -Type DWord -Value 0


# NOTIFICATIONS
# Disable notifications and lock screen toasts
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "ToastEnabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "LockScreenToastEnabled" -Type DWord -Value 0

# Disable notification sounds, lock screen toasts, reminders/VoIP calls
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" -Name "NOC_GLOBAL_SETTING_ALLOW_NOTIFICATION_SOUND" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" -Name "NOC_GLOBAL_SETTING_ALLOW_TOASTS_ABOVE_LOCK" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" -Name "NOC_GLOBAL_SETTING_ALLOW_CRITICAL_TOASTS_ABOVE_LOCK" -Type DWord -Value 0

# Disable specific notification categories
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\windows.immersivecontrolpanel_cw5n1h2txyewy!microsoft.windows.immersivecontrolpanel" -Name "Enabled" -Type DWord -Value 0


# Disable Windows Input Experience preload
Set-ItemProperty -Path "HKCU:\Software\Microsoft\input" -Name "IsInputAppPreloadEnabled" -Type DWord -Value 0

# Remove OneDrive Setup (delete key/value)
Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "OneDriveSetup" -ErrorAction SilentlyContinue

		Write-Host "Recommended User Tweaks Applied!" -ForegroundColor Green
		
		Start-Sleep -Seconds 2
}


# Default HKCU
function Set-DefaultHKCURegistry {
# --LEGACY CONTROL PANEL--
# EASE OF ACCESS

# narrator
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Narrator\NoRoam" -Name "DuckAudio" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Narrator\NoRoam" -Name "WinEnterLaunchEnabled" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Narrator\NoRoam" -Name "ScriptingEnabled" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Narrator\NoRoam" -Name "OnlineServicesEnabled" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Narrator\NoRoam" -Name "EchoToggleKeys" -ErrorAction SilentlyContinue

# narrator settings
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Narrator" -Name "NarratorCursorHighlight" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Narrator" -Name "CoupleNarratorCursorKeyboard" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Narrator" -Name "IntonationPause" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Narrator" -Name "ReadHints" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Narrator" -Name "ErrorNotificationType" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Narrator" -Name "EchoChars" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Narrator" -Name "EchoWords" -ErrorAction SilentlyContinue

# delete narrator home
Remove-Item -Path "HKCU:\SOFTWARE\Microsoft\Narrator\NarratorHome" -Recurse -Force -ErrorAction SilentlyContinue

# delete ease of access settings
Remove-Item -Path "HKCU:\Software\Microsoft\Ease of Access" -Recurse -Force -ErrorAction SilentlyContinue

# accessibility root
Remove-ItemProperty -Path "HKCU:\Control Panel\Accessibility" -Name "Sound on Activation" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKCU:\Control Panel\Accessibility" -Name "Warning Sounds" -ErrorAction SilentlyContinue

# high contrast
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\HighContrast" -Name "Flags" -Value "126"

# keyboard response
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\Keyboard Response" -Name "Flags" -Value "126"
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\Keyboard Response" -Name "AutoRepeatRate" -Value "500"
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\Keyboard Response" -Name "AutoRepeatDelay" -Value "1000"

# mouse keys
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\MouseKeys" -Name "Flags" -Value "62"
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\MouseKeys" -Name "MaximumSpeed" -Value "80"
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\MouseKeys" -Name "TimeToMaximumSpeed" -Value "3000"

# sticky keys
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "Flags" -Value "510"

# toggle keys
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\ToggleKeys" -Name "Flags" -Value "62"

# sound sentry
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\SoundSentry" -Name "Flags" -Value "2"
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\SoundSentry" -Name "FSTextEffect" -Value "0"
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\SoundSentry" -Name "TextEffect" -Value "0"
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\SoundSentry" -Name "WindowsEffect" -Value "1"

# slate launch
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\SlateLaunch" -Name "ATapp" -Value "narrator"
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\SlateLaunch" -Name "LaunchAT" -Value 1

# --CLOCK AND REGION--

# notify me when the clock changes
Remove-Item -Path "HKCU:\Control Panel\TimeDate" -Recurse -Force -ErrorAction SilentlyContinue

# enhance pointer precision (default accel with EPP on)
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value "1"
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value "6"
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value "10"
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSensitivity" -Value "10"
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "SmoothMouseXCurve" -Value ([byte[]](0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x15,0x6e,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x40,0x01,0x00,0x00,0x00,0x00,0x00,0x29,0xdc,0x03,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x28,0x00,0x00,0x00,0x00,0x00))
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "SmoothMouseYCurve" -Value ([byte[]](0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xfd,0x11,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x24,0x04,0x00,0x00,0x00,0x00,0x00,0x00,0xfc,0x12,0x00,0x00,0x00,0x00,0x00,0x00,0xc0,0xbb,0x01,0x00,0x00,0x00,0x00))

# --IMMERSIVE CONTROL PANEL--
# PRIVACY

# show me notifications in the settings app
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\SystemSettings\AccountNotifications" -Name "EnableAccountNotifications" -ErrorAction SilentlyContinue

# voice activation
Remove-Item -Path "HKCU:\Software\Microsoft\Speech_OneCore\Settings" -Recurse -Force -ErrorAction SilentlyContinue

# let websites show me locally relevant content by accessing my language list
Remove-ItemProperty -Path "HKCU:\Control Panel\International\User Profile" -Name "HttpAcceptLanguageOptOut" -ErrorAction SilentlyContinue

# let windows improve start and search results by tracking app launches
Remove-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\EdgeUI" -Recurse -Force -ErrorAction SilentlyContinue

# input personalization
Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts" -Value 1

# personalization settings
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -Value 1

# feedback frequency
Remove-Item -Path "HKCU:\SOFTWARE\Microsoft\Siuf" -Recurse -Force -ErrorAction SilentlyContinue

# --GAMING--

# game bar
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0

# xbox game bar using controller & game mode
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "UseNexusForGameBarEnabled" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AutoGameModeEnabled" -ErrorAction SilentlyContinue

# --SYSTEM--

# DWM scaling
Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\DWM" -Name "UseDpiScaling" -ErrorAction SilentlyContinue

# variable refresh rate & optimizations for windowed games
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\DirectX\UserGpuPreferences" -Name "DirectXUserGlobalSettings" -ErrorAction SilentlyContinue

# notification defaults
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "ToastEnabled" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "LockScreenToastEnabled" -ErrorAction SilentlyContinue

Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" -Name "NOC_GLOBAL_SETTING_ALLOW_NOTIFICATION_SOUND" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" -Name "NOC_GLOBAL_SETTING_ALLOW_TOASTS_ABOVE_LOCK" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" -Name "NOC_GLOBAL_SETTING_ALLOW_CRITICAL_TOASTS_ABOVE_LOCK" -ErrorAction SilentlyContinue

Remove-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" -Recurse -Force -ErrorAction SilentlyContinue

Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\windows.immersivecontrolpanel_cw5n1h2txyewy!microsoft.windows.immersivecontrolpanel" -Name "Enabled" -ErrorAction SilentlyContinue

Remove-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.CapabilityAccess" -Recurse -Force -ErrorAction SilentlyContinue

Remove-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\UserProfileEngagement" -Recurse -Force -ErrorAction SilentlyContinue

# suggested actions
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\SmartActionPlatform\SmartClipboard" -Name "Disabled" -ErrorAction SilentlyContinue

# battery options optimize
Remove-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\VideoSettings" -Recurse -Force -ErrorAction SilentlyContinue

# --UWP APPS--

# disable windows input experience preload
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\input" -Name "IsInputAppPreloadEnabled" -ErrorAction SilentlyContinue

Remove-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Dsh" -Recurse -Force -ErrorAction SilentlyContinue

# copilot
Remove-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" -Recurse -Force -ErrorAction SilentlyContinue

# --OTHER--

# gallery
Remove-Item -Path "HKCU:\Software\Classes\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}" -Recurse -Force -ErrorAction SilentlyContinue

		Write-Host "Default User Tweaks Applied!" -ForegroundColor Green
		
		Start-Sleep -Seconds 2
}





#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
# 														5. Tasks & Services


Function Show-TasksServicesMenu {
    Clear-Host
	Show-Header
    Write-Host "=== Tasks & Services Menu ===" -ForegroundColor Cyan
    Write-Host "1. Recommended Services"
    Write-Host "2. Default Services"
    Write-Host "3. Recommended Scheduled Tasks"
    Write-Host "4. Default Scheduled Tasks"
    Write-Host "0. Back to Main Menu"

    Write-Host ""
    $choice = Read-Host "Select an option"
    switch ($choice) {
		"1" { Set-ServiceStartup }  
        "2" { Set-DefaultServices } 
        "3" { Disable-ScheduledTasks } 
        "4" { Enable-ScheduledTasks } 
        "0" { Show-MuchilityMainMenu }
        default { Write-Host "Selected: $choice"; Show-TasksServicesMenu }
    }
}




# Recommended Services
function Set-ServiceStartup {
	clear-host
    # List of services to set to Disabled
    $disabledServices = @(
    'AJRouter', 'AppVClient', 'AssignedAccessManagerSvc', 
    'DiagTrack', 'DialogBlockingService', 'NetTcpPortSharing',
    'RemoteAccess', 'RemoteRegistry', 'shpamsvc', 
    'ssh-agent', 'tzautoupdate', 'uhssvc',
    'UevAgentService'
	)

    # List of services to set to Manual
    $manualServices = @(
    'ALG', 'AppIDSvc', 'AppMgmt', 'AppReadiness', 'AppXSvc', 'Appinfo',
    'AxInstSV', 'BDESVC', 'BITS', 'BTAGService', 'BcastDVRUserService_*',
    'Browser', 'CDPSvc', 'CDPUserSvc_*', 'COMSysApp', 'CaptureService_*',
    'CertPropSvc', 'ClipSVC', 'ConsentUxUserSvc_*', 'CscService', 'DcpSvc',
    'DevQueryBroker', 'DeviceAssociationBrokerSvc_*', 'DeviceAssociationService', 
    'DeviceInstall', 'DevicePickerUserSvc_*', 'DevicesFlowUserSvc_*', 
    'DisplayEnhancementService', 'DmEnrollmentSvc', 'DoSvc', 'DsSvc', 'DsmSvc',
    'EFS', 'EapHost', 'EntAppSvc', 'FDResPub', 'Fax', 'FrameServer',
    'FrameServerMonitor', 'GraphicsPerfSvc', 'HomeGroupListener', 
    'HomeGroupProvider', 'HvHost', 'IEEtwCollectorService', 'IKEEXT',
    'InstallService', 'InventorySvc', 'IpxlatCfgSvc', 'KtmRm', 'LicenseManager',
    'LxpSvc', 'MSDTC', 'MSiSCSI', 'MapsBroker', 'McpManagementService', 
    'MessagingService_*', 'MicrosoftEdgeElevationService', 
    'MixedRealityOpenXRSvc', 'MsKeyboardFilter', 'NPSMSvc_*', 'NaturalAuthentication',
    'NcaSvc', 'NcbService', 'NcdAutoSetup', 'Netman', 'NgcCtnrSvc', 'NgcSvc',
    'NlaSvc', 'P9RdrService_*', 'PNRPAutoReg', 'PNRPsvc', 'PcaSvc', 'PeerDistSvc',
    'PenService_*', 'PerfHost', 'PhoneSvc', 'PimIndexMaintenanceSvc_*', 'PlugPlay',
    'PolicyAgent', 'PrintNotify', 'PrintWorkflowUserSvc_*', 'PushToInstall', 'QWAVE',
    'RasAuto', 'RasMan', 'RetailDemo', 'RmSvc', 'RpcLocator', 'SCPolicySvc',
    'SCardSvr', 'SDRSVC', 'SEMgrSvc', 'SecurityHealthService', 
    'SensorDataService', 'SensorService', 'SensrSvc', 'SessionEnv', 
    'SharedAccess', 'SharedRealitySvc', 'SmsRouter', 'SstpSvc', 
    'StateRepository', 'StiSvc', 'StorSvc', 'TabletInputService', 'TapiSrv',
    'TextInputManagementService', 'TieringEngineService', 'TimeBroker',
    'TimeBrokerSvc', 'TokenBroker', 'TroubleshootingSvc', 'TrustedInstaller',
    'UI0Detect', 'UdkUserSvc_*', 'UmRdpService', 'UnistoreSvc_*', 
    'UserDataSvc_*', 'UsoSvc', 'VSS', 'VacSvc', 'W32Time', 'WEPHOSTSVC',
    'WFDSConMgrSvc', 'WMPNetworkSvc', 'WManSvc', 'WPDBusEnum', 'WSService',
    'WSearch', 'WaaSMedicSvc', 'WalletService', 'WarpJITSvc', 'WbioSrvc',
    'WcsPlugInService', 'WdiServiceHost', 'WdiSystemHost', 'WebClient', 'Wecsvc',
    'WerSvc', 'WiaRpc', 'WinHttpAutoProxySvc', 'WinRM', 'WpcMonSvc', 
    'WpnService', 'WwanSvc', 'XblAuthManager', 'XblGameSave', 'XboxGipSvc', 
    'XboxNetApiSvc', 'autotimesvc', 'bthserv', 'camsvc', 'cbdhsvc_*',
    'cloudidsvc', 'dcsvc', 'defragsvc', 'diagnosticshub.standardcollector.service',
    'diagsvc', 'dmwappushservice', 'dot3svc', 'edgeupdate', 'edgeupdatem', 
    'embeddedmode', 'fdPHost', 'fhsvc', 'hidserv', 'icssvc', 'lfsvc', 
    'lltdsvc', 'lmhosts', 'msiserver', 'netprofm', 'p2pimsvc', 'p2psvc', 
    'perceptionsimulation', 'pla', 'seclogon', 'smphost', 'spectrum', 
    'sppsvc', 'svsvc', 'swprv', 'upnphost', 'vds', 'vm3dservice', 
    'vmicguestinterface', 'vmicheartbeat', 'vmickvpexchange', 'vmicrdv', 
    'vmicshutdown', 'vmictimesync', 'vmicvmsession', 'vmicvss', 'wbengine', 
    'wcncsvc', 'webthreatdefsvc', 'wercplsupport', 'wisvc', 'wlidsvc', 
    'wlpasvc', 'wmiApSrv', 'workfolderssvc', 'wuauserv', 'wudfsvc'
    )

    # Set the services in the disabledServices list to Disabled
    foreach ($service in $disabledServices) {
    try {
        $svc = Get-Service -Name $service -ErrorAction SilentlyContinue
        if ($null -eq $svc) {
            Write-Host "$service not found" -ForegroundColor DarkGray
            continue
        }

        $currentStartup = (Get-WmiObject -Class Win32_Service -Filter "Name='$service'").StartMode

        if ($currentStartup -eq 'Disabled') {
            Write-Host "$service is already disabled :)" -ForegroundColor Green
        } else {
            Write-Host "$currentStartup > Disabled" -ForegroundColor Cyan
            Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue | Out-Null
        }
    }
    catch {
        Show-Header
        Write-Host "Failed to set $service to Disabled: $_" -ForegroundColor Yellow
    }
}


	Start-Sleep -Seconds 3
	
	
    # Set the services in the manualServices list to Manual
    foreach ($service in $manualServices) {
    try {
        $svc = Get-Service -Name $service -ErrorAction SilentlyContinue
        if ($null -eq $svc) {
            Write-Host "$service not found" -ForegroundColor DarkGray
            continue
        }

        $currentStartup = (Get-WmiObject -Class Win32_Service -Filter "Name='$service'").StartMode

        if ($currentStartup -eq 'Manual') {
            Write-Host "$service is already set to Manual :)" -ForegroundColor Green
        } else {
            Write-Host "$currentStartup > Manual" -ForegroundColor Cyan
            Set-Service -Name $service -StartupType Manual -ErrorAction SilentlyContinue | Out-Null
        }
    }
    catch {
        Show-Header
        Write-Host "Failed to set $service to Manual: $_" -ForegroundColor Yellow
    }
}


    Show-Header
    Write-Host "Service startup types updated successfully." -ForegroundColor Green
    
	Start-Sleep -Seconds 2
}


# Default Services
function Set-DefaultServices {
	clear-host
    # Get all services that are not currently set to Automatic and revert them
    $allServices = Get-Service | Where-Object { $_.StartType -ne 'Automatic' }

    $successCount = 0
    foreach ($service in $allServices) {
        try {
            Show-Header
            Write-Host "Setting services to Automatic where permissions are allowed. Please wait . . ."
            # Set the service startup type to Automatic using Set-Service
            Set-Service -Name $service.Name -StartupType Automatic 2>&1 | Out-Null

            # Forcibly set the startup type to Automatic using WMI as a fallback
            $wmiService = Get-WmiObject -Class Win32_Service -Filter "Name='$($service.Name)'" 2>&1 | Out-Null
            if ($wmiService) {
                $result = $wmiService.ChangeStartMode("Automatic") 2>&1 | Out-Null
                if ($result.ReturnValue -eq 0) {
                    $successCount++
                }
            }
        }
        catch {
            # Silently continue if a service fails
            continue
        }
    }
    Show-Header
		Write-Host "Successfully set services to Automatic where permissions allowed." -ForegroundColor Green
		
		Start-Sleep -Seconds 2
}


# Recommended Scheduled Tasks
Function Disable-ScheduledTasks {
	clear-host
    $scheduledTasks = @(
        "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
        "Microsoft\Windows\Application Experience\ProgramDataUpdater",
        "Microsoft\Windows\Autochk\Proxy",
        "Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
        "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
        "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector",
        "Microsoft\Windows\Feedback\Siuf\DmClient",
        "Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload",
        "Microsoft\Windows\Windows Error Reporting\QueueReporting",
        "Microsoft\Windows\Application Experience\MareBackup",
        "Microsoft\Windows\Application Experience\StartupAppTask",
        "Microsoft\Windows\Application Experience\PcaPatchDbTask",
        "Microsoft\Windows\Maps\MapsUpdateTask"
    )

    $successCount = 0

    foreach ($task in $scheduledTasks) {
        try {
            $status = schtasks /Query /TN $task /FO LIST /V 2>$null | Select-String "Scheduled Task State"
            
            if ($status -match "Disabled") {
                Write-Host ("*" + $task + "* Is Already Disabled") -ForegroundColor Yellow
            }
            else {
                schtasks /Change /TN $task /Disable 2>$null
                Write-Host ("*" + $task + "* Now Disabled :)") -ForegroundColor Green
                $successCount++
            }
        }
        catch {
            Write-Host ("*" + $task + "* Not Found Or Failed To Disable") -ForegroundColor DarkGray
        }
    }
	Start-Sleep -Seconds 3
    Show-Header
    Write-Host "Successfully Disabled Unneeded Scheduled Tasks." -ForegroundColor Green
    Start-Sleep -Seconds 2
}


# Default Scheduled Tasks
function Enable-ScheduledTasks {
    # Define the list of scheduled tasks to enable (same as those to disable)
    $scheduledTasks = @(
        "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
        "Microsoft\Windows\Application Experience\ProgramDataUpdater",
        "Microsoft\Windows\Autochk\Proxy",
        "Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
        "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
        "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector",
        "Microsoft\Windows\Feedback\Siuf\DmClient",
        "Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload",
        "Microsoft\Windows\Windows Error Reporting\QueueReporting",
        "Microsoft\Windows\Application Experience\MareBackup",
        "Microsoft\Windows\Application Experience\StartupAppTask",
        "Microsoft\Windows\Application Experience\PcaPatchDbTask",
        "Microsoft\Windows\Maps\MapsUpdateTask"
    )

    $successCount = 0
    foreach ($task in $scheduledTasks) {
        try {
            # Disable the task without wildcards
            schtasks /Change /TN $task /Disable 2>&1 | Out-Null
            $successCount++
        }
        catch {
            # Silently continue if a task fails
            continue
        }
    }
    
    Show-Header
		Write-Host "Successfully Enabled Default scheduled tasks." -ForegroundColor Green
		
		Start-Sleep -Seconds 2
}





#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
# 														6. Power Settings


Function Show-PowerSettingsMenu {
    Clear-Host
	Show-Header
    Write-Host "=== Power Settings Menu ===" -ForegroundColor Cyan
    Write-Host "1. Recommended Power Settings"
    Write-Host "2. Default Power Settings"
    Write-Host "0. Back to Main Menu"

    Write-Host ""
    $choice = Read-Host "Select an option"
    switch ($choice) {
		"1" { Set-RecommendedPowerSettings }  
        "2" { Set-DefaultPowerSettings } 
        "0" { Show-MuchilityMainMenu }
        default { Write-Host "Selected: $choice"; Show-PowerSettingsMenu }
    }
}




# Recommended Power Settings
function Set-RecommendedPowerSettings {
    Clear-Host
    # Import and set Ultimate power plan
    cmd /c "powercfg /duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 99999999-9999-9999-9999-999999999999 >nul 2>&1 & powercfg /SETACTIVE 99999999-9999-9999-9999-999999999999 >nul 2>&1"

    # Get all power plans and delete them
    powercfg /L | ForEach-Object {
        if ($_ -match "^\s*Power Scheme GUID: (\S+)") {
            $guid = $matches[1]
            if ($guid -ne "99999999-9999-9999-9999-999999999999") {
                cmd /c "powercfg /delete $guid" | Out-Null
            }
        }
    }

    # Registry modifications
    $regChanges = @(
        'HKLM\SYSTEM\CurrentControlSet\Control\Power /v HibernateEnabled /t REG_DWORD /d 0', # Disables hibernate
        'HKLM\SYSTEM\CurrentControlSet\Control\Power /v HibernateEnabledDefault /t REG_DWORD /d 0', # Disables default hibernate settings
        'HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings /v ShowLockOption /t REG_DWORD /d 0', # Hides the Lock option from the Power menu
        'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings /v ShowSleepOption /t REG_DWORD /d 0', # Hides the Sleep option from the Power menu
        'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power /v HiberbootEnabled /t REG_DWORD /d 0', # Disables Fast Startup (Hiberboot)
        'HKLM\SYSTEM\ControlSet001\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583 /v ValueMax /t REG_DWORD /d 0', # Unparks CPU cores by setting the maximum processor state
        'HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling /v PowerThrottlingOff /t REG_DWORD /d 1', # Disables power throttling
        'HKLM\System\ControlSet001\Control\Power\PowerSettings\2a737441-1930-4402-8d77-b2bebba308a3\0853a681-27c8-4100-a2fd-82013e970683 /v Attributes /t REG_DWORD /d 2', # Unhides "Hub Selective Suspend Timeout"
        'HKLM\System\ControlSet001\Control\Power\PowerSettings\2a737441-1930-4402-8d77-b2bebba308a3\d4e98f31-5ffe-4ce1-be31-1b38b384c009 /v Attributes /t REG_DWORD /d 2' # Unhides "USB 3 Link Power Management"
    )


    foreach ($reg in $regChanges) {
        cmd /c "reg add `$reg` /f >nul 2>&1"
    }

    # Modify Power Plan settings
    $settings = @(
        @{
            SubgroupGUID = "0012ee47-9041-4b5d-9b77-535fba8b1442" # Hard Disk
            SettingGUIDs = @("6738e2c4-e8a5-4a42-b16a-e040e769756e") # Turn off hard disk after
        },
        @{
            SubgroupGUID = "0d7dbae2-4294-402a-ba8e-26777e8488cd" # Desktop Background Settings
            SettingGUIDs = @("309dce9b-bef4-4119-9921-a851fb12f0f4") # Slide show
        },
        @{
            SubgroupGUID = "19cbb8fa-5279-450e-9fac-8a3d5fedd0c1" # Wireless Adapter Settings
            SettingGUIDs = @("12bbebe6-58d6-4636-95bb-3217ef867c1a") # Power saving mode
        },
        @{
            SubgroupGUID = "238c9fa8-0aad-41ed-83f4-97be242c8f20" # Sleep
            SettingGUIDs = @(
                "29f6c1db-86da-48c5-9fdb-f2b67b1f44da", # Sleep after
                "94ac6d29-73ce-41a6-809f-6363ba21b47e", # Allow hybrid sleep
                "9d7815a6-7ee4-497e-8888-515a05f02364", # Hibernate after
                "bd3b718a-0680-4d9d-8ab2-e1d2b4ac806d"  # Allow wake timers
            )
        },
        @{
            SubgroupGUID = "2a737441-1930-4402-8d77-b2bebba308a3" # USB Settings
            SettingGUIDs = @(
                "0853a681-27c8-4100-a2fd-82013e970683", # USB selective suspend setting
                "48e6b7a6-50f5-4782-a5d4-53bb8f07e226", # USB 3 Link Power Management
                "d4e98f31-5ffe-4ce1-be31-1b38b384c009"  # USB Hub Selective Suspend Timeout
            )
        },
        @{
            SubgroupGUID = "501a4d13-42af-4429-9fd1-a8218c268e20" # PCI Express
            SettingGUIDs = @("ee12f906-d277-404b-b6da-e5fa1a576df5") # Link State Power Management
        },
        @{
            SubgroupGUID = "7516b95f-f776-4464-8c53-06167f40cc99" # Display settings
            SettingGUIDs = @("3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e") # Turn off Display After setting
        }
    )


    foreach ($group in $settings) {
        $subgroup = $group.SubgroupGUID
        foreach ($setting in $group.SettingGUIDs) {
            powercfg /setacvalueindex 99999999-9999-9999-9999-999999999999 $subgroup $setting 0x00000000
            powercfg /setdcvalueindex 99999999-9999-9999-9999-999999999999 $subgroup $setting 0x00000000
        }
    }

    if (-not $isSpecializePhase) {
        Show-Header
        Write-Host "Recommended Power Settings Applied." -ForegroundColor Green
		
		Start-Sleep -Seconds 2
    }
}


# Default Power Settings
function Set-DefaultPowerSettings {
    Clear-Host
    # Restore default power plans and enable hibernate
    powercfg -restoredefaultschemes
    cmd /c "powercfg /hibernate on >nul 2>&1"
    cmd /c "reg add `"HKLM\SYSTEM\CurrentControlSet\Control\Power`" /v `"HibernateEnabledDefault`" /t REG_DWORD /d `"1`" /f >nul 2>&1"

    # Registry modifications
    $regChanges = @(
        'HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings /v ShowLockOption /t REG_DWORD /d 1',
        'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings /v ShowSleepOption /t REG_DWORD /d 1',
        'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power /v HiberbootEnabled /t REG_DWORD /d 1',
        'HKLM\SYSTEM\ControlSet001\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583 /v ValueMax /t REG_DWORD /d 100',
        'HKLM\System\ControlSet001\Control\Power\PowerSettings\2a737441-1930-4402-8d77-b2bebba308a3\0853a681-27c8-4100-a2fd-82013e970683 /v Attributes /t REG_DWORD /d 1',
        'HKLM\System\ControlSet001\Control\Power\PowerSettings\2a737441-1930-4402-8d77-b2bebba308a3\d4e98f31-5ffe-4ce1-be31-1b38b384c009 /v Attributes /t REG_DWORD /d 1'
    )

    foreach ($reg in $regChanges) {
        cmd /c "reg add `$reg` /f >nul 2>&1"
    }

    Show-Header
    Write-Host "Default Power Settings Applied." -ForegroundColor Green
    
	Start-Sleep -Seconds 2
}






#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
# 														7. Upgrade + Activate Windows


Function Show-UpgradeActivateMenu {
    Clear-Host
	Show-Header
    Write-Host "=== Upgrade + Activate Menu ===" -ForegroundColor Cyan
    Write-Host "1. Upgrade Windows"
    Write-Host "2. Activate Windows"
    Write-Host "0. Back to Main Menu"

    Write-Host ""
    $choice = Read-Host "Select an option"
    switch ($choice) {
		"1" { Upgrade-Win }  
        "2" { Activate-Win } 
        "0" { Show-MuchilityMainMenu }
        default { Write-Host "Selected: $choice"; Show-UpgradeActivateMenu }
    }
}





# Upgrade Windows Function
Function Upgrade-Win {
    try {
        $null = sc.exe config LicenseManager start= auto > $null 2>&1
        $null = net start LicenseManager > $null 2>&1

        $null = sc.exe config wuauserv start= auto > $null 2>&1
        $null = net start wuauserv > $null 2>&1

        & "changepk.exe" /productkey "VK7JG-NPHTM-C97JM-9MPGT-3V66T"
    } catch {
        throw $_
    }
}


# Activate Windows Function
Function Activate-Win {
    Start-Process -FilePath "powershell.exe" -ArgumentList '-NoProfile -WindowStyle Normal -Command "iwr -Useb https://get.activated.win/ | iex"'
}



#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
# 														8. System Repair


# System Repair Function
Function System-Repair {
    $cmdArguments = "dism.exe /Online /Cleanup-Image /ScanHealth && dism.exe /Online /Cleanup-Image /RestoreHealth && sfc.exe /scannow && chkdsk C: /F /R /X"

    Start-Process "cmd.exe" -ArgumentList "/K $cmdArguments" -Verb RunAs
}





#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
# 														9. Clear Temp


Function Clear-Temp {
    $windowsTemp = "C:\Windows\Temp"
    $appDataTemp = [System.Environment]::GetFolderPath('LocalApplicationData') + "\Temp"
    $prefetchTemp = "C:\Windows\Prefetch"

    Function Get-FolderSize($path) {
        if (Test-Path -Path $path) {
            $bytes = (Get-ChildItem -Path $path -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
            return [math]::Round($bytes / 1MB, 2)
        }
        else { return 0 }
    }

    Function Remove-TempFolder($path) {
        if (Test-Path -Path $path) {
            Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    Clear-Host

    $folders = @(
        @{ Path = $windowsTemp; Name = "Windows Temp" },
        @{ Path = $appDataTemp; Name = "AppData Temp" },
        @{ Path = $prefetchTemp; Name = "Windows Prefetch" }
    )

    foreach ($folder in $folders) {
        $sizeBefore = Get-FolderSize $folder.Path
        Remove-TempFolder $folder.Path
        Write-Host ("Cleared " + $folder.Name + " Files - Saved " + $sizeBefore + " MB") -ForegroundColor Green
        Start-Sleep -Seconds 2
        Clear-Host
    }
}



























Show-MuchilityMainMenu





# Main loop to keep showing the main menu
while ($script:loop) {
    Show-MuchilityMainMenu
}

