# Script: UndoRecentUpdateAndPauseUpdates.ps1
# Author: Service Desk, XYZ Corporation
# Description: This script uninstalls the most recent security updates for Microsoft Windows
#              and temporarily pauses automatic updates.

# Ensure the script is run with administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script must be run as an administrator. Please restart the script with elevated privileges." -ForegroundColor Red
    exit 1
}

Write-Host "Starting script to undo recent update and pause automatic updates..." -ForegroundColor Cyan

# Task 1: Uninstall the most recent security updates for Microsoft Windows
try {
    Write-Host "Retrieving a list of installed updates..." -ForegroundColor Yellow
    $updates = Get-HotFix | Sort-Object InstalledOn -Descending | Where-Object { $_.Description -eq "Security Update" }

    if ($updates.Count -eq 0) {
        Write-Host "No security updates found to uninstall." -ForegroundColor Yellow
    } else {
        $mostRecentUpdate = $updates[0]
        Write-Host "Most recent security update found: $($mostRecentUpdate.HotFixID) installed on $($mostRecentUpdate.InstalledOn)" -ForegroundColor Green

        # Uninstall the most recent update
        Write-Host "Uninstalling the most recent security update: $($mostRecentUpdate.HotFixID)..." -ForegroundColor Yellow
        wusa /uninstall /kb:$($mostRecentUpdate.HotFixID.Replace("KB", "")) /quiet /norestart

        if ($LASTEXITCODE -eq 0) {
            Write-Host "Successfully uninstalled the most recent security update." -ForegroundColor Green
        } else {
            Write-Host "Failed to uninstall the most recent security update. Exit code: $LASTEXITCODE" -ForegroundColor Red
        }
    }
} catch {
    Write-Host "An error occurred while attempting to uninstall the most recent security update: $_" -ForegroundColor Red
}

# Task 2: Temporarily pause automatic updates
try {
    Write-Host "Pausing automatic updates..." -ForegroundColor Yellow

    # Disable automatic updates via Windows Update settings
    $updateService = New-Object -ComObject Microsoft.Update.ServiceManager
    $updateSession = New-Object -ComObject Microsoft.Update.Session
    $updateSearcher = $updateSession.CreateUpdateSearcher()

    # Set the service to manual mode (paused)
    $updateService.Services | ForEach-Object {
        if ($_.IsDefaultAUService) {
            $_.IsDefaultAUService = $false
        }
    }

    # Configure Group Policy to pause updates (requires registry modification)
    $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
    if (-not (Test-Path $registryPath)) {
        New-Item -Path $registryPath -Force | Out-Null
    }

    # Set the registry values to pause updates
    Set-ItemProperty -Path $registryPath -Name "NoAutoUpdate" -Value 1 -Type DWord
    Set-ItemProperty -Path $registryPath -Name "AUOptions" -Value 1 -Type DWord

    Write-Host "Automatic updates have been paused successfully." -ForegroundColor Green
} catch {
    Write-Host "An error occurred while attempting to pause automatic updates: $_" -ForegroundColor Red
}

Write-Host "Script execution completed." -ForegroundColor Cyan
