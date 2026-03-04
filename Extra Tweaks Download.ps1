function MuchiExtraTweaks {

    $ProgressPreference = 'SilentlyContinue'
    $ErrorActionPreference = 'SilentlyContinue'

    $TempDir    = [System.IO.Path]::GetTempPath()
    $Desktop    = [Environment]::GetFolderPath('Desktop')
    $ExtractDir = Join-Path $Desktop "Muchi Extra Tweaks"

    if (!(Test-Path $ExtractDir)) {
        New-Item -ItemType Directory -Path $ExtractDir -Force | Out-Null
    }

    $urls = @(
        "https://github.com/Muchi404/muchi-pub/raw/main/Extra%20Tweaks%202.zip",
        "https://github.com/Muchi404/muchi-pub/raw/refs/heads/main/Extra%20Tweaks.zip"
    )

    foreach ($url in $urls) {

        $fileName = Split-Path $url -Leaf
        $zipPath  = Join-Path $TempDir $fileName

        Start-BitsTransfer -Source $url -Destination $zipPath -ErrorAction SilentlyContinue

        if (Test-Path $zipPath) {
            Expand-Archive -Path $zipPath -DestinationPath $ExtractDir -Force
            Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
        }
    }
}


MuchiExtraTweaks