@echo off
cd /d "C:\Users\thero\OneDrive\Documents\VirtualDesktop"

IF "%~1"=="" echo Error: No command provided. Please specify '/all' or an index (e.g., '/1' or '1'). & exit /b 1

powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\KillVD.ps1" -cmd "%1"