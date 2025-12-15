function New-SystemMessage {
    param(
        [string]$Message = ""
    )

    return @{
        "role"    = "system"
        "content" = $Message
    }
}

function New-SystemAboutMessage {
    $version = Get-Content -Path "$PSScriptRoot\..\version"
    $aboutMessage = @"
About DX CLI

CLI version : $version
Last update : 2025-12-04
GitHub      : https://github.com/startdevx
License     : MIT Open Source License
"@

    return New-SystemMessage -Message $aboutMessage
}

function New-SystemHelpMessage {
    $helpMessage = @"
Basics:
  1. Ask any questions. DX CLI will answer based on your company knowledge.
  2. Be specific for the best results.

Commands:
  /about     - Show DX CLI info
  /clear     - Clear the screen and conversation history
  /docs      - Open DX CLI documentation in your browser
  /help      - Get help for DX CLI
  /quit      - Quit application

Keyboard Shortcuts:
  Backspace  - Delete last message character
  Ctrl+C     - Force quit application
  Ctrl+Enter - New line (Windows only)
  Ctrl+J     - New line
  Enter      - Send message
  Up/Down    - Cycle through your message history
"@

    return New-SystemMessage -Message $helpMessage
}

function New-SystemExitMessage {
    $exitMessage = "Thanks for using DX CLI! See you next time."
    return New-SystemMessage -Message $exitMessage
}

function New-SystemUnknownCommandMessage {
    param(
        [string]$Command = ""
    )
    
    return New-SystemMessage -Message "'$Command' is not valid. Use '/help' for more information."
}

function New-SystemDocsMessage {
    param(
        [string]$Url = ""
    )
    
    return New-SystemMessage -Message "Opening $Url in your browser"
}