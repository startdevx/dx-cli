@echo OFF
setlocal

setlocal ENABLEDELAYEDEXPANSION
set "current_location=%~dp0"

:: Check for PowerShell (pwsh)
where pwsh.exe >nul 2>&1
if %ERRORLEVEL%==0 (
    for /F "usebackq delims=" %%A in (`pwsh -NoProfile -ExecutionPolicy Bypass -File "%current_location%..\utilities\UpdateChecker.ps1"`) do (
        set "has_cli_been_updated=%%A"
    )

    pwsh -NoProfile -ExecutionPolicy Bypass -File "%current_location%..\StartChat.ps1" -HasCliBeenUpdated !has_cli_been_updated!
    endlocal
    exit /b %ERRORLEVEL%
)

:: Check for Windows PowerShell (powershell)
where powershell.exe >nul 2>&1
if %ERRORLEVEL%==0 (
    for /F "usebackq delims=" %%A in (`powershell -NoProfile -ExecutionPolicy Bypass -File "%current_location%..\utilities\UpdateChecker.ps1"`) do (
        set "has_cli_been_updated=%%A"
    )

    powershell -NoProfile -ExecutionPolicy Bypass -File "%current_location%..\StartChat.ps1" -HasCliBeenUpdated !has_cli_been_updated!
    endlocal
    exit /b %ERRORLEVEL%
)

echo PowerShell is not installed. Install PowerShell before using DX CLI.
echo See https://learn.microsoft.com/en-us/powershell/scripting/install/install-powershell-on-windows

endlocal
exit /b 1