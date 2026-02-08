
#Option 1 - Video Settings

Function ImportVideoSettings {
    Clear-Host

    $Url = "https://pastebin.com/raw/NNt2VCBr"
    $PossiblePaths = @()

    # Add default user paths
    $UserProfile = [Environment]::GetFolderPath('UserProfile')
    $PossiblePaths += Join-Path $UserProfile "Saved Games\Respawn\Apex\local"
    $PossiblePaths += Join-Path $UserProfile "Documents\Respawn\Apex\local"

    # Scan all drives for possible Apex config paths
    Get-PSDrive -PSProvider FileSystem | ForEach-Object {
        $PossiblePaths += Join-Path $_.Root "Users\$env:USERNAME\Saved Games\Respawn\Apex\local"
        $PossiblePaths += Join-Path $_.Root "Users\$env:USERNAME\Documents\Respawn\Apex\local"
    }

    Start-Sleep -Seconds 1

    # Select the first existing directory or create the first one
    $ApexConfigPath = $PossiblePaths | Where-Object { Test-Path $_ } | Select-Object -First 1
    if (-not $ApexConfigPath) {
        $ApexConfigPath = $PossiblePaths[0]
        New-Item -ItemType Directory -Path $ApexConfigPath -Force | Out-Null
    }

    Start-Sleep -Seconds 1

    $ConfigFile = Join-Path $ApexConfigPath "VideoConfig.txt"

    # ---- BACKUP STEP ----
    if (Test-Path $ConfigFile) {
        $Desktop = [Environment]::GetFolderPath('Desktop')
        $BackupFolder = Join-Path $Desktop "Apex Video Settings Backup"
        New-Item -ItemType Directory -Path $BackupFolder -Force | Out-Null

        $BackupFile = Join-Path $BackupFolder "VideoConfig_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
        Copy-Item $ConfigFile $BackupFile -Force
    }

    Start-Sleep -Seconds 1

    try {
        Invoke-WebRequest -Uri $Url -OutFile $ConfigFile -UseBasicParsing
        Start-Sleep -Seconds 1
    } catch {
        Write-Error "Failed to download or write VideoConfig.txt: $_"
        Start-Sleep -Seconds 1
    }
}



#Option 2 - Autoexec Download

Function ImportAutoExec {
	Clear-Host
# Detect all potential Steam library locations and locate Apex Legends
$CommonPaths = @()
$Drives = Get-PSDrive -PSProvider 'FileSystem' | Where-Object { $_.Free -gt 0 }

foreach ($Drive in $Drives) {
    $CommonPaths += Join-Path $Drive.Root "SteamLibrary\steamapps\common\Apex Legends"
    $CommonPaths += Join-Path $Drive.Root "Program Files (x86)\Steam\steamapps\common\Apex Legends"
    $CommonPaths += Join-Path $Drive.Root "Program Files\Steam\steamapps\common\Apex Legends"
}

# Find the first valid Apex Legends directory
$ApexPath = $CommonPaths | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $ApexPath) {
    Write-Error "Could not find Apex Legends installation on any drive."
    exit 1
}

Write-Host "Found Apex Legends directory at: $ApexPath"

# Define destination path for autoexec.cfg
$CfgDir = Join-Path $ApexPath "cfg"
$CfgFile = Join-Path $CfgDir "autoexec.cfg"

# Ensure cfg directory exists
if (!(Test-Path $CfgDir)) {
    New-Item -ItemType Directory -Path $CfgDir -Force | Out-Null
    Write-Host "Created directory: $CfgDir"
}

# Download the raw autoexec.cfg from Pastebin
$Url = "https://pastebin.com/raw/biqkk5ht"

try {
    $ConfigData = Invoke-WebRequest -Uri $Url -UseBasicParsing
    $ConfigData.Content | Set-Content -Path $CfgFile -Encoding UTF8
    Write-Host "autoexec.cfg created successfully at: $CfgFile"
} catch {
    Write-Error "Failed to download or write autoexec.cfg: $_"
}
}


#Option 3 - Create Shortcut

Function CreateApexShortcut {
Clear-Host
    Add-Type @"
    using System;
    using System.Runtime.InteropServices;

    public class IconExtractor {
        [DllImport("shell32.dll", EntryPoint = "ExtractIconEx", CharSet = CharSet.Auto)]
        public static extern int ExtractIconEx(string lpszFile, int nIconIndex, IntPtr[] phiconLarge, IntPtr[] phiconSmall, int nIcons);
    }
"@

    Write-Host "Searching for Apex Legends installation..."
    $CommonPaths = @()
    $Drives = Get-PSDrive -PSProvider 'FileSystem' | Where-Object { $_.Free -gt 0 }

    foreach ($Drive in $Drives) {
        $Root = $Drive.Root
        $CommonPaths += Join-Path $Root "SteamLibrary\steamapps\common\Apex Legends"
        $CommonPaths += Join-Path $Root "Program Files (x86)\Steam\steamapps\common\Apex Legends"
        $CommonPaths += Join-Path $Root "Program Files\Steam\steamapps\common\Apex Legends"
    }

    Start-Sleep -Seconds 1

    $ApexPath = $CommonPaths | Where-Object { Test-Path $_ } | Select-Object -First 1

    if (-not $ApexPath) {
        Write-Error "Could not find Apex Legends installation on any drive."
        Read-Host -Prompt "Press Enter to exit"
        exit 1
    }

    Write-Host "Found Apex Legends directory at: $ApexPath"
    Start-Sleep -Seconds 1

    $ExePath = Join-Path $ApexPath "r5apex_dx12.exe"
    if (-not (Test-Path $ExePath)) {
        Write-Error "Could not find r5apex_dx12.exe in $ApexPath"
        Read-Host -Prompt "Press Enter to exit"
        exit 1
    }

    Write-Host "Found Apex executable: $ExePath"
    Start-Sleep -Seconds 1

    Write-Host "Extracting icon information..."
    Start-Sleep -Seconds 1

    $IconCount = [IconExtractor]::ExtractIconEx($ExePath, -1, $null, $null, 0)

    if ($IconCount -gt 0) {
        Write-Host "Found $IconCount icons inside r5apex_dx12.exe"
        Start-Sleep -Seconds 1
        for ($i = 0; $i -lt $IconCount; $i++) {
            Write-Host "  `"$ExePath`",$i"
            Start-Sleep -Milliseconds 100
        }
    } else {
        Write-Host "No icons found in $ExePath"
        Read-Host -Prompt "Press Enter to exit"
        exit 1
    }

    Start-Sleep -Seconds 1
    Write-Host "Preparing to create desktop shortcut..."
    Start-Sleep -Seconds 1

    $SteamExe = "C:\Program Files (x86)\Steam\steam.exe"
    $Args = '-applaunch 1172470 +exec autoexec -novid -forcenovsync +cl_showfps 4e +cl_showpos 2 +fps_max 0 +m_rawinput 1 -dxlevel95 -high -preload +lobby_fps_max 0 -no_render_on_input_thread'
    $Desktop = [Environment]::GetFolderPath("Desktop")
    $ShortcutPath = Join-Path $Desktop "Apex + Launch Options.lnk"

    Write-Host "Creating shortcut on desktop..."
    Start-Sleep -Seconds 1

    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
    $Shortcut.TargetPath = $SteamExe
    $Shortcut.Arguments = $Args
    $Shortcut.WorkingDirectory = Split-Path $SteamExe
    $Shortcut.IconLocation = "`"$ExePath`",0"
    $Shortcut.Save()

    Start-Sleep -Seconds 1
    Write-Host "Shortcut created successfully!"
    Write-Host "Location: $ShortcutPath"
    Start-Sleep -Seconds 2
}


#Option 4 - Import KB + Roller Settings

Function ImportKBRollerSettings {
	Clear-Host
    $ConfigURL = "https://muchi.online/settings.cfg"
    $PossiblePaths = @()

    # Check all drives for 'Saved Games\Respawn\Apex\local'
    $Drives = Get-PSDrive -PSProvider 'FileSystem' | Where-Object { $_.Free -gt 0 }
    foreach ($Drive in $Drives) {
        $PossiblePaths += Join-Path $Drive.Root "Users\$env:USERNAME\Saved Games\Respawn\Apex\local"
    }

    # Add fallback: Documents\Respawn\Apex\local
    $PossiblePaths += Join-Path ([Environment]::GetFolderPath('MyDocuments')) "Respawn\Apex\local"

    # Use the first existing path, or create the first one if none exist
    $ApexConfigPath = $PossiblePaths | Where-Object { Test-Path $_ } | Select-Object -First 1
    if (-not $ApexConfigPath) {
        $ApexConfigPath = $PossiblePaths[0]
        New-Item -ItemType Directory -Path $ApexConfigPath -Force | Out-Null
    }
	
	Start-Sleep -Seconds 1
	
    $ConfigFile = Join-Path $ApexConfigPath "settings.cfg"

    try {
        Invoke-WebRequest -Uri $ConfigURL -OutFile $ConfigFile -UseBasicParsing
		Start-Sleep -Seconds 1
    } catch {
        Write-Error "Failed to download settings.cfg: $_"
		Start-Sleep -Seconds 1
    }
}


Do {
    Clear-Host
    Write-Host "Select An Option:`n"
    Write-Host "1 - Import Video Settings"
    Write-Host "2 - Import AutoExec"
    Write-Host "3 - Create Apex Shortcut"
    Write-Host "4 - Import Tama Roller + KB"
    Write-Host "Q - Quit`n"

    $key = Read-Host "Enter your choice"

    Switch ($key.ToUpper()) {
        '1' { ImportVideoSettings }
        '2' { ImportAutoExec }
        '3' { CreateApexShortcut }
        '4' { ImportKBRollerSettings }
        'Q' { break }
        Default {
            Write-Host "`nInvalid selection, please try again." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }


} While ($true)
