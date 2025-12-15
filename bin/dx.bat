@echo OFF
setlocal

set "current_location=%~dp0"

:: Check for PowerShell (pwsh)
where pwsh.exe >nul 2>&1
if %ERRORLEVEL%==0 (
    pwsh -NoProfile -ExecutionPolicy Bypass -File "%current_location%..\StartChat.ps1"
    exit /b %ERRORLEVEL%
)

:: Check for Windows PowerShell (powershell)
where powershell.exe >nul 2>&1
if %ERRORLEVEL%==0 (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%current_location%..\StartChat.ps1"
    exit /b %ERRORLEVEL%
)

echo PowerShell is not installed. Install PowerShell before using DX CLI.
echo See https://learn.microsoft.com/en-us/powershell/scripting/install/install-powershell-on-windows

exit /b 1