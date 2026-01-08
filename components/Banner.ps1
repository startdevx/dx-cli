."$PSScriptRoot\Card.ps1"
."$PSScriptRoot\..\utilities\SystemUtilities.ps1"

function Write-Banner {
    param (
        [string]$FromVersion = "0.0.1"
    )

    # https://patorjk.com/software/taag/#p=display&f=Big+Money-ne&t=dx+AI&x=none&v=4&h=4&w=80&we=false
    $bannerTitle = "dx cli"
    $bannerAsciiArt = @"
       /00                           /00 /00
      | 00                          | 00|__/
  /0000000 /00   /00        /0000000| 00 /00
 /00__  00|  00 /00/       /00_____/| 00| 00
| 00  | 00 \  0000/       | 00      | 00| 00
| 00  | 00  >00  00       | 00      | 00| 00
|  0000000 /00/\  00      |  0000000| 00| 00
 \_______/|__/  \__/       \_______/|__/|__/
"@
    $bannerTipsText = @"
1. Ask questions.
2. Be specific for the best results.
3. /help for more information.
"@
    $powershellVersion = Get-PowerShellVersion
    $version = Get-CliVersion
    $currentDirectory = (Get-Location).Path
    $bannerInfoText = @"
Using $powershellVersion
DX CLI $version
Started in $currentDirectory
"@

    $bannerAsciiArtWidth = ($bannerAsciiArt -split "`n" | ForEach-Object { $_.Length } | Measure-Object -Maximum).Maximum

    if ($bannerAsciiArtWidth -gt $Host.UI.RawUI.WindowSize.Width) {
        Write-Host $bannerTitle -ForegroundColor Cyan
    }
    else {
        $chars = $bannerAsciiArt.ToCharArray()
        for ($i = 0; $i -lt $chars.Length; $i++) {
            $char = $chars[$i]
            
            if ($i -ne ($chars.Length - 1)) {
                switch ($char) {
                    "0" { Write-Host ([char]0x2588).ToString() -ForegroundColor Cyan -NoNewline }
                    default { Write-Host $char -ForegroundColor Cyan -NoNewline }
                }
            }
            else {
                switch ($char) {
                    "0" { Write-Host ([char]0x2588).ToString() -ForegroundColor Cyan }
                    default { Write-Host $char -ForegroundColor Cyan }
                }
            }
        }
    }

    Write-Host
    Write-Card -Title "Info" -TextColor DarkGray -BorderColor DarkGray -Text $bannerInfoText
    Write-Card -Title "Tips" -BorderColor DarkYellow -Text $bannerTipsText

    [Version]$oldVersion = $FromVersion
    [Version]$currentVersion = Get-CliVersion

    if ($currentVersion -le $oldVersion) {
        Write-Host
        return
    }
    
    $content = Get-Content "$PSScriptRoot\..\RELEASE-NOTES.md" -Raw
    $pattern = '(?ms)^##\s+(?<version>[^\r\n]+)\s*(?<body>.*?)(?=^##\s+|\z)'

    $releases = @([regex]::Matches($content, $pattern) | ForEach-Object {
            [pscustomobject]@{
                Version = [Version]$($_.Groups['version'].Value.Trim())
                Content = $_.Groups['body'].Value.Trim()
            }
        } | Where-Object { $_.Version -gt $oldVersion -and $_.Version -le $currentVersion })

    $releaseNotes = ""

    for ($i = 0; $i -lt $releases.Count; $i++) {
        $releaseNotes += $releases[$i].Content
        if ($i -ne ($releases.Count - 1)) {
            $releaseNotes += "`n"
        }
    }

    Write-Card -Title "Release Notes ($currentVersion)" -BorderColor DarkBlue -Text $releaseNotes
    Write-Host
}
