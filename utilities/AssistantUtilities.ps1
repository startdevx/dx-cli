$script:assistantJob = $null
$script:isAssistantJobRunning = $false

function New-AssistantMessage {
    param(
        [string]$Message = ""
    )

    return @{
        "role"    = "assistant"
        "content" = $Message
    }
}

function Test-AssistantJobRunning {
    return $script:isAssistantJobRunning
}

function Test-AssistantJobCompleted {
    if ($script:assistantJob) {
        return $script:assistantJob.State -eq "Completed"
    }

    return $false
}

function Get-AssistantMessage {
    $assistantJobResponse = Receive-Job -Job $script:assistantJob
    $assistantMessage = New-AssistantMessage -Message $assistantJobResponse

    Remove-Job -Job $script:assistantJob
    $script:isAssistantJobRunning = $false
    $script:assistantJob = $null

    return $assistantMessage
}

function Start-AssistantJob {
    param(
        [string]$PromptInput = "",
        [array]$MessageHistory = @()
    )

    $PromptSystem = Get-Content "$PSScriptRoot\..\prompts\system.md" -Raw
    
    $script:isAssistantJobRunning = $true
    $script:assistantJob = Start-Job -ScriptBlock {
        param(
            [string]$PromptInput,
            [string]$PromptSystem,
            [string]$MessageHistory
        )

        $assistantDirectory = "$HOME\.dx\ai"

        if (Test-Path "$assistantDirectory\ai.ps1") {
            Set-Location $assistantDirectory
            $result = .\ai.ps1 -PromptInput $PromptInput -PromptSystem $PromptSystem -MessageHistory $MessageHistory
            if ($result) {
                return $result
            }
        }

        return "Your AI assistant has not been integrated yet by your organization.`nMore info at https://github.com/startdevx/dx-cli/blob/main/docs/integrate-your-ai.md"
    } -ArgumentList $PromptInput, $PromptSystem, $MessageHistory
}
