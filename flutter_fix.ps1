# Flutter Error Fixing Scripts
# Kumpulan script PowerShell untuk menyelesaikan error Flutter umum

# =============================================================================
# SCRIPT PARAMETERS
# =============================================================================

param(
    [switch]$QuickFix,
    [switch]$Help,
    [switch]$Interactive
)

# =============================================================================
# CONFIGURATION
# =============================================================================

$ErrorActionPreference = "Stop"
$ProjectPath = "lib"
$BackupPath = "backups"
$ReportPath = "reports"

# Ensure directories exist
if (!(Test-Path $BackupPath)) { New-Item -Path $BackupPath -ItemType Directory -Force }
if (!(Test-Path $ReportPath)) { New-Item -Path $ReportPath -ItemType Directory -Force }

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Create-Backup {
    param([string]$Description = "General backup")
    
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    
    try {
        # Git backup (preferred)
        git add -A 2>$null
        git commit -m "Backup: $Description - $timestamp" 2>$null
        Write-ColorOutput "✅ Git backup created: $Description" "Green"
    } catch {
        # Manual backup fallback
        $backupFolder = "$BackupPath\backup_$timestamp"
        Copy-Item -Path $ProjectPath -Destination $backupFolder -Recurse -Force
        Write-ColorOutput "✅ Manual backup created: $backupFolder" "Yellow"
    }
}

function Get-DartFiles {
    return Get-ChildItem -Path $ProjectPath -Recurse -Filter "*.dart"
}

function Test-RegexPattern {
    param(
        [string]$Pattern,
        [string]$TestString,
        [string]$Replacement = ""
    )
    
    Write-ColorOutput "🧪 Testing regex pattern..." "Cyan"
    Write-ColorOutput "Pattern: $Pattern" "Gray"
    Write-ColorOutput "Test string: $TestString" "Gray"
    
    if ($TestString -match $Pattern) {
        Write-ColorOutput "✅ Match found: $($matches[0])" "Green"
        if ($Replacement) {
            $result = $TestString -replace $Pattern, $Replacement
            Write-ColorOutput "🔄 After replacement: $result" "Blue"
        }
    } else {
        Write-ColorOutput "❌ No match found" "Red"
    }
}

# =============================================================================
# MAIN FIXING FUNCTIONS
# =============================================================================

function Fix-WithOpacityDeprecation {
    Write-ColorOutput "🔧 Fixing withOpacity deprecation..." "Yellow"
    
    $pattern = '\.withOpacity\(([^)]+)\)'
    $replacement = '.withValues(alpha: $1)'
    $filesFixed = 0
    $totalMatches = 0
    
    Get-DartFiles | ForEach-Object {
        $content = Get-Content $_.FullName -Raw
        $matches = [regex]::Matches($content, $pattern)
        
        if ($matches.Count -gt 0) {
            $totalMatches += $matches.Count
            $newContent = $content -replace $pattern, $replacement
            Set-Content -Path $_.FullName -Value $newContent
            $filesFixed++
            Write-ColorOutput "  ✅ Fixed $($matches.Count) occurrences in: $($_.Name)" "Green"
        }
    }
    
    Write-ColorOutput "📊 Summary: Fixed $totalMatches withOpacity calls in $filesFixed files" "Cyan"
    return @{ FilesFixed = $filesFixed; TotalMatches = $totalMatches }
}

function Remove-PrintStatements {
    Write-ColorOutput "🧹 Removing print statements..." "Yellow"
    
    $filesFixed = 0
    $totalRemoved = 0
    
    Get-DartFiles | ForEach-Object {
        $content = Get-Content $_.FullName -Raw
        $originalContent = $content
        
        # Count print statements (excluding debugPrint)
        $printMatches = [regex]::Matches($content, '(?<!debug)print\s*\([^)]*\);?')
        
        if ($printMatches.Count -gt 0) {
            # Remove standalone print statements
            $content = $content -replace '^\s*(?<!debug)print\s*\([^)]*\);\s*$', ''
            # Remove inline print statements
            $content = $content -replace '\n\s*(?<!debug)print\s*\([^)]*\);\s*\n', "`n"
            # Clean up extra newlines
            $content = $content -replace '\n\n\n+', "`n`n"
            
            if ($originalContent -ne $content) {
                Set-Content -Path $_.FullName -Value $content
                $filesFixed++
                $totalRemoved += $printMatches.Count
                Write-ColorOutput "  ✅ Removed $($printMatches.Count) print statements from: $($_.Name)" "Green"
            }
        }
    }
    
    Write-ColorOutput "📊 Summary: Removed $totalRemoved print statements from $filesFixed files" "Cyan"
    return @{ FilesFixed = $filesFixed; TotalRemoved = $totalRemoved }
}

function Fix-DeprecatedWidgets {
    Write-ColorOutput "🔄 Fixing deprecated widgets..." "Yellow"
    
    $replacements = @{
        'RaisedButton' = 'ElevatedButton'
        'FlatButton' = 'TextButton'
        'OutlineButton' = 'OutlinedButton'
        'WhitelistingTextInputFormatter' = 'AllowlistTextInputFormatter'
        'BlacklistingTextInputFormatter' = 'DenylistTextInputFormatter'
    }
    
    $filesFixed = 0
    $totalReplacements = 0
    
    Get-DartFiles | ForEach-Object {
        $content = Get-Content $_.FullName -Raw
        $originalContent = $content
        $fileReplacements = 0
        
        foreach ($old in $replacements.Keys) {
            $new = $replacements[$old]
            $matches = [regex]::Matches($content, $old)
            if ($matches.Count -gt 0) {
                $content = $content -replace $old, $new
                $fileReplacements += $matches.Count
                $totalReplacements += $matches.Count
            }
        }
        
        if ($originalContent -ne $content) {
            Set-Content -Path $_.FullName -Value $content
            $filesFixed++
            Write-ColorOutput "  ✅ Made $fileReplacements replacements in: $($_.Name)" "Green"
        }
    }
    
    Write-ColorOutput "📊 Summary: Made $totalReplacements widget replacements in $filesFixed files" "Cyan"
    return @{ FilesFixed = $filesFixed; TotalReplacements = $totalReplacements }
}

function Fix-StringInterpolation {
    Write-ColorOutput "🔤 Fixing unnecessary string interpolation..." "Yellow"
    
    $pattern = '\$\{([^}]+)\}'
    $filesFixed = 0
    $totalFixed = 0
    
    Get-DartFiles | ForEach-Object {
        $content = Get-Content $_.FullName -Raw
        $matches = [regex]::Matches($content, $pattern)
        
        if ($matches.Count -gt 0) {
            $newContent = $content
            foreach ($match in $matches) {
                $innerExpression = $match.Groups[1].Value
                # Only replace if it's a simple variable or property access
                if ($innerExpression -match '^[a-zA-Z_][a-zA-Z0-9_]*(\.[a-zA-Z_][a-zA-Z0-9_]*)*$') {
                    $newContent = $newContent -replace [regex]::Escape($match.Value), "`$$innerExpression"
                    $totalFixed++
                }
            }
            
            if ($content -ne $newContent) {
                Set-Content -Path $_.FullName -Value $newContent
                $filesFixed++
                Write-ColorOutput "  ✅ Fixed string interpolation in: $($_.Name)" "Green"
            }
        }
    }
    
    Write-ColorOutput "📊 Summary: Fixed $totalFixed string interpolations in $filesFixed files" "Cyan"
    return @{ FilesFixed = $filesFixed; TotalFixed = $totalFixed }
}

function Remove-UnusedImports {
    Write-ColorOutput "📦 Removing unused imports..." "Yellow"
    
    # This is a basic implementation - for full functionality use `dart fix`
    Write-ColorOutput "💡 For comprehensive unused import removal, run: dart fix --apply" "Blue"
    
    # Run dart fix for unused imports
    try {
        $output = dart fix --dry-run 2>&1
        Write-ColorOutput "🔍 Dart fix dry run results:" "Cyan"
        Write-ColorOutput $output "Gray"
        
        $userInput = Read-Host "Apply these fixes? (y/N)"
        if ($userInput -eq "y" -or $userInput -eq "Y") {
            dart fix --apply
            Write-ColorOutput "✅ Applied dart fix suggestions" "Green"
        }
    } catch {
        Write-ColorOutput "⚠️ Could not run dart fix. Make sure Dart SDK is installed." "Yellow"
    }
}

# =============================================================================
# ANALYSIS AND REPORTING
# =============================================================================

function Get-FlutterAnalysis {
    Write-ColorOutput "🔍 Running Flutter analysis..." "Yellow"
    
    try {
        $analysisOutput = flutter analyze 2>&1
        return $analysisOutput
    } catch {
        Write-ColorOutput "❌ Error running flutter analyze" "Red"
        return @()
    }
}

function Generate-Report {
    param([hashtable]$Results)
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $reportFile = "$ReportPath\fix_report_$((Get-Date).ToString('yyyyMMdd_HHmmss')).md"
    
    $analysis = Get-FlutterAnalysis
    $issuesLine = $analysis | Where-Object { $_ -match "issue.*found" -or $_ -match "No issues found" }
    
    $report = @"
# Flutter Error Fix Report

**Generated:** $timestamp

## Summary
$issuesLine

## Fixes Applied

### WithOpacity Deprecation
- **Files Fixed:** $($Results.WithOpacity.FilesFixed)
- **Total Matches:** $($Results.WithOpacity.TotalMatches)

### Print Statements Removal
- **Files Fixed:** $($Results.PrintStatements.FilesFixed)  
- **Statements Removed:** $($Results.PrintStatements.TotalRemoved)

### Deprecated Widgets
- **Files Fixed:** $($Results.DeprecatedWidgets.FilesFixed)
- **Total Replacements:** $($Results.DeprecatedWidgets.TotalReplacements)

### String Interpolation
- **Files Fixed:** $($Results.StringInterpolation.FilesFixed)
- **Total Fixed:** $($Results.StringInterpolation.TotalFixed)

## Flutter Analysis Results
``````
$($analysis -join "`n")
``````

## Next Steps
- Run ``flutter analyze`` to verify all issues are resolved
- Run ``flutter test`` to ensure no functionality is broken
- Review changes and commit to version control

---
Generated by Flutter Error Fixing Scripts
"@

    Set-Content -Path $reportFile -Value $report
    Write-ColorOutput "📊 Report generated: $reportFile" "Green"
}

# =============================================================================
# MAIN EXECUTION FUNCTIONS
# =============================================================================

function Start-QuickFix {
    Write-ColorOutput "🚀 Starting Quick Fix Process..." "Cyan"
    Write-ColorOutput "This will fix common Flutter errors automatically." "Gray"
    
    # Create backup
    Create-Backup "Quick fix before automated fixes"
    
    # Initialize results
    $results = @{
        WithOpacity = @{ FilesFixed = 0; TotalMatches = 0 }
        PrintStatements = @{ FilesFixed = 0; TotalRemoved = 0 }
        DeprecatedWidgets = @{ FilesFixed = 0; TotalReplacements = 0 }
        StringInterpolation = @{ FilesFixed = 0; TotalFixed = 0 }
    }
    
    # Run fixes
    $results.WithOpacity = Fix-WithOpacityDeprecation
    $results.PrintStatements = Remove-PrintStatements
    $results.DeprecatedWidgets = Fix-DeprecatedWidgets
    $results.StringInterpolation = Fix-StringInterpolation
    
    # Generate report
    Generate-Report $results
    
    # Final analysis
    Write-ColorOutput "🔍 Running final analysis..." "Yellow"
    $finalAnalysis = Get-FlutterAnalysis
    $finalIssues = $finalAnalysis | Where-Object { $_ -match "issue.*found" -or $_ -match "No issues found" }
    Write-ColorOutput "📊 Final Result: $finalIssues" "Green"
}

function Start-InteractiveFix {
    Write-ColorOutput "🎛️ Interactive Fix Mode" "Cyan"
    
    do {
        Write-Host ""
        Write-ColorOutput "Choose an option:" "Yellow"
        Write-ColorOutput "1. Fix withOpacity deprecation" "White"
        Write-ColorOutput "2. Remove print statements" "White"
        Write-ColorOutput "3. Fix deprecated widgets" "White"
        Write-ColorOutput "4. Fix string interpolation" "White"
        Write-ColorOutput "5. Remove unused imports" "White"
        Write-ColorOutput "6. Run flutter analyze" "White"
        Write-ColorOutput "7. Generate report" "White"
        Write-ColorOutput "8. Quick fix all" "White"
        Write-ColorOutput "9. Exit" "White"
        
        $choice = Read-Host "Enter your choice (1-9)"
        
        switch ($choice) {
            "1" { 
                Create-Backup "withOpacity fix"
                Fix-WithOpacityDeprecation 
            }
            "2" { 
                Create-Backup "print statements removal"
                Remove-PrintStatements 
            }
            "3" { 
                Create-Backup "deprecated widgets fix"
                Fix-DeprecatedWidgets 
            }
            "4" { 
                Create-Backup "string interpolation fix"
                Fix-StringInterpolation 
            }
            "5" { Remove-UnusedImports }
            "6" { 
                $analysis = Get-FlutterAnalysis
                Write-ColorOutput $analysis "Gray"
            }
            "7" { 
                $emptyResults = @{
                    WithOpacity = @{ FilesFixed = 0; TotalMatches = 0 }
                    PrintStatements = @{ FilesFixed = 0; TotalRemoved = 0 }
                    DeprecatedWidgets = @{ FilesFixed = 0; TotalReplacements = 0 }
                    StringInterpolation = @{ FilesFixed = 0; TotalFixed = 0 }
                }
                Generate-Report $emptyResults
            }
            "8" { Start-QuickFix }
            "9" { 
                Write-ColorOutput "👋 Goodbye!" "Green"
                break 
            }
            default { 
                Write-ColorOutput "❌ Invalid choice. Please try again." "Red" 
            }
        }
    } while ($choice -ne "9")
}

# =============================================================================
# USAGE EXAMPLES AND HELP
# =============================================================================

function Show-Help {
    $helpText = @"

Flutter Error Fixing Scripts - Help
===================================

QUICK START:
  .\flutter_fix.ps1                 # Interactive mode
  .\flutter_fix.ps1 -QuickFix       # Automatic fix mode
  .\flutter_fix.ps1 -Help           # Show this help

INDIVIDUAL FUNCTIONS:
  Fix-WithOpacityDeprecation         # Fix .withOpacity() to .withValues()
  Remove-PrintStatements             # Remove production print statements
  Fix-DeprecatedWidgets             # Update deprecated widget names  
  Fix-StringInterpolation           # Fix \${variable} to \$variable
  Remove-UnusedImports              # Remove unused import statements

TESTING:
  Test-RegexPattern -Pattern "regex" -TestString "test" -Replacement "new"

UTILITIES:
  Create-Backup "description"       # Create backup before changes
  Get-FlutterAnalysis              # Run flutter analyze
  Generate-Report \$results         # Generate fix report

EXAMPLES:
  # Test a regex pattern before applying
  Test-RegexPattern -Pattern '\.withOpacity\(([^)]+)\)' -TestString 'Colors.red.withOpacity(0.5)' -Replacement '.withValues(alpha: \$1)'
  
  # Fix specific issue
  Create-Backup "Before withOpacity fix"
  Fix-WithOpacityDeprecation
  
  # Check results  
  Get-FlutterAnalysis

CONFIGURATION:
  Edit these variables at the top of the script:
  - \$ProjectPath = "lib"           # Source code directory
  - \$BackupPath = "backups"        # Backup directory  
  - \$ReportPath = "reports"        # Report output directory

"@
    Write-ColorOutput $helpText "Cyan"
}

# Show banner
Write-ColorOutput "╔══════════════════════════════════════════════════════════╗" "Cyan"
Write-ColorOutput "║              Flutter Error Fixing Scripts               ║" "Cyan" 
Write-ColorOutput "║            Automated Flutter Code Quality               ║" "Cyan"
Write-ColorOutput "╚══════════════════════════════════════════════════════════╝" "Cyan"
Write-Host ""

# Handle parameters
if ($Help) {
    Show-Help
} elseif ($QuickFix) {
    Start-QuickFix
} else {
    Start-InteractiveFix
}
