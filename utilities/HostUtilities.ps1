function Remove-HostLines {
    param(
        [int]$LinesCount = 0
    )

    $initialCursorPositionY = $Host.UI.RawUI.CursorPosition.Y

    for ($i = 1; $i -le $LinesCount; $i++) {
        $lineNumber = $initialCursorPositionY - $i

        if ($lineNumber -lt 0) {
            $lineNumber = 0
        }

        [Console]::SetCursorPosition(0, $lineNumber)
        Write-Host (" " * $Host.UI.RawUI.WindowSize.Width) -NoNewline
        [Console]::SetCursorPosition(0, $lineNumber)
    }
}

function Reset-Host {
    if ($PSVersionTable.PSVersion.Major -gt 5) {
        Write-Host "`e[H`e[2J`e[3J"
    }
    else {
        Clear-Host
    }
}
