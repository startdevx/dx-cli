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
        [string]$PromptInput = ""
    )
    
    $script:isAssistantJobRunning = $true
    $script:assistantJob = Start-Job -ScriptBlock {
        param(
            [string]$PromptInput
        )

        $assistantDirectory = "$HOME\.dx\assistant"

        if (Test-Path "$assistantDirectory\ai.ps1") {
            Set-Location $assistantDirectory
            $result = .\ai.ps1 -PromptInput $PromptInput
            if ($result) {
                return $result
            }
        }

        return "Your AI assistant has not been implemented yet by your organization."
    } -ArgumentList $PromptInput
}
