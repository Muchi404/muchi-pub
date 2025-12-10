Function Install-Apps {
    winget install --id Guru3D.Afterburner -e --silent
    winget install --id Brave.Brave -e --silent
    winget install --id Discord.Discord -e --silent
    winget install --id Valve.Steam -e --silent
    winget install --id EpicGames.EpicGamesLauncher -e --silent
    winget install --id Google.Chrome -e --silent
    winget install --id 7zip.7zip -e --silent
    winget install --id VideoLAN.VLC -e --silent
}

Function Run-MuchiDebloat {
    Start-Process powershell -ArgumentList "iwr -useb 'muchi.online/debloat' | iex"
}

Function Run-MuchiSpotify {
    Start-Process powershell -ArgumentList "iwr -useb 'muchi.online/spotify' | iex"
}

Function Run-MuchiRedists {
    Start-Process powershell -ArgumentList "iwr -useb 'muchi.online/redists' | iex"
}

Function Run-MuchiAIO {
    Start-Process powershell -ArgumentList "iwr -useb 'muchi.online/aio' | iex"
}

Function Muchi-Scripts {
	Run-MuchiAIO
	Run-MuchiRedists
    Run-MuchiDebloat
    Run-MuchiSpotify
}

Function Set-MuchiWallpaper {
    $TempPath = "$env:TEMP\blue.jpg"
    Invoke-WebRequest -Uri "https://muchi.online/blue.jpg" -OutFile $TempPath

    # Update registry
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name Wallpaper -Value $TempPath

    # Use COM object to apply wallpaper immediately
    $code = @"
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", SetLastError=true)]
    public static extern bool SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@
    Add-Type $code
    [Wallpaper]::SystemParametersInfo(20, 0, $TempPath, 3)
}

Set-MuchiWallpaper
Install-Apps
Muchi-Scripts
