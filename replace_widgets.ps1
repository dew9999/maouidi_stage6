# FlutterFlow Widget Replacement Script
# This script replaces all FF widgets with standard Flutter widgets

Write-Host "Starting comprehensive FF widget replacement..."

# Function to replace FFButtonWidget patterns
function Replace-FFButtonWidget {
    param([string]$file)
    $content = Get-Content $file -Raw
    
    # Simple FFButtonWidget replacement - convert to FilledButton
    $content = $content -replace 'FFButtonWidget\s*\(', 'FilledButton('
    $content = $content -replace 'options:\s*FFButtonOptions\s*\(', 'style: FilledButton.styleFrom('
    $content = $content -replace 'height:', 'minimumSize: Size(double.infinity,'
    $content = $content -replace 'color:', 'backgroundColor:'
    $content = $content -replace 'textStyle:', 'textStyle:'
    $content = $content -replace 'borderRadius:', 'shape: RoundedRectangleBorder(borderRadius:'
    $content = $content -replace 'disabledColor:', '// disabledColor:'
    $content = $content -replace 'disabledTextColor:', '// disabledTextColor:'
    
    Set-Content $file $content
}

# Replace in all 4 files
Write-Host "Replacing FF widgets in booking_page..."
# Note: booking_page needs manual handling for FlutterFlowCalendar

Write-Host "Replacing FF widgets in patient_dashboard..."
Replace-FFButtonWidget "lib\patient_dashboard\patient_dashboard_widget.dart"

Write-Host "Replacing FF widgets in partner_dashboard..."  
Replace-FFButtonWidget "lib\partner_dashboard_page\partner_dashboard_page_widget.dart"

Write-Host "Replacing FF widgets in settings_page..."
Replace-FFButtonWidget "lib\settings_page\settings_page_widget.dart"

Write-Host "Replacement script complete!"
