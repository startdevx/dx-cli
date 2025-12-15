."$PSScriptRoot\Card.ps1"

function Write-AssistantMessageCard {
    param(
        [object]$Message = ""
    )

    $symbol = ([char]0x2605).ToString() # ★
    Write-Card -Title "Assistant" -Text $Message.content -Symbol $symbol -SymbolColor DarkMagenta
}

function Write-SystemMessageCard {
    param(
        [object]$Message = ""
    )

    $symbol = ([char]0x2756).ToString() # ❖
    Write-Card -Title "System" -Text $Message.content -Symbol $symbol -SymbolColor DarkCyan
}

function Write-UserMessageCard {
    param(
        [object]$Message = ""
    )

    $symbol = ([char]0x25C9).ToString() # ◉
    Write-Card -Title "You" -BorderColor DarkGray -Text $Message.content -TextColor DarkGray -Symbol $symbol -SymbolColor DarkGreen
}

function Write-MessageCards {
    param(
        [array]$Messages = @()
    )

    foreach ($message in $Messages) {
        if ($message.role -eq "assistant") {
            Write-AssistantMessageCard -Message $message
        }
        if ($message.role -eq "system") {
            Write-SystemMessageCard -Message $message
        }
        if ($message.role -eq "user") {
            Write-UserMessageCard -Message $message
        }
    }
}
