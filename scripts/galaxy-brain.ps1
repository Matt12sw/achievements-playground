<#
.SYNOPSIS
    Galaxy Brain Achievement Q&A Automation
.DESCRIPTION
    Creates a discussion in the Q&A category with Account A, answers with Account B,
    and marks Account B's response as the Accepted Answer via GitHub GraphQL API.
.PARAMETER RepoOwner
    The GitHub owner/username of the repository.
.PARAMETER RepoName
    The name of the repository.
.PARAMETER QuestionerToken
    GitHub Personal Access Token for the user asking the question and marking the answer.
.PARAMETER AnswererToken
    GitHub Personal Access Token for the user receiving the Galaxy Brain badge.
.PARAMETER Count
    Number of accepted answers to generate (2 for Base, 8 Bronze, 16 Silver, 32 Gold).
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$RepoOwner,

    [Parameter(Mandatory=$true)]
    [string]$RepoName,

    [Parameter(Mandatory=$true)]
    [string]$QuestionerToken,

    [Parameter(Mandatory=$true)]
    [string]$AnswererToken,

    [int]$Count = 2
)

$headersQuestioner = @{ "Authorization" = "Bearer $QuestionerToken"; "Content-Type" = "application/json"; "User-Agent" = "GalaxyBrain-Script" }
$headersAnswerer   = @{ "Authorization" = "Bearer $AnswererToken";   "Content-Type" = "application/json"; "User-Agent" = "GalaxyBrain-Script" }

# 1. Fetch Repo ID and Q&A Category ID
$fetchQuery = @"
{
  repository(owner: "$RepoOwner", name: "$RepoName") {
    id
    discussionCategories(first: 10) {
      nodes {
        id
        name
        isAnswerable
      }
    }
  }
}
"@

$repoData = Invoke-RestMethod -Uri "https://api.github.com/graphql" -Method Post -Headers $headersQuestioner -Body (@{ query = $fetchQuery } | ConvertTo-Json)
$repoId = $repoData.data.repository.id
$qaCategory = $repoData.data.repository.discussionCategories.nodes | Where-Object { $_.isAnswerable -eq $true } | Select-Object -First 1

if (-not $qaCategory) {
    Write-Error "No answerable Q&A discussion category found. Please enable Discussions on your repository."
    exit 1
}

Write-Host "Repository ID: $repoId | Category: $($qaCategory.name) ($($qaCategory.id))" -ForegroundColor Cyan

for ($i = 1; $i -le $Count; $i++) {
    Write-Host "[$i/$Count] Creating discussion..." -ForegroundColor Yellow

    # Step 1: Create Discussion
    $m1 = @"
mutation {
  createDiscussion(input: {
    repositoryId: "$repoId",
    categoryId: "$($qaCategory.id)",
    title: "Question #$i on best practices",
    body: "How should module #$i be configured?"
  }) {
    discussion { id }
  }
}
"@
    $res1 = Invoke-RestMethod -Uri "https://api.github.com/graphql" -Method Post -Headers $headersQuestioner -Body (@{ query = $m1 } | ConvertTo-Json)
    $discId = $res1.data.createDiscussion.discussion.id

    # Step 2: Answer as Answerer
    $m2 = @"
mutation {
  addDiscussionComment(input: {
    discussionId: "$discId",
    body: "Here is the recommended verified solution for module #$i."
  }) {
    comment { id }
  }
}
"@
    $res2 = Invoke-RestMethod -Uri "https://api.github.com/graphql" -Method Post -Headers $headersAnswerer -Body (@{ query = $m2 } | ConvertTo-Json)
    $commentId = $res2.data.addDiscussionComment.comment.id

    # Step 3: Mark as Answer
    $m3 = @"
mutation {
  markDiscussionCommentAsAnswer(input: {
    id: "$commentId"
  }) {
    discussion { id }
  }
}
"@
    $res3 = Invoke-RestMethod -Uri "https://api.github.com/graphql" -Method Post -Headers $headersQuestioner -Body (@{ query = $m3 } | ConvertTo-Json)

    Write-Host "[$i/$Count] Answer marked as accepted!" -ForegroundColor Green
    Start-Sleep -Milliseconds 800
}

Write-Host "All $Count discussions answered and accepted successfully!" -ForegroundColor Green
