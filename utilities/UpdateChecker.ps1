function Invoke-Git {
    param (
        [array]$GitArguments = @()
    )

    return git $GitArguments 2>&1
}

try {
    Get-Command git -ErrorAction Stop | Out-Null
    $resolvedPath = (Resolve-Path -Path "$PSScriptRoot\..").Path
    Invoke-Git -GitArguments @("-C", $resolvedPath, "fetch", "origin", "--prune") | Out-Null
    [Version]$remoteVersion = Invoke-Git -GitArguments @("-C", $resolvedPath, "show", "origin/main:Version")
    [Version]$currentVersion = Get-Content -Path "$resolvedPath\Version"
    if ($remoteVersion -gt $currentVersion) {
        Write-Host "A new version $remoteVersion of DX CLI is available"
        $userInput = Read-Host "Do you want to update it now? (Y/N)"
        switch -Regex ($userInput.Trim().ToLower()) {
            '^(yes|y)$' {
                Invoke-Git -GitArguments @("-C", $resolvedPath, "pull")
                return "true"
            }
        }
    }
}
catch {
}

return "false"