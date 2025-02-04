# Task 4: Enable Windows Defender Firewall
Write-Host "Enabling Windows Defender Firewall..." -ForegroundColor Yellow

# Enable the Windows Defender Firewall for all profiles (Domain, Private, Public)
Set-NetFirewallProfile -Profile Domain, Private, Public -Enabled True

Write-Host "Windows Defender Firewall has been enabled." -ForegroundColor Green

# Task 5: Verify that Google Chrome is allowed to communicate through Windows Defender Firewall
Write-Host "Ensuring Google Chrome is allowed through Windows Defender Firewall..." -ForegroundColor Yellow

# Define the path to Google Chrome executable
$chromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"

# Check if a rule for Google Chrome already exists
$chromeRule = Get-NetFirewallApplicationFilter | Where-Object { $_.Program -eq $chromePath }

if (-not $chromeRule) {
    # If no rule exists, create a new rule to allow Google Chrome
    New-NetFirewallRule -DisplayName "Allow Google Chrome" -Direction Outbound -Program $chromePath -Action Allow
    Write-Host "A new firewall rule has been created to allow Google Chrome." -ForegroundColor Green
} else {
    # If a rule exists, ensure it is enabled
    Set-NetFirewallRule -DisplayName "Allow Google Chrome" -Enabled True
    Write-Host "The existing firewall rule for Google Chrome has been verified and enabled." -ForegroundColor Green
}

# Task 6: Block Firefox from communicating through Windows Defender Firewall
Write-Host "Blocking Firefox from communicating through Windows Defender Firewall..." -ForegroundColor Yellow

# Define the path to Firefox executable
$firefoxPath = "C:\Program Files\Mozilla Firefox\firefox.exe"

# Check if a rule for Firefox already exists
$firefoxRule = Get-NetFirewallApplicationFilter | Where-Object { $_.Program -eq $firefoxPath }

if (-not $firefoxRule) {
    # If no rule exists, create a new rule to block Firefox
    New-NetFirewallRule -DisplayName "Block Firefox" -Direction Outbound -Program $firefoxPath -Action Block
    Write-Host "A new firewall rule has been created to block Firefox." -ForegroundColor Green
} else {
    # If a rule exists, ensure it is set to block
    Set-NetFirewallRule -DisplayName "Block Firefox" -Action Block -Enabled True
    Write-Host "The existing firewall rule for Firefox has been updated to block communication." -ForegroundColor Green
}

Write-Host "All tasks have been completed successfully." -ForegroundColor Cyan
