<#
.SYNOPSIS
    Pull Shark Achievement Helper (Safe Batching)
.DESCRIPTION
    Automates creating lightweight Pull Requests and merging them via the GitHub REST API.
    Increases your merged PR count towards Pull Shark tiers (16 Bronze, 128 Silver, 1024 Gold).
.PARAMETER RepoOwner
    The GitHub owner/username of the repository.
.PARAMETER RepoName
    The name of the repository.
.PARAMETER Token
    GitHub Personal Access Token with repo scope.
.PARAMETER Count
    Number of PRs to create and merge (default: 5, recommended: max 50 per batch).
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$RepoOwner,

    [Parameter(Mandatory=$true)]
    [string]$RepoName,

    [Parameter(Mandatory=$true)]
    [string]$Token,

    [int]$Count = 5
)

$headers = @{
    "Authorization" = "Bearer $Token"
    "Accept" = "application/vnd.github+json"
    "X-GitHub-Api-Version" = "2022-11-28"
    "User-Agent" = "PullShark-Script"
}

Write-Host "Target: $RepoOwner/$RepoName | PR Count: $Count" -ForegroundColor Cyan

for ($i = 1; $i -le $Count; $i++) {
    Write-Host "[$i/$Count] Processing PR..." -ForegroundColor Yellow

    try {
        # 1. Get latest main SHA
        $mainRef = Invoke-RestMethod -Uri "https://api.github.com/repos/$RepoOwner/$RepoName/git/ref/heads/main" -Headers $headers
        $parentSha = $mainRef.object.sha

        # 2. Create blob
        $blob = Invoke-RestMethod -Uri "https://api.github.com/repos/$RepoOwner/$RepoName/git/blobs" -Method Post -Headers $headers -Body (@{
            content = "Pull Shark automated contribution item #$i at $(Get-Date -Format 'o')"
            encoding = "utf-8"
        } | ConvertTo-Json)

        # 3. Create tree
        $tree = Invoke-RestMethod -Uri "https://api.github.com/repos/$RepoOwner/$RepoName/git/trees" -Method Post -Headers $headers -Body (@{
            base_tree = $parentSha
            tree = @(
                @{
                    path = "prs/pull-shark-batch-$i.txt"
                    mode = "100644"
                    type = "blob"
                    sha = $blob.sha
                }
            )
        } | ConvertTo-Json)

        # 4. Create commit
        $commit = Invoke-RestMethod -Uri "https://api.github.com/repos/$RepoOwner/$RepoName/git/commits" -Method Post -Headers $headers -Body (@{
            message = "Pull Shark progression commit #$i"
            tree = $tree.sha
            parents = @($parentSha)
        } | ConvertTo-Json)

        # 5. Create branch ref
        $branchName = "ps-batch-$i-$(Get-Random)"
        $branchRef = Invoke-RestMethod -Uri "https://api.github.com/repos/$RepoOwner/$RepoName/git/refs" -Method Post -Headers $headers -Body (@{
            ref = "refs/heads/$branchName"
            sha = $commit.sha
        } | ConvertTo-Json)

        # 6. Create PR
        $pr = Invoke-RestMethod -Uri "https://api.github.com/repos/$RepoOwner/$RepoName/pulls" -Method Post -Headers $headers -Body (@{
            title = "Pull Shark batch increment #$i"
            head = $branchName
            base = "main"
        } | ConvertTo-Json)

        Start-Sleep -Milliseconds 600

        # 7. Merge PR
        $merge = Invoke-RestMethod -Uri "https://api.github.com/repos/$RepoOwner/$RepoName/pulls/$($pr.number)/merge" -Method Put -Headers $headers -Body (@{
            merge_method = "merge"
        } | ConvertTo-Json)

        # 8. Clean up temporary branch
        Invoke-RestMethod -Uri "https://api.github.com/repos/$RepoOwner/$RepoName/git/refs/heads/$branchName" -Method Delete -Headers $headers

        Write-Host "[$i/$Count] Merged PR #$($pr.number) successfully!" -ForegroundColor Green
        Start-Sleep -Milliseconds 500
    } catch {
        Write-Host "Error during PR #$i : $_" -ForegroundColor Red
        Start-Sleep -Seconds 2
    }
}

Write-Host "Batch processing complete!" -ForegroundColor Green
