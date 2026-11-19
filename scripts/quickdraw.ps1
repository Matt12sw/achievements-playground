<#
.SYNOPSIS
    Quickdraw Achievement Helper
.DESCRIPTION
    Creates an issue on the current repository and closes it within seconds (< 5 minutes)
    to qualify for the GitHub "Quickdraw" achievement badge.
.PARAMETER RepoOwner
    The GitHub owner/username of the repository.
.PARAMETER RepoName
    The name of the repository.
.PARAMETER Token
    GitHub Personal Access Token (classic or fine-grained) with `issues:write` scope.
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$RepoOwner,

    [Parameter(Mandatory=$true)]
    [string]$RepoName,

    [Parameter(Mandatory=$true)]
    [string]$Token
)

$headers = @{
    "Authorization" = "Bearer $Token"
    "Accept" = "application/vnd.github+json"
    "X-GitHub-Api-Version" = "2022-11-28"
    "User-Agent" = "Quickdraw-Script"
}

Write-Host "Creating temporary issue in $RepoOwner/$RepoName..." -ForegroundColor Cyan
$createBody = @{
    title = "Quickdraw Achievement Trigger"
    body  = "This issue is automatically created to trigger the Quickdraw badge and will close in 3 seconds."
} | ConvertTo-Json

$issue = Invoke-RestMethod -Uri "https://api.github.com/repos/$RepoOwner/$RepoName/issues" -Method Post -Headers $headers -Body $createBody
Write-Host "Issue #$($issue.number) created: $($issue.html_url)" -ForegroundColor Green

Write-Host "Waiting 3 seconds before closing..." -ForegroundColor Yellow
Start-Sleep -Seconds 3

Write-Host "Closing issue #$($issue.number)..." -ForegroundColor Cyan
$closeBody = @{
    state = "closed"
    state_reason = "completed"
} | ConvertTo-Json

$closedIssue = Invoke-RestMethod -Uri "https://api.github.com/repos/$RepoOwner/$RepoName/issues/$($issue.number)" -Method Patch -Headers $headers -Body $closeBody
Write-Host "Issue #$($issue.number) successfully closed (< 5 minutes). Quickdraw qualification met!" -ForegroundColor Green
