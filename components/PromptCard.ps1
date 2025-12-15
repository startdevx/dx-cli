."$PSScriptRoot\Card.ps1"
."$PSScriptRoot\..\utilities\HostUtilities.ps1"

$script:numberOfLinesCurrentlyDisplayed = 1

function Show-PromptCard {
    param(
        [string]$PromptInput = ""
    )

    [Console]::CursorVisible = $false

    if (!$PromptInput) {
        $textColor = "DarkGray"
        $PromptInput = "Ask your AI"
        $columnNumber = 4
        $script:numberOfLinesCurrentlyDisplayed = 1
    }
    else {
        $textColor = "Gray"
        $lines = @(Convert-StringToLines -Text $PromptInput)
        $columnNumber = $lines[-1].Length + 4
        $script:numberOfLinesCurrentlyDisplayed = $lines.Count
    }

    $symbol = ([char]0x003E).ToString() # >
    Write-Card -Title "Prompt" -BorderColor Cyan -Text $PromptInput -TextColor $textColor -Symbol $symbol

    $rowNumber = $Host.UI.RawUI.CursorPosition.Y - 2
    [Console]::SetCursorPosition($columnNumber, $rowNumber)
    [Console]::CursorVisible = $true
}

function Update-PromptCard {
    param(
        [string]$PromptInput = ""
    )

    [Console]::CursorVisible = $false

    $lines = @(Convert-StringToLines -Text $PromptInput)
    if ($lines.Count -eq $script:numberOfLinesCurrentlyDisplayed) {
        if (!$PromptInput) {
            [Console]::SetCursorPosition(4, $Host.UI.RawUI.CursorPosition.Y)
            $hintText = "Ask your AI"
            Write-Host ($hintText + " " * ($Host.UI.RawUI.WindowSize.Width - 6 - $hintText.Length)) -ForegroundColor "DarkGray" -NoNewline
            [Console]::SetCursorPosition(4, $Host.UI.RawUI.CursorPosition.Y)
        }
        else {
            [Console]::SetCursorPosition(4, $Host.UI.RawUI.CursorPosition.Y)
            Write-Host ($lines[-1] + " " * ($Host.UI.RawUI.WindowSize.Width - 6 - $lines[-1].Length)) -ForegroundColor "Gray" -NoNewline
            $columnNumber = $lines[-1].Length + 4
            [Console]::SetCursorPosition($columnNumber, $Host.UI.RawUI.CursorPosition.Y)
        }
    }
    else {
        Remove-PromptCard
        Show-PromptCard -PromptInput $PromptInput
    }

    [Console]::CursorVisible = $true
}

function Remove-PromptCard {
    [Console]::CursorVisible = $false
    $rowNumber = $Host.UI.RawUI.CursorPosition.Y + 2
    [Console]::SetCursorPosition(0, $rowNumber)
    Remove-HostLines ($script:numberOfLinesCurrentlyDisplayed + 2)
    [Console]::CursorVisible = $true
}
