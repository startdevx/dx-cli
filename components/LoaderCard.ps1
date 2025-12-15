."$PSScriptRoot\Card.ps1"
."$PSScriptRoot\..\utilities\HostUtilities.ps1"

$script:loaderIndex = 0

function Show-LoaderCard {
    $loaderFrames = @(
        ([char]0x280B).ToString() # ⠋
        ([char]0x2819).ToString() # ⠙
        ([char]0x2839).ToString() # ⠹
        ([char]0x2838).ToString() # ⠸
        ([char]0x283C).ToString() # ⠼
        ([char]0x2834).ToString() # ⠴
        ([char]0x2826).ToString() # ⠦
        ([char]0x2827).ToString() # ⠧
        ([char]0x2807).ToString() # ⠇
        ([char]0x280F).ToString() # ⠏
    )
    
    [Console]::CursorVisible = $false
    $loaderTitle = "Searching"
    $loaderText = "Brewing answers... enjoy this moment of suspense."
    Write-Card -Title $loaderTitle -BorderColor Cyan -Text $loaderText -TextColor DarkGray -Symbol $loaderFrames[$script:loaderIndex % $loaderFrames.Count] -SymbolColor DarkGray
    Start-Sleep -Milliseconds 16
}

function Update-LoaderCard {
    $loaderFrames = @(
        ([char]0x280B).ToString() # ⠋
        ([char]0x2819).ToString() # ⠙
        ([char]0x2839).ToString() # ⠹
        ([char]0x2838).ToString() # ⠸
        ([char]0x283C).ToString() # ⠼
        ([char]0x2834).ToString() # ⠴
        ([char]0x2826).ToString() # ⠦
        ([char]0x2827).ToString() # ⠧
        ([char]0x2807).ToString() # ⠇
        ([char]0x280F).ToString() # ⠏
    )

    $script:loaderIndex++
    $loaderText = "Brewing answers... enjoy this moment of suspense."
    $lines = @(Convert-StringToLines -Text $loaderText)
    $rowNumber = $Host.UI.RawUI.CursorPosition.Y - $lines.Count - 1
    [Console]::SetCursorPosition(2, $rowNumber)
    Write-Host $loaderFrames[$script:loaderIndex % $loaderFrames.Count] -NoNewline -ForegroundColor DarkGray
    $rowNumber = $Host.UI.RawUI.CursorPosition.Y + $lines.Count + 1
    [Console]::SetCursorPosition(0, $rowNumber)
    Start-Sleep -Milliseconds 16
}

function Remove-LoaderCard {
    $loaderText = "Brewing answers... enjoy this moment of suspense."
    $lines = @(Convert-StringToLines -Text $loaderText)
    Remove-HostLines -LinesCount ($lines.Count + 2)
    [Console]::CursorVisible = $true
}
