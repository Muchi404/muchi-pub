$licenseKey = Read-Host "Enter your license key"

$activationUrl = "https://muchi.online/.netlify/functions/activate"
$runUrl = "https://muchi.online/.netlify/functions/run"

do {
    $payload = @{ licenseKey = $licenseKey } | ConvertTo-Json -Compress

    try {
        $response = Invoke-RestMethod -Uri $activationUrl -Method Post -Body $payload -ContentType "application/json"
        Write-Host "Server response: $($response.message)"
        if ($response.message -eq "License key valid") {
            break
        } else {
            $licenseKey = Read-Host "Invalid key. Please enter a valid license key"
        }
    }
    catch {
        Write-Host "Activation failed: $($_.Exception.Message)"
        $licenseKey = Read-Host "Please enter a valid license key"
    }
} while ($true)

try {
    $headers = @{ Authorization = "Bearer $licenseKey" }
    $result = Invoke-RestMethod -Uri $runUrl -Headers $headers -Method Get
    $script = $result.script
    $signature = $result.signature

    Write-Host "Successfully downloaded script and signature."
    
    # 👉 RUN the downloaded script
    Write-Host "`nRunning Muchility script..." -ForegroundColor Cyan
    Start-Sleep -Seconds 2
    Invoke-Expression $script

} catch {
    Write-Host "Failed to get script: $($_.Exception.Message)"
}
