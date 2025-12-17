function Invoke-Git {
    param (
        [array]$GitArguments = @()
    )

    return git $GitArguments 2>&1
}

$resolvedPath = (Resolve-Path -Path "$PSScriptRoot\..").Path
[Version]$previousCliVersion = Get-Content -Path "$resolvedPath\Version"

try {
    Get-Command git -ErrorAction Stop | Out-Null
    Invoke-Git -GitArguments @("-C", $resolvedPath, "fetch", "origin", "--prune") | Out-Null
    [Version]$remoteVersion = Invoke-Git -GitArguments @("-C", $resolvedPath, "show", "origin/main:Version")
    if ($remoteVersion -gt $previousCliVersion) {
        Write-Host "A new version $remoteVersion of DX CLI is available"
        $userInput = Read-Host "Do you want to update it now? (Y/N)"
        switch -Regex ($userInput.Trim().ToLower()) {
            '^(yes|y)$' {
                Invoke-Git -GitArguments @("-C", $resolvedPath, "pull")
            }
        }
    }
}
catch {
}

return $previousCliVersion.ToString()