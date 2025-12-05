# Audio Done Hook
# Plays a windchime sound when Claude finishes responding

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
    } catch {
        # Silently fail and use fallback
    }
}

# Fallback to console beep if audio file didn't work
if (-not $played) {
    try {
        # Middle C (C4) is 262 Hz
        [console]::beep(262, 800)
    } catch {
        # Silently fail
    }
}

exit 0
