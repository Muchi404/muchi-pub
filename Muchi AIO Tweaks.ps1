function Recommended-All {
	
	RemoveAndUninstall-OneDrive *> $null
    Write-Host "Onedrive Removed."
    Start-Sleep -Seconds 2
    Clear-Host
	
	Set-AppsRegistry *> $null
    Write-Host "Bloatware Reinstallation Disabled."
    Start-Sleep -Seconds 2
    Clear-Host
	
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


Recommended-All