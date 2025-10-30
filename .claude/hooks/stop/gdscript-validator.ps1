# GDScript Validator Hook (Stop Event)
# Validates GDScript syntax after Claude finishes editing
# Runs after each response to catch errors immediately

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "🔍 GDScript Validator" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

# Get list of recently modified .gd files (last 5 minutes)
$ModifiedFiles = Get-ChildItem -Path . -Filter "*.gd" -Recurse -File |
    Where-Object {
        $_.LastWriteTime -gt (Get-Date).AddMinutes(-5) -and
        $_.FullName -notlike "*\addons\*"
    } |
    Select-Object -First 20

if ($ModifiedFiles.Count -eq 0) {
    Write-Host "✅ No GDScript files modified recently" -ForegroundColor Green
    Write-Host ""
    exit 0
}

Write-Host ""
Write-Host "📝 Modified GDScript files detected:" -ForegroundColor Yellow
foreach ($file in $ModifiedFiles) {
    $relativePath = $file.FullName.Replace((Get-Location).Path + "\", "")
    Write-Host "   → $relativePath" -ForegroundColor Gray
}
Write-Host ""

# Check if Godot is available
$GodotCmd = $null
if (Get-Command "godot.exe" -ErrorAction SilentlyContinue) {
    $GodotCmd = "godot.exe"
} elseif (Get-Command "godot" -ErrorAction SilentlyContinue) {
    $GodotCmd = "godot"
}

if (-not $GodotCmd) {
    Write-Host "⚠️  Godot not found in PATH - skipping syntax check" -ForegroundColor Yellow
    Write-Host "💡 Tip: Add Godot to PATH for automatic validation" -ForegroundColor Cyan
    Write-Host ""
    exit 0
}

# Validate each file
$ErrorsFound = 0
$TotalFiles = $ModifiedFiles.Count

Write-Host "🔧 Running syntax validation..." -ForegroundColor Cyan
Write-Host ""

foreach ($file in $ModifiedFiles) {
    # Run Godot headless check
    $Output = & $GodotCmd --headless --check-only --script $file.FullName 2>&1
    $ExitCode = $LASTEXITCODE

    $relativePath = $file.FullName.Replace((Get-Location).Path + "\", "")

    if ($ExitCode -ne 0) {
        $ErrorsFound++
        Write-Host "❌ ${relativePath}:1" -ForegroundColor Red

        # Extract error messages
        $ErrorLines = $Output | Select-String -Pattern "(ERROR|SCRIPT ERROR|Parse Error)" | Select-Object -First 5
        foreach ($line in $ErrorLines) {
            Write-Host "   $line" -ForegroundColor Red
        }
        Write-Host ""
    } else {
        Write-Host "✅ $relativePath" -ForegroundColor Green
    }
}

if ($ErrorsFound -gt 0) {
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Red
    Write-Host "❌ Found GDScript errors in $ErrorsFound file(s)" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 Action Required:" -ForegroundColor Yellow
    Write-Host "   Claude should fix these errors before proceeding" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Red
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
    Write-Host "✅ All GDScript files validated successfully!" -ForegroundColor Green
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
    Write-Host ""
}

exit 0
