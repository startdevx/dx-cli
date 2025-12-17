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
        $userInput = Read-Host "A new version of DX CLI ($remoteVersion) is available.`nYou can update now or continue using the current version.`nUpdate now? [Y/N] (default: N)"
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