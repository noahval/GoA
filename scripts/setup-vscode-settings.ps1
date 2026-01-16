# Setup VSCode workspace settings for GoA project
# Run this on any machine after cloning the repo

$settingsDir = Join-Path $PSScriptRoot "..\.vscode"
$settingsFile = Join-Path $settingsDir "settings.json"

# Create .vscode directory if it doesn't exist
if (-not (Test-Path $settingsDir)) {
    New-Item -ItemType Directory -Path $settingsDir -Force | Out-Null
    Write-Host "Created .vscode directory"
}

# Settings to apply
$settings = @{
    "explorer.sortOrder" = "mixed"  # Files and folders sort together by name
}

# If settings.json exists, merge with existing settings
if (Test-Path $settingsFile) {
    $existing = Get-Content $settingsFile -Raw | ConvertFrom-Json -AsHashtable
    foreach ($key in $settings.Keys) {
        $existing[$key] = $settings[$key]
    }
    $settings = $existing
    Write-Host "Merged with existing settings"
}

# Write settings
$settings | ConvertTo-Json -Depth 10 | Set-Content $settingsFile -Encoding UTF8
Write-Host "VSCode settings updated: $settingsFile"
Write-Host "  - explorer.sortOrder = mixed (folders and files sort together)"
