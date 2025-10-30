# Game Mechanics Safety Check Hook (Stop Event)
# Gentle reminder about GoA game mechanics patterns
# Non-blocking awareness system - doesn't block, just reminds

# Get list of recently modified .gd files (last 5 minutes)
$ModifiedFiles = Get-ChildItem -Path . -Filter "*.gd" -Recurse -File |
    Where-Object {
        $_.LastWriteTime -gt (Get-Date).AddMinutes(-5) -and
        $_.FullName -notlike "*\addons\*"
    } |
    Select-Object -First 20

if ($ModifiedFiles.Count -eq 0) {
    # No files modified, skip check
    exit 0
}

# Detection flags
$SceneChangeDetected = $false
$TimerDetected = $false
$StatModificationDetected = $false
$GlobalStatDetected = $false

# Check each file for risky patterns
foreach ($file in $ModifiedFiles) {
    $content = Get-Content -Path $file.FullName -Raw -ErrorAction SilentlyContinue

    if (-not $content) {
        continue
    }

    # Check for scene changes (get_tree().change_scene*)
    if ($content -match "get_tree\(\)\.change_scene") {
        $SceneChangeDetected = $true
    }

    # Check for timer modifications
    if ($content -match "(Timer\.new\(\)|\.timeout|whisper_timer|suspicion_timer|stamina_timer|break_timer)") {
        $TimerDetected = $true
    }

    # Check for direct stat modifications (Global.strength =, etc.)
    if ($content -match "Global\.(strength|constitution|dexterity|wisdom|intelligence|charisma)\s*=") {
        $GlobalStatDetected = $true
    }

    # Check for stat modifications without using add_stat_exp
    if ($content -match "(strength|constitution|dexterity|wisdom|intelligence|charisma)") {
        if ($content -notmatch "add_stat_exp") {
            $StatModificationDetected = $true
        }
    }
}

# Only show reminder if risky patterns detected
if ($SceneChangeDetected -or $TimerDetected -or $StatModificationDetected -or $GlobalStatDetected) {
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "📋 GAME MECHANICS SELF-CHECK" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "⚠️  GoA Game Mechanics Detected" -ForegroundColor Yellow

    $SuggestionsShown = $false

    if ($SceneChangeDetected) {
        Write-Host ""
        Write-Host "   🎬 Scene Changes Detected" -ForegroundColor Yellow
        Write-Host "   ❓ Did you use Global.change_scene_with_check()?" -ForegroundColor Cyan
        Write-Host "   💡 This ensures scene changes respect game mechanics" -ForegroundColor Gray
        $SuggestionsShown = $true
    }

    if ($TimerDetected) {
        Write-Host ""
        Write-Host "   ⏱️  Timer Modifications Detected" -ForegroundColor Yellow
        Write-Host "   ❓ Are you aware of global timer dependencies?" -ForegroundColor Cyan
        Write-Host "   💡 Game has whisper, suspicion, stamina, and break timers" -ForegroundColor Gray
        $SuggestionsShown = $true
    }

    if ($GlobalStatDetected) {
        Write-Host ""
        Write-Host "   📊 Direct Stat Assignment Detected" -ForegroundColor Yellow
        Write-Host "   ❓ Should you use Global.add_stat_exp() instead?" -ForegroundColor Cyan
        Write-Host "   💡 Direct assignment bypasses experience system" -ForegroundColor Gray
        $SuggestionsShown = $true
    }

    if ($StatModificationDetected -and -not $GlobalStatDetected) {
        Write-Host ""
        Write-Host "   📈 Stat-Related Code Detected" -ForegroundColor Yellow
        Write-Host "   ❓ Did you use Global.add_stat_exp()?" -ForegroundColor Cyan
        Write-Host "   ❓ Did you use Global.show_stat_notification()?" -ForegroundColor Cyan
        Write-Host "   💡 These ensure proper stat changes & user feedback" -ForegroundColor Gray
        $SuggestionsShown = $true
    }

    if ($SuggestionsShown) {
        Write-Host ""
        Write-Host "   📚 Quick Reference:" -ForegroundColor Cyan
        Write-Host "      → Global.add_stat_exp(stat_name, amount)" -ForegroundColor Gray
        Write-Host "      → Global.show_stat_notification(stat_name, amount)" -ForegroundColor Gray
        Write-Host "      → Global.change_scene_with_check(scene_path)" -ForegroundColor Gray
        Write-Host ""
        Write-Host "   📖 See: game-systems.md for details" -ForegroundColor Cyan
    }

    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host ""
}

exit 0
