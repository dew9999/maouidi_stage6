$ErrorActionPreference = 'Continue'
$output = flutter analyze --no-preamble 2>&1 | Out-String -Width 4096
$output | Out-File -FilePath "full_analyze.txt" -Encoding UTF8
Write-Output $output
