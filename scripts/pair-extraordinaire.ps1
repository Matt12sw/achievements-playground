<#
.SYNOPSIS
    Pair Extraordinaire Achievement Helper
.DESCRIPTION
    Creates a branch, a commit with Git Co-authored-by trailers, opens a Pull Request,
    and merges it into the default branch to unlock the Pair Extraordinaire badge.
.PARAMETER CoAuthorName
    The GitHub display name or username of the second account.
.PARAMETER CoAuthorEmail
    The verified email address associated with the second GitHub account.
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$CoAuthorName,

    [Parameter(Mandatory=$true)]
    [string]$CoAuthorEmail,

    [string]$BranchName = "feature/pair-achievement-$(Get-Random)"
)

Write-Host "Creating branch $BranchName..." -ForegroundColor Cyan
git checkout -b $BranchName

# Create or touch a file
$filePath = "pair-collaboration.txt"
"Co-author contribution timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Out-File -FilePath $filePath -Append -Encoding utf8
git add $filePath

# Commit with proper trailer formatting
$commitMsg = @"
Add contribution for Pair Extraordinaire badge

Collaboration with $CoAuthorName.

Co-authored-by: $CoAuthorName <$CoAuthorEmail>
"@

Write-Host "Committing with Co-authored-by trailer..." -ForegroundColor Cyan
git commit -m "$commitMsg"

Write-Host "Pushing branch to origin..." -ForegroundColor Cyan
git push -u origin $BranchName

Write-Host "`nBranch successfully pushed! Next steps:" -ForegroundColor Green
Write-Host "1. Open a Pull Request from '$BranchName' into your default branch (main)." -ForegroundColor Yellow
Write-Host "2. Merge the Pull Request (using Merge commit)." -ForegroundColor Yellow
Write-Host "3. Both the author and co-author will receive the Pair Extraordinaire achievement!" -ForegroundColor Green
