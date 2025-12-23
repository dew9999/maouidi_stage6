# Parse flutter analyze output and categorize errors
$output = flutter analyze 2>&1 | Out-String

# Extract all error/warning/info lines with their file paths
$lines = $output -split "`n"
$issues = @()

for ($i = 0; $i -lt $lines.Count; $i++) {
    $line = $lines[$i]
    
    # Match error/warning/info patterns
    if ($line -match "(error|warning|info)\s+-\s+(.+?)\s+-\s+(lib\\\\[^:]+):(\d+):(\d+)\s+-\s+(\S+)") {
        $issues += [PSCustomObject]@{
            Severity = $matches[1]
            Message = $matches[2].Trim()
            File = $matches[3]
            Line = $matches[4]
            Column = $matches[5]
            Code = $matches[6]
        }
    }
}

# Group by error code
Write-Output "`n=== ERROR SUMMARY BY CODE ===`n"
$issues | Group-Object Code | Sort-Object Count -Descending | Select-Object Count, Name | Format-Table -AutoSize

# Show top file offenders
Write-Output "`n=== TOP FILES WITH ISSUES ===`n"
$issues | Group-Object File | Sort-Object Count -Descending | Select-Object Count, Name -First 20 | Format-Table -AutoSize

# Show breakdown by severity
Write-Output "`n=== BY SEVERITY ===`n"
$issues | Group-Object Severity | Select-Object Count, Name | Format-Table -AutoSize

Write-Output "`nTotal Issues: $($issues.Count)"
