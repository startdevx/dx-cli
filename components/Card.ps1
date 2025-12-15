function Convert-StringToLines {
    param(
        [string]$Text,
        [int]$MaxWidth = $Host.UI.RawUI.WindowSize.Width - 6
    )

    $lines = @()

    if (!$Text -or $MaxWidth -le 0) {
        $lines += ""
        return $lines
    }

    $textWithoutTabs = $Text -replace "`t", "    "
    $paragraphs = $textWithoutTabs -split "`r?`n"
    
    foreach ($paragraph in $paragraphs) {
        if ($paragraph) {
            $charPosition = 0
            while ($charPosition -lt $paragraph.Length) {
                $numberOfCharsLeft = $paragraph.Length - $charPosition
                $currentLine = $paragraph.Substring($charPosition, [Math]::Min($MaxWidth, $numberOfCharsLeft))
                $isCurrentLineMaxWidth = $currentLine.Length -eq $MaxWidth
                $doesNextCharExist = $null -ne $paragraph[$charPosition + $MaxWidth]
                if ($isCurrentLineMaxWidth -and $doesNextCharExist) {
                    $lastChar = $currentLine[-1]
                    $nextChar = $paragraph[$charPosition + $MaxWidth]
                    if ($lastChar -match "\s" -and $nextChar -match "\S") {
                        $lines += $currentLine
                        $charPosition += $MaxWidth
                    }
                    else {
                        $currentLineBlocks = @([regex]::Matches($currentLine, "\S+|\s+") | ForEach-Object { $_.Value })
                        if ($currentLineBlocks.Count -eq 1) {
                            $lines += $currentLine
                            $charPosition += $MaxWidth
                        }
                        elseif ($currentLineBlocks[-1] -match "\S+") {
                            $newLength = $MaxWidth - $currentLineBlocks[-1].Length
                            $lines += $paragraph.Substring($charPosition, $newLength)
                            $charPosition += $newLength
                        }
                        elseif (($currentLineBlocks[-1].Length + $currentLineBlocks[-2].Length) -eq $MaxWidth) {
                            $lines += $currentLine
                            $charPosition += $MaxWidth
                        }
                        else {
                            $newLength = $MaxWidth - $currentLineBlocks[-1].Length - $currentLineBlocks[-2].Length
                            $lines += $paragraph.Substring($charPosition, $newLength)
                            $charPosition += $newLength
                        }
                    }
                }
                else {
                    $lines += $currentLine
                    $charPosition += $MaxWidth
                }
            }
        }
        else {
            $lines += ""
        }
    }
    
    return $lines
}

function Write-CardTopBorder {
    param(
        [string]$Title = "",
        [ConsoleColor]$TitleColor = "White",
        [ConsoleColor]$BorderColor = "White"
    )

    if ($Title) {
        $Title = $Title.Trim()
    }
    else {
        $Title = ""
    }

    $topLeft = ([char]0x256D).ToString()    # ╭
    $topRight = ([char]0x256E).ToString()   # ╮
    $horizontal = ([char]0x2500).ToString() # ─

    $windowWidth = $Host.UI.RawUI.WindowSize.Width
    $minimumWidthRequiredWithTitle = 8    # "╭──  ──╮"
    $isHostWidthSufficientToDisplayTitle = $windowWidth -ge ($Title.Length + $minimumWidthRequiredWithTitle)

    if ($Title -and $isHostWidthSufficientToDisplayTitle) {
        Write-Host ($topLeft + $horizontal * 2) -ForegroundColor $BorderColor -NoNewline
        Write-Host (" " + $Title + " ") -ForegroundColor $TitleColor -NoNewline
        Write-Host ($horizontal * ($windowWidth - $Title.Length - $minimumWidthRequiredWithTitle) + $horizontal * 2 + $topRight) -ForegroundColor $BorderColor -NoNewline
    }
    else {
        $minimumWidthRequiredWithoutTitle = 2 # "╭╮"
        Write-Host ($topLeft + $horizontal * ($windowWidth - $minimumWidthRequiredWithoutTitle) + $topRight) -ForegroundColor $BorderColor
    }
}

function Write-CardLine {
    param(
        [ConsoleColor]$BorderColor = "White",
        [string]$Symbol = "",
        [ConsoleColor]$SymbolColor = "Cyan",
        [string]$Text = "",
        [ConsoleColor]$TextColor = "Gray",
        [int]$PaddingLeft = 3,
        [int]$PaddingRight = 1
    )

    $vertical = ([char]0x2502).ToString() # │
    
    Write-Host $vertical -ForegroundColor $BorderColor -NoNewline

    $minimumWidthRequired = 2 # "││"
    $totalPaddingWidth = $PaddingLeft + $PaddingRight + $minimumWidthRequired
    $maxTextWidthAllowed = $Host.UI.RawUI.WindowSize.Width - $totalPaddingWidth

    if ($Text.Length -le $maxTextWidthAllowed) {
        if ($Symbol) {
            Write-Host " $Symbol " -ForegroundColor $SymbolColor -NoNewline
        }
        else {
            Write-Host (" " * $PaddingLeft) -NoNewline
        }

        Write-Host ($Text + " " * ($maxTextWidthAllowed - $Text.Length)) -ForegroundColor $TextColor -NoNewline
        Write-Host (" " * $PaddingRight) -NoNewline
    }
    else {
        Write-Host (" " * ($Host.UI.RawUI.WindowSize.Width - $minimumWidthRequired)) -NoNewline
    }

    Write-Host $vertical -ForegroundColor $BorderColor
}

function Write-CardBottomBorder {
    param(
        [ConsoleColor]$BorderColor = "White"
    )

    $windowWidth = $Host.UI.RawUI.WindowSize.Width
    $minimumWidthRequired = 2 # "╰╯"

    $bottomLeft = ([char]0x2570).ToString()  # ╰
    $bottomRight = ([char]0x256F).ToString() # ╯
    $horizontal = ([char]0x2500).ToString()  # ─

    Write-Host ($bottomLeft + $horizontal * ($windowWidth - $minimumWidthRequired) + $bottomRight) -ForegroundColor $BorderColor
}

function Write-Card {
    param(
        [string]$Title = "",
        [ConsoleColor]$TitleColor = "White",
        [ConsoleColor]$BorderColor = "White",
        [string]$Symbol = "",
        [ConsoleColor]$SymbolColor = "Cyan",
        [string]$Text = "",
        [ConsoleColor]$TextColor = "Gray",
        [int]$PaddingLeft = 3,
        [int]$PaddingRight = 1
    )

    if ($Symbol) {
        $PaddingLeft = 3
        $Symbol = $Symbol[0]
    }

    $minimumWidthRequired = 2 # "││"
    $totalPaddingWidth = $PaddingLeft + $PaddingRight + $minimumWidthRequired
    $maxTextWidthAllowed = $Host.UI.RawUI.WindowSize.Width - $totalPaddingWidth
    $lines = @(Convert-StringToLines -Text $Text -MaxWidth $maxTextWidthAllowed)

    Write-CardTopBorder -Title $Title -TitleColor $TitleColor -BorderColor $BorderColor

    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($i -eq 0) {
            Write-CardLine -BorderColor $BorderColor -Text $lines[$i] -TextColor $TextColor -PaddingLeft $PaddingLeft -PaddingRight $PaddingRight -Symbol $Symbol -SymbolColor $SymbolColor
        }
        else {
            Write-CardLine -BorderColor $BorderColor -Text $lines[$i] -TextColor $TextColor -PaddingLeft $PaddingLeft -PaddingRight $PaddingRight
        }
    }

    Write-CardBottomBorder -BorderColor $BorderColor
}
