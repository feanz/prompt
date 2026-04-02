oh-my-posh init pwsh | Invoke-Expression

function yolo {
  param([string]$worktree = "")
  if ($worktree) {
    quell claude -- --dangerously-skip-permissions -w $worktree
  } else {
    quell claude -- --dangerously-skip-permissions
  }
}

Import-Module Terminal-Icons
Import-Module z


