."$PSScriptRoot\components\Banner.ps1"
."$PSScriptRoot\components\LoaderCard.ps1"
."$PSScriptRoot\components\MessageCard.ps1"
."$PSScriptRoot\components\PromptCard.ps1"
."$PSScriptRoot\utilities\AssistantUtilities.ps1"
."$PSScriptRoot\utilities\HostUtilities.ps1"
."$PSScriptRoot\utilities\SystemUtilities.ps1"
."$PSScriptRoot\utilities\UserUtilities.ps1"

$script:previousWindowSizeWidth = $Host.UI.RawUI.WindowSize.Width
$script:previousPromptInput = ""

Reset-Host
Write-Banner
Show-PromptCard -PromptInput $script:previousPromptInput

while ($true) {
    $currentWindowSizeWidth = $Host.UI.RawUI.WindowSize.Width
    $currentPromptInput = $script:previousPromptInput
    $isEnterKeyPressed = $false
    
    if ($currentWindowSizeWidth -ne $script:previousWindowSizeWidth) {
        Reset-Host
        Write-Banner
        $messages = @(Get-MessagesFromHistory)
        Write-MessageCards -Messages $messages

        if (Test-AssistantJobRunning) {
            Show-LoaderCard
        }
        else {
            Show-PromptCard -PromptInput $currentPromptInput
        }
        
        $script:previousWindowSizeWidth = $currentWindowSizeWidth
    }

    if ([Console]::KeyAvailable) {
        $keyInfo = [Console]::ReadKey($true)
        $key = $keyInfo.Key
        $keyModifiers = $keyInfo.Modifiers
        if (!(Test-AssistantJobRunning)) {
            switch ($key) {
                "UpArrow" {
                    Update-UserHistoryIndex -Decrease
                    $currentPromptInput = Get-UserMessageContentFromHistoryIndex
                }
                "DownArrow" {
                    Update-UserHistoryIndex -Increase
                    $currentPromptInput = Get-UserMessageContentFromHistoryIndex
                }
                "Escape" {
                    # Do nothing
                }
                "Tab" {
                    # Do nothing
                }
                "Backspace" {
                    if ($currentPromptInput.Length -gt 0) {
                        $currentPromptInput = $currentPromptInput.Substring(0, $currentPromptInput.Length - 1)
                    }
                }
                "Enter" {
                    if ($keyModifiers -eq "Control") {
                        $currentPromptInput += "`n"
                    }
                    elseif ($currentPromptInput.Length -gt 0) {
                        $isEnterKeyPressed = $true
                    }
                }
                default {
                    if ($keyInfo.KeyChar -and $keyInfo.KeyChar -ne [char]0) {
                        $currentPromptInput += $keyInfo.KeyChar
                    }
                }
            }
        }
    }

    if ($currentPromptInput -ne $script:previousPromptInput) {
        Update-PromptCard -PromptInput $currentPromptInput
    }

    if (Test-AssistantJobCompleted) {
        $assistantMessage = Get-AssistantMessage
        Add-MessageToHistory -Message $assistantMessage

        Remove-LoaderCard
        Write-AssistantMessageCard -Message $assistantMessage
        Show-PromptCard -PromptInput $currentPromptInput
    }

    if (Test-AssistantJobRunning) {
        Update-LoaderCard
    }

    if ($isEnterKeyPressed) {
        Remove-PromptCard

        $userMessage = New-UserMessage -Message $currentPromptInput
        Add-MessageToHistory -Message $userMessage
        Write-UserMessageCard -Message $userMessage
        
        if ($currentPromptInput.StartsWith("/")) {
            $command = $currentPromptInput.Substring(1)
            switch ($command) {
                'about' {
                    $systemAboutMessage = New-SystemAboutMessage
                    Add-MessageToHistory -Message $systemAboutMessage
                    Write-SystemMessageCard -Message $systemAboutMessage
                }
                'clear' {
                    Reset-MessageHistory
                    Reset-Host
                    Write-Banner
                }
                'docs' {
                    $url = "https://github.com/startdevx"

                    $systemDocsMessage = New-SystemDocsMessage -Url $url
                    Add-MessageToHistory -Message $systemDocsMessage
                    Write-SystemMessageCard -Message $systemDocsMessage

                    Start-Process -FilePath $url
                }
                'help' {
                    $systemHelpMessage = New-SystemHelpMessage
                    Add-MessageToHistory -Message $systemHelpMessage
                    Write-SystemMessageCard -Message $systemHelpMessage
                }
                'quit' {
                    $systemExitMessage = New-SystemExitMessage
                    Write-SystemMessageCard -Message $systemExitMessage
                    exit 0
                }
                default {
                    $unknownCommandMessage = New-SystemUnknownCommandMessage -Command $command
                    Add-MessageToHistory -Message $unknownCommandMessage
                    Write-SystemMessageCard -Message $unknownCommandMessage
                }
            }

            $currentPromptInput = ""
            Show-PromptCard -PromptInput $currentPromptInput
        }
        else {
            Show-LoaderCard
            Start-AssistantJob -PromptInput $currentPromptInput
            $currentPromptInput = ""
        }
    }

    $script:previousPromptInput = $currentPromptInput
}
