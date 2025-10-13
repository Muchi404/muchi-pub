$functionCode = @'
Function No-Ads {
    [Net.ServicePointManager]::SecurityProtocol = 3072
    Invoke-WebRequest -UseBasicParsing "https://raw.githubusercontent.com/SpotX-Official/SpotX/refs/heads/main/run.ps1" | Invoke-Expression
}
No-Ads
'@

Start-Process powershell.exe -ArgumentList "-NoExit", "-Command", $functionCode
