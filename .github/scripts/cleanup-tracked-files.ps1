$removed = @()
$paths = @('.next','dist','build','node_modules','.vercel','.env.local')
foreach ($p in $paths) {
  $matches = git ls-files | Select-String -Pattern ("^" + [regex]::Escape($p))
  if ($matches) {
    Write-Output "Removing tracked: $p"
    git rm -r --cached $p 2>$null
    $removed += $p
  }
}
if ($removed.Count -gt 0) {
  git commit -m ("chore: remove generated/build and local files from repo ({0})" -f ($removed -join ", "))
  git push
} else {
  Write-Output "No tracked build/local files found."
}
