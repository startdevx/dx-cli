# Integrate Your AI

You can integrate your internal AI with DX CLI by providing a PowerShell script that DX CLI automatically executes.

## 🔍 Overview

DX CLI looks for a PowerShell script named `ai.ps1` in the following location:

```shell
$HOME/.dx/ai/ai.ps1
```

This script acts as the interface between DX CLI and your AI provider.

## 🆕 Create the `ai.ps1` file

1. Create the required directory structure `$HOME/.dx/ai`
2. Inside this directory, create a file named `ai.ps1`
3. Add the following parameter definition at the top of the file:

```powershell
param (
    [string]$PromptInput,
    [string]$PromptSystem
)
```

## 📜 Interface of `ai.ps1` script

### Script inputs

The `ai.ps1` script receives two parameters:
* `PromptInput`: the prompt created by the user
* `PromptSystem`: a system prompt provided by DX CLI to give context or instructions to the AI

> [!NOTE]
> You may choose to use, modify, or ignore the system prompt depending on your implementation.

### Script logic

You can use PowerShell language to write your script or you can use any other type of scripting language and call them using its command such as `python`.

### Script output

You can write your script directly in PowerShell, or use any other scripting language and invoke it through its command-line interface (for example, `python`).

## ✍️ Example: OpenAI API integration

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