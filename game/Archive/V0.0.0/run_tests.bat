@echo off
REM Run headless tests for GoA
REM This batch file runs the Godot tests in headless mode

echo Running GoA tests in headless mode...
echo.

REM Try common Godot installation locations
if exist "C:\Program Files\Godot\Godot_v4.5-stable_win64.exe" (
    "C:\Program Files\Godot\Godot_v4.5-stable_win64.exe" --headless --script "res://tests/test_runner.gd"
    goto :done
)

if exist "C:\Godot\Godot_v4.5-stable_win64.exe" (
    "C:\Godot\Godot_v4.5-stable_win64.exe" --headless --script "res://tests/test_runner.gd"
    goto :done
)

if exist "%LOCALAPPDATA%\Godot\Godot_v4.5-stable_win64.exe" (
    "%LOCALAPPDATA%\Godot\Godot_v4.5-stable_win64.exe" --headless --script "res://tests/test_runner.gd"
    goto :done
)

REM If not found, try 'godot' command (in case it's in PATH)
where godot >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    godot --headless --script "res://tests/test_runner.gd"
    goto :done
)

echo ERROR: Godot executable not found!
echo Please ensure Godot 4.5 is installed and update this batch file with the correct path.
echo.
pause
exit /b 1

:done
echo.
echo Tests completed. Press any key to exit.
pause
