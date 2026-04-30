Function Set-MuchiWallpaper {
    $TempPath = "$env:TEMP\porsche.jpeg"
    Invoke-WebRequest -Uri "https://muchi.online/porsche.jpeg" -OutFile $TempPath

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

Function Run-ContextMenu {
	Start-Process powershell -ArgumentList "iwr -useb 'muchi.online/contextmenu' | iex"
}

Function Run-MuchiDebloat {
    Start-Process powershell -ArgumentList "iwr -useb 'muchi.online/debloat' | iex"
}

Function Run-MuchiAIO {
    Start-Process powershell -ArgumentList "iwr -useb 'muchi.online/aio' | iex"
}

Function Run-MuchiExtras {
    Start-Process powershell -ArgumentList "iwr -useb 'muchi.online/extras' | iex"
}

Function Run-MuchiExe {
    Start-Process powershell -ArgumentList "iwr -useb 'muchi.online/exe' | iex"
}

Function Install-Apps {
    winget install --id 7zip.7zip -e --silent
    winget install --id VideoLAN.VLC -e --silent
    winget install --id Discord.Discord -e --silent
}



Function RunAll {
Set-MuchiWallpaper
Run-ContextMenu
Run-MuchiDebloat
Run-MuchiAIO
Run-MuchiExtras
Run-MuchiExe
Install-Apps
}

RunAll
