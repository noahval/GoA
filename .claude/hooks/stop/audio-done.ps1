# Audio Done Hook
# Plays a windchime sound when Claude finishes responding

# Debug: Log that hook is running
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"[$timestamp] Audio hook triggered" | Out-File -FilePath "c:\GoA\.claude\hooks\audio-debug.log" -Append

# Setup path to windchime file
$audioFile = "c:\GoA\.claude\hooks\stop\Windchime.mp3"

# Try to play the windchime audio file
$played = $false
if (Test-Path $audioFile) {
    try {
        # For MP3 files, use Windows Media Player COM object
        Add-Type -AssemblyName PresentationCore
        $mediaPlayer = New-Object System.Windows.Media.MediaPlayer
        $mediaPlayer.Open([Uri]::new($audioFile))
        $mediaPlayer.Volume = 1.0
        $mediaPlayer.Play()

        # Play at full volume for 1000ms
        Start-Sleep -Milliseconds 1000

        # Fade out from 1000ms to 1200ms (200ms fade)
        $fadeSteps = 20
        $fadeDelay = 10  # 20 steps * 10ms = 200ms
        for ($i = $fadeSteps; $i -ge 0; $i--) {
            $mediaPlayer.Volume = $i / $fadeSteps
            Start-Sleep -Milliseconds $fadeDelay
        }

        $mediaPlayer.Stop()
        $mediaPlayer.Close()

        $played = $true
        "[$timestamp] Played windchime audio file" | Out-File -FilePath "c:\GoA\.claude\hooks\audio-debug.log" -Append
    } catch {
        "[$timestamp] Failed to play windchime: $_" | Out-File -FilePath "c:\GoA\.claude\hooks\audio-debug.log" -Append
    }
}

# Fallback to console beep if audio file didn't work
if (-not $played) {
    try {
        # Middle C (C4) is 262 Hz
        [console]::beep(262, 800)
        "[$timestamp] Played fallback beep (262 Hz)" | Out-File -FilePath "c:\GoA\.claude\hooks\audio-debug.log" -Append
    } catch {
        "[$timestamp] Fallback beep failed: $_" | Out-File -FilePath "c:\GoA\.claude\hooks\audio-debug.log" -Append
    }
}

exit 0
