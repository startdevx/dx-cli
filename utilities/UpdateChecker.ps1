function Invoke-Git {
    param (
        [array]$GitArguments = @()
    )

    return git $GitArguments 2>&1
}

try {
    Get-Command git -ErrorAction Stop | Out-Null
    Invoke-Git -GitArguments @("-C", "$PSScriptRoot\..", "fetch", "origin", "--prune") | Out-Null
    [Version]$remoteVersion = Invoke-Git -GitArguments @("-C", "$PSScriptRoot\..", "show", "origin/main:version")
    [Version]$currentVersion = Get-Content -Path "$PSScriptRoot\..\Version"
    if ($remoteVersion -gt $currentVersion) {
        Write-Host "A new version $remoteVersion of DX CLI is available"
        $userInput = Read-Host "Do you want to update it now? (Y/N)"
        switch -Regex ($userInput.Trim().ToLower()) {
            '^(yes|y)$' {
                Invoke-Git -GitArguments @("-C", "$PSScriptRoot\..", "pull")
                break
            }
            default {
                break
            }
        }
    }
}
catch {
}