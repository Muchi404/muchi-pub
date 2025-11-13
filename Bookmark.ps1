Function BM-Bookmarks {
    $ErrorActionPreference = 'SilentlyContinue'
    $Host.UI.RawUI.BackgroundColor = "Black"
    Clear-Host

    Write-Host "Select Mode:" -ForegroundColor White
    Write-Host "1 - Export Bookmarks" -ForegroundColor Yellow
    Write-Host "2 - Import Bookmarks`n" -ForegroundColor Cyan
    $Mode = Read-Host "Enter Number"
    Clear-Host

    Function Get-BrowserPath {
        Write-Host "Select Browser:" -ForegroundColor White
        Write-Host "1 - Brave" -ForegroundColor Yellow
        Write-Host "2 - Google Chrome`n" -ForegroundColor Cyan

        $Choice = Read-Host "Enter Number"
        Clear-Host

        Switch ($Choice) {
            1 {
                return @{
                    Browser = "Brave"
                    Path    = Join-Path $env:LOCALAPPDATA "BraveSoftware\Brave-Browser\User Data\Default\Bookmarks"
                    Root    = Join-Path $env:LOCALAPPDATA "BraveSoftware\Brave-Browser\User Data\Default"
                }
            }
            2 {
                return @{
                    Browser = "Chrome"
                    Path    = Join-Path $env:LOCALAPPDATA "Google\Chrome\User Data\Default\Bookmarks"
                    Root    = Join-Path $env:LOCALAPPDATA "Google\Chrome\User Data\Default"
                }
            }
            Default { return $null }
        }
    }

# -------------------------------
# IMPORT MODE
# -------------------------------
if ($Mode -eq "2") {

    $ZipPath = "C:\extracted bookmarks.zip"
    if (-Not (Test-Path $ZipPath)) { return }

    $Binfo = Get-BrowserPath
    if (-not $Binfo) { return }

    Clear-Host
    Write-Host "Importing To $($Binfo.Browser)..." -ForegroundColor Cyan

    # Extract ZIP
    $Temp = Join-Path $env:TEMP ("Import_" + [guid]::NewGuid())
    New-Item -ItemType Directory -Path $Temp | Out-Null
    Expand-Archive -Path $ZipPath -DestinationPath $Temp -Force | Out-Null

    # ---------------------------------------------------
    # CHROMIUM IMPORT (BRAVE / CHROME) - MERGE DIRECTLY INTO BOOKMARK BAR
    # ---------------------------------------------------

    $BookmarksJsonPath = $Binfo.Path
    if (-not (Test-Path $BookmarksJsonPath)) { return }

    $Json = Get-Content $BookmarksJsonPath -Raw | ConvertFrom-Json

    Function Convert-ToChromeJson {
        param ($Path)

        $Items = @()

        foreach ($Item in Get-ChildItem $Path) {

            if ($Item.PSIsContainer) {
                $FolderObj = [PSCustomObject]@{
                    type          = "folder"
                    name          = $Item.Name
                    id            = (Get-Random -Minimum 300000 -Maximum 999999).ToString()
                    date_added    = "13200000000000000"
                    date_modified = "13200000000000000"
                    children      = @(Convert-ToChromeJson -Path $Item.FullName)
                }
                $Items += $FolderObj
            }

            elseif ($Item.Extension -eq ".url") {
                $Content = Get-Content $Item.FullName
                $UrlLine = $Content | Where-Object { $_ -like "URL=*" }
                $Url = $UrlLine -replace "URL=", ""

                $BookmarkObj = [PSCustomObject]@{
                    type       = "url"
                    name       = [System.IO.Path]::GetFileNameWithoutExtension($Item.Name)
                    url        = $Url
                    id         = (Get-Random -Minimum 300000 -Maximum 999999).ToString()
                    date_added = "13200000000000000"
                }
                $Items += $BookmarkObj
            }
        }

        return $Items
    }

    # Convert ZIP → bookmarks/folders
    $Converted = Convert-ToChromeJson -Path $Temp

    # Merge directly into bookmark_bar
    $Json.roots.bookmark_bar.children += $Converted

    # Save updated JSON
    $Json | ConvertTo-Json -Depth 30 | Set-Content $BookmarksJsonPath -Encoding UTF8

    Remove-Item $Temp -Recurse -Force | Out-Null

    Write-Host "`nBookmarks Imported Directly Into Bookmark Bar" -ForegroundColor Green

    $Delete = Read-Host "Delete extracted bookmarks.zip? (y/n)"
    if ($Delete -eq "y") { Remove-Item $ZipPath -Force | Out-Null }

    return
}

# -------------------------------
# EXPORT MODE
# -------------------------------
$Binfo = Get-BrowserPath
if (-not $Binfo) { return }

$Browser = $Binfo.Browser

Write-Host "$Browser Selected.`n" -ForegroundColor Cyan
Write-Host "Select Export Mode:" -ForegroundColor White
Write-Host "1 - Single Folder" -ForegroundColor Blue
Write-Host "2 - All Folders`n" -ForegroundColor Green
$ExportChoice = Read-Host "Enter Number"
Clear-Host

# -------------------------------
# CHROMIUM EXPORT (BRAVE / CHROME)
# -------------------------------
$BookmarksPath = $Binfo.Path
if (-Not (Test-Path $BookmarksPath)) { return }

$Json = Get-Content $BookmarksPath -Raw | ConvertFrom-Json
$RootChildren = $Json.roots.bookmark_bar.children + $Json.roots.other.children + $Json.roots.synced.children

Function Export-UrlsRecursively($Items, $BasePath) {
    foreach ($Item in $Items) {
        if ($Item.type -eq "url") {
            $Safe = ($Item.name -replace '[\\/:*?"<>|]', '_')
            $UrlFile = Join-Path $BasePath ($Safe + ".url")
            Set-Content -Path $UrlFile -Value "[InternetShortcut]`nURL=$($Item.url)" -Encoding ASCII | Out-Null
        }
        elseif ($Item.type -eq "folder" -and $Item.children) {
            $Sub = Join-Path $BasePath ($Item.name -replace '[\\/:*?"<>|]', '_')
            New-Item -ItemType Directory -Path $Sub -Force | Out-Null
            Export-UrlsRecursively $Item.children $Sub
        }
    }
}

Function Find-Folder($Items, $Target) {
    foreach ($Item in $Items) {
        if ($Item.type -eq "folder" -and $Item.name -eq $Target) { return $Item }
        if ($Item.children) {
            $Found = Find-Folder $Item.children $Target
            if ($Found) { return $Found }
        }
    }
    return $null
}

if ($ExportChoice -eq "1") {
    Write-Host "Enter Folder Name:" -ForegroundColor Yellow
    $FolderName = Read-Host
    $Target = Find-Folder $RootChildren $FolderName
    if (-not $Target) { return }
}

Clear-Host
Write-Host "Exporting $Browser bookmarks..." -ForegroundColor Cyan

$TempPath = Join-Path $env:TEMP ("Export_" + [guid]::NewGuid())
New-Item -ItemType Directory -Path $TempPath | Out-Null

if ($ExportChoice -eq "1") {
    Export-UrlsRecursively $Target.children $TempPath
} else {
    Export-UrlsRecursively $RootChildren $TempPath
}

$ZipPath = "C:\extracted bookmarks.zip"
if (Test-Path $ZipPath) { Remove-Item $ZipPath -Force | Out-Null }
Compress-Archive -Path (Join-Path $TempPath "*") -DestinationPath $ZipPath | Out-Null
Remove-Item $TempPath -Recurse -Force | Out-Null

Clear-Host
Write-Host "Bookmarks Exported To C:\" -ForegroundColor Green
}

BM-Bookmarks
