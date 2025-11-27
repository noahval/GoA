# Audio Done Hook
# Plays a notification sound when Claude finishes responding

# Debug: Log that hook is running
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"[$timestamp] Audio hook triggered" | Out-File -FilePath "c:\GoA\.claude\hooks\audio-debug.log" -Append

# Try multiple audio methods for maximum compatibility

# Method 1: Console beep (more reliable in background)
try {
    [console]::beep(523, 800)
    "[$timestamp] Console beep attempted" | Out-File -FilePath "c:\GoA\.claude\hooks\audio-debug.log" -Append
} catch {
    "[$timestamp] Console beep failed: $_" | Out-File -FilePath "c:\GoA\.claude\hooks\audio-debug.log" -Append
}

# Method 2: Windows system sound
try {
    $sound = New-Object System.Media.SoundPlayer
    $sound.SoundLocation = "C:\Windows\Media\Windows Ding.wav"
    $sound.PlaySync()  # Changed to PlaySync for better reliability
    $sound.Dispose()
    "[$timestamp] System sound played" | Out-File -FilePath "c:\GoA\.claude\hooks\audio-debug.log" -Append
} catch {
    "[$timestamp] System sound failed: $_" | Out-File -FilePath "c:\GoA\.claude\hooks\audio-debug.log" -Append
}

exit 0
