."$PSScriptRoot\Card.ps1"
."$PSScriptRoot\..\utilities\SystemUtilities.ps1"

function Write-ReleaseNoteCard {
    param (
        [string]$FromVersion = "0.0.1"
    )

    [Version]$oldVersion = $FromVersion
    [Version]$currentVersion = Get-CliVersion

    if ($currentVersion -le $oldVersion) {
        return
    }
    
    $content = Get-Content "$PSScriptRoot\..\RELEASE-NOTES.md" -Raw
    $pattern = '(?ms)^##\s+(?<version>[^\r\n]+)\s*(?<body>.*?)(?=^##\s+|\z)'

    $releases = [regex]::Matches($content, $pattern) | ForEach-Object {
        [pscustomobject]@{
            Version = [Version]$($_.Groups['version'].Value.Trim())
            Content = $_.Groups['body'].Value.Trim()
        }
    }

    $releaseNotes = ""

    foreach ($release in $releases) {
        if ($release.Version -gt $oldVersion -and $release.Version -le $currentVersion) {
            $releaseNotes += $release.Content + "`n"
        }
    }

    Write-Card -Title "Release Notes" -BorderColor DarkGreen -Text $releaseNotes
}
