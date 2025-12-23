# Parse and display flutter analyze errors
$output = flutter analyze 2>&1 | Out-String
$lines = $output -split "`n"

# Extract error lines with file paths
$errors = @()
foreach ($line in $lines) {
    if ($line -match "error\s+-.*lib\\(.+):(\d+):(\d+)") {
        $errors += [PSCustomObject]@{
            File = $matches[1]
            Line = $matches[2]
            Column = $matches[3]
            FullLine = $line.Trim()
        }
    }
}

Write-Output "`n=== ERROR LOCATIONS ==="
$errors | Format-Table -AutoSize
Write-Output "`nTotal Errors: $($errors.Count)"
