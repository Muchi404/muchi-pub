# ==========================
#  RAINBOW
# ==========================

$e = [char]27
$r = "$e[0m"

$rainbow = @(
    "$e[38;2;255;182;193m","$e[38;2;255;186;191m","$e[38;2;255;190;189m",
    "$e[38;2;255;194;187m","$e[38;2;255;198;185m","$e[38;2;255;202;183m",
    "$e[38;2;255;206;181m","$e[38;2;255;210;179m","$e[38;2;255;214;177m",
    "$e[38;2;255;218;175m","$e[38;2;255;222;173m","$e[38;2;255;226;172m",
    "$e[38;2;255;230;171m","$e[38;2;255;234;170m","$e[38;2;255;238;170m",
    "$e[38;2;255;242;170m","$e[38;2;255;246;170m","$e[38;2;255;250;170m",
    "$e[38;2;253;252;172m","$e[38;2;248;254;174m","$e[38;2;243;255;176m",
    "$e[38;2;235;255;178m","$e[38;2;227;255;180m","$e[38;2;219;255;182m",
    "$e[38;2;211;255;184m","$e[38;2;203;255;186m","$e[38;2;195;255;190m",
    "$e[38;2;190;255;195m","$e[38;2;185;255;200m","$e[38;2;180;255;208m",
    "$e[38;2;178;255;216m","$e[38;2;176;255;224m","$e[38;2;174;255;232m",
    "$e[38;2;172;255;240m","$e[38;2;172;252;248m","$e[38;2;172;248;252m",
    "$e[38;2;172;244;255m","$e[38;2;172;238;255m","$e[38;2;174;232;255m",
    "$e[38;2;176;226;255m","$e[38;2;178;220;255m","$e[38;2;180;214;255m",
    "$e[38;2;182;208;255m","$e[38;2;184;202;255m","$e[38;2;186;196;255m",
    "$e[38;2;188;192;255m","$e[38;2;190;188;255m","$e[38;2;192;185;255m"
)

function Get-RainbowText {
    param([string]$Text)

    $chars = $Text.ToCharArray()
    $len = $chars.Length
    $out = ""

    for ($i = 0; $i -lt $len; $i++) {
        $idx = [Math]::Floor(($i / $len) * $rainbow.Length)
        if ($idx -ge $rainbow.Length) { $idx = $rainbow.Length - 1 }
        $out += $rainbow[$idx] + $chars[$i]
    }

    "$out$r"
}

# ==========================
#  MUCHI HUB
# ==========================

$Apps = [ordered]@{
    "1" = "Muchility (Tweaks)"
    "2" = "Activate Windows"
    "3" = "Apex Legends Performance Mode"
    "4" = "Microsoft Redists AIO Installer"
    "5" = "Upgrade Windows Edition (Home > Pro)"
    "6" = "Spotify (No Ads)"
    "7" = "Debloat Windows"
    "8" = "Reset Windows Update (If Bugged)"
}

$Links = @{
    "1" = "muchi.online/app"
    "2" = "muchi.online/activate"
    "3" = "muchi.online/apex"
    "4" = "muchi.online/redists"
    "5" = "muchi.online/upgrade"
    "6" = "muchi.online/spotify"
    "7" = "muchi.online/debloat"
    "8" = "muchi.online/updatereset"
}


while ($true) {

    $Host.UI.RawUI.BackgroundColor = "Black"
    $Host.UI.RawUI.ForegroundColor = "White"
    Clear-Host

    Write-Host ""
    Write-Host (Get-RainbowText "===== MUCHI HUB =====")
    Write-Host ""

    foreach ($Key in ($Apps.Keys | Sort-Object {[int]$_})) {
        Write-Host (Get-RainbowText "$Key) $($Apps[$Key])")
    }

    Write-Host ""
    $Choice = Read-Host (Get-RainbowText "Select An Option")

    if ($Links.ContainsKey($Choice) -and $Links[$Choice]) {
        $Cmd = "iwr -useb `"$($Links[$Choice])`" | iex"
        Start-Process powershell.exe "-NoExit -ExecutionPolicy Bypass -Command $Cmd"
        Start-Sleep 1
    }
    else {
        Write-Host ""
        Write-Host (Get-RainbowText "Invalid Option")
        Start-Sleep 1
    }
}

