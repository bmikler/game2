@echo off
rem Runs the game with the look-tuning panel for ticket 27 (live_tuning.gd).
start "" "%~dp0..\godot\Godot_v4.7.2-stable_win64_console.exe" --path "%~dp0..\..\game" --script "%~dp0live_tuning.gd"
