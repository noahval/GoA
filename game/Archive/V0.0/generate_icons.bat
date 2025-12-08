@echo off
REM Generate 64x64 currency icons from source images
REM This batch file runs the icon generation script in headless mode

echo Generating currency icons...
echo.

REM Try common Godot installation locations
if exist "C:\Program Files\Godot\Godot_v4.5-stable_win64.exe" (
    "C:\Program Files\Godot\Godot_v4.5-stable_win64.exe" --headless --script "res://generate_currency_icons.gd"
    goto :done
)

if exist "C:\Godot\Godot_v4.5-stable_win64.exe" (
    "C:\Godot\Godot_v4.5-stable_win64.exe" --headless --script "res://generate_currency_icons.gd"
    goto :done
)

if exist "%LOCALAPPDATA%\Godot\Godot_v4.5-stable_win64.exe" (
    "%LOCALAPPDATA%\Godot\Godot_v4.5-stable_win64.exe" --headless --script "res://generate_currency_icons.gd"
    goto :done
)

REM If not found, try 'godot' command (in case it's in PATH)
where godot >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    godot --headless --script "res://generate_currency_icons.gd"
    goto :done
)

echo ERROR: Godot executable not found!
echo Please ensure Godot 4.5 is installed and update this batch file with the correct path.
echo.
pause
exit /b 1

:done
echo.
echo Icon generation completed. Press any key to exit.
pause
