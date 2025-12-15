$script:userHistoryIndex = 0
$script:messageHistory = @()

function New-UserMessage {
    param(
        [string]$Message = ""
    )

    return @{
        "role"    = "user"
        "content" = $Message
    }
}

function Add-MessageToHistory {
    param(
        [Parameter(Mandatory)]
        [object]$Message
    )

    $script:messageHistory += $Message
    $script:userHistoryIndex = @(Get-UserMessagesFromHistory).Count
}

function Reset-MessageHistory {
    $script:messageHistory = @()
}

function Get-MessagesFromHistory {
    return $script:messageHistory
}

function Get-UserMessagesFromHistory {
    return $script:messageHistory | Where-Object { $_.role -eq "user" }
}

function Get-UserMessageContentFromHistoryIndex {
    $userMessages = @(Get-UserMessagesFromHistory)
    $userMessageContent = $userMessages[$script:userHistoryIndex].content
    if (!$userMessageContent) {
        return ""
    }

    return $userMessageContent
}

function Update-UserHistoryIndex {
    param (
        [switch] $Decrease,
        [switch] $Increase
    )
    
    $userMessages = @(Get-UserMessagesFromHistory)
    if (!$userMessages) {
        return
    }

    if ($Decrease) {
        if ($script:userHistoryIndex -eq $userMessages.Count) {
            $script:userHistoryIndex--
        }
        elseif (($script:userHistoryIndex - 1) -ge 0) {
            $script:userHistoryIndex--
        }
        else {
            $script:userHistoryIndex = 0
        }
        return
    }

    if ($Increase) {
        if ($script:userHistoryIndex -lt $userMessages.Count) {
            $script:userHistoryIndex++
        }
        return
    }
}
