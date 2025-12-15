# Integrate Your AI

You can integrate your internal AI with DX CLI by providing a PowerShell script that DX CLI automatically executes.

## Overview

DX CLI looks for a PowerShell script named `ai.ps1` in the following location:

```shell
$HOME/.dx/ai/ai.ps1
```

This script acts as the interface between DX CLI and your AI provider.

## Create the `ai.ps1` File

1. Create the required directory structure `$HOME/.dx/ai`
2. Inside this directory, create a file named `ai.ps1`
3. Add the following parameter definition at the top of the file:

```powershell
param (
    [string]$PromptInput,
    [string]$PromptSystem
)
```

## Interface of `ai.ps1` script

### Script inputs

The `ai.ps1` script receives two parameters:
* `PromptInput`: the prompt created by the user
* `PromptSystem`: a system prompt provided by DX CLI to give context or instructions to the AI.

> [!NOTE]
> You may choose to use, modify, or ignore the system prompt depending on your implementation.

### Script output

The script must return a **string**. This returned string is displayed directly in the DX CLI user interface.

## Example: OpenAI API Integration

Below is an example implementation using the OpenAI Responses API.

```powershell
param (
    [string]$PromptInput,
    [string]$PromptSystem
)

try {
    $model = "gpt-5-nano"
    $uri = "https://api.openai.com/v1/responses"

    $headers = @{
        "Authorization" = "Bearer $Env:OPENAIKEY"
        "Content-Type"  = "application/json"
    }

    $body = @{
        "model" = $model;
        "input" = $PromptInput;
    } | ConvertTo-Json -Depth 2 -Compress

    $response = Invoke-RestMethod -Method POST -Headers $headers -Uri $uri -Body ([System.Text.Encoding]::UTF8.GetBytes($body)) -ErrorAction Stop
    return $response.output[1].content[0].text.Trim()
}
catch {
    $errorResponse = $_ | ConvertFrom-Json
    return $errorResponse.error.message
}
```