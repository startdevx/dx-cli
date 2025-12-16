."$PSScriptRoot\Card.ps1"

function Get-PowerShellVersion {
    $majorVersion = $PSVersionTable.PSVersion.Major
    $minorVersion = $PSVersionTable.PSVersion.Minor
    if ($majorVersion -gt 5) {
        return "Using PowerShell $majorVersion.$minorVersion"
    }
    else {
        return "Using Windows PowerShell $majorVersion.$minorVersion"
    }
}

function Write-Banner {
    # https://patorjk.com/software/taag/#p=display&f=Big+Money-ne&t=dx+AI&x=none&v=4&h=4&w=80&we=false
    $bannerTitle = "dx AI"
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
    $powershellVersion = Get-PowerShellVersion
    $currentDirectory = (Get-Location).Path
    $bannerTipsText = @"
1. Ask questions.
2. Be specific for the best results.
3. /help for more information.
"@
    $version = Get-Content -Path "$PSScriptRoot\..\Version"
    $bannerInfoText = @"
$powershellVersion
DX CLI version $version
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
            $isLastChar = $i -eq ($chars.Length - 1)

            if (!$isLastChar) {
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
    Write-Host
}
