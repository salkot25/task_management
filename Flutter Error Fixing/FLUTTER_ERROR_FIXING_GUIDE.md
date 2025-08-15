# Flutter Error Fixing Guide - Command Line Techniques

## 📋 Daftar Isi

- [Pengantar](#pengantar)
- [Prerequisites](#prerequisites)
- [Teknik Dasar](#teknik-dasar)
- [Error Umum dan Solusinya](#error-umum-dan-solusinya)
- [Command PowerShell untuk Flutter](#command-powershell-untuk-flutter)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## 🎯 Pengantar

Dokumentasi ini menyediakan panduan lengkap untuk menyelesaikan error Flutter menggunakan teknik command line, khususnya PowerShell di Windows. Teknik ini sangat efektif untuk:

- **Bulk Operations**: Menangani ratusan file sekaligus
- **Consistency**: Memastikan perubahan konsisten di seluruh codebase
- **Efficiency**: Menghemat waktu dengan automation
- **Accuracy**: Mengurangi human error dengan pattern matching

## 🔧 Prerequisites

### Tools yang Diperlukan:

```powershell
# 1. Flutter SDK
flutter --version

# 2. PowerShell (Windows)
$PSVersionTable.PSVersion

# 3. Git (optional untuk version control)
git --version
```

### Knowledge Requirements:

- Basic PowerShell commands
- Flutter project structure
- Regex pattern understanding
- File system navigation

## 🚀 Teknik Dasar

### 1. Identifikasi Error dengan Flutter Analyze

```powershell
# Jalankan analisis Flutter
flutter analyze

# Simpan output ke file untuk review
flutter analyze > analysis_report.txt

# Count total issues
flutter analyze 2>&1 | Select-String "issue" | Measure-Object
```

### 2. Pattern Searching

```powershell
# Mencari pattern tertentu
Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | Select-String "pattern"

# Mencari dengan regex
Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | Select-String "regex_pattern"

# Count occurrences
Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | Select-String "pattern" | Measure-Object
```

### 3. Bulk File Processing

```powershell
# Template untuk bulk processing
Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $newContent = $content -replace "old_pattern", "new_pattern"
    if ($content -ne $newContent) {
        Set-Content -Path $_.FullName -Value $newContent
        Write-Host "Updated: $($_.Name)"
    }
}
```

## 🐛 Error Umum dan Solusinya

### 1. Deprecated `withOpacity` Calls

#### Problem:

```dart
// Deprecated in Flutter 3.27+
Colors.blue.withOpacity(0.5)
```

#### Solution:

```dart
// New approach
Colors.blue.withValues(alpha: 0.5)
```

#### PowerShell Command:

```powershell
# Bulk replacement untuk withOpacity
Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $newContent = $content -replace '\.withOpacity\(([^)]+)\)', '.withValues(alpha: $1)'
    if ($content -ne $newContent) {
        Set-Content -Path $_.FullName -Value $newContent
        Write-Host "✅ Updated withOpacity in: $($_.Name)"
    }
}
```

#### Regex Explanation:

- `\.withOpacity\(` - Match literal ".withOpacity("
- `([^)]+)` - Capture group: any character except ")"
- `\)` - Match literal ")"
- `$1` - Reference to captured group

### 2. Production Print Statements

#### Problem:

```dart
print('Debug message'); // Tidak boleh di production
debugPrint('Debug'); // Masih boleh
```

#### PowerShell Commands:

**Mencari Print Statements:**

```powershell
# Find all print statements
Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | Select-String "print\("

# Exclude debugPrint
Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | Select-String "print\(" | Where-Object { $_.Line -notmatch "debugPrint" }
```

**Menghapus Print Statements:**

```powershell
# Remove print statements (excluding debugPrint)
Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    # Remove standalone print statements
    $newContent = $content -replace "^\s*print\([^)]*\);\s*$", ""
    # Remove inline print statements
    $newContent = $newContent -replace "\n\s*print\([^)]*\);\s*\n", "`n"
    # Preserve debugPrint statements
    if ($content -ne $newContent -and $newContent -notmatch "debugPrint") {
        Set-Content -Path $_.FullName -Value $newContent
        Write-Host "🧹 Cleaned print statements in: $($_.Name)"
    }
}
```

### 3. Unused Variables

#### Problem:

```dart
final unused = 'This variable is not used';
```

#### Detection:

```powershell
# Find unused variable warnings
flutter analyze | Select-String "unused_local_variable"
```

#### Manual Fix Required:

```powershell
# Unused variables require manual inspection
# Use replace_string_in_file tool for specific fixes
```

### 4. Missing Imports

#### Problem:

```dart
// Missing import for specific classes
```

#### PowerShell Commands:

```powershell
# Find missing import errors
flutter analyze | Select-String "undefined_identifier\|undefined_class"

# Add common imports
Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    if ($content -match "MaterialApp" -and $content -notmatch "import 'package:flutter/material.dart'") {
        $newContent = "import 'package:flutter/material.dart';\n\n$content"
        Set-Content -Path $_.FullName -Value $newContent
        Write-Host "📦 Added material import to: $($_.Name)"
    }
}
```

## 🛠️ Command PowerShell untuk Flutter

### Analysis Commands

```powershell
# 1. Basic Analysis
flutter analyze

# 2. Detailed Analysis with Line Numbers
flutter analyze --no-congratulate

# 3. Analysis for Specific Directory
flutter analyze lib/features/

# 4. Save Analysis to File
flutter analyze > "reports/analysis_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
```

### Code Quality Commands

```powershell
# 1. Format All Dart Files
dart format lib/

# 2. Format with Line Length
dart format --line-length=80 lib/

# 3. Check Formatting
dart format --set-exit-if-changed lib/
```

### Search and Replace Commands

```powershell
# 1. Find TODO Comments
Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | Select-String "TODO\|FIXME\|HACK"

# 2. Find Hardcoded Strings
Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | Select-String "'[^']*'|\"[^\"]*\"" |
Where-Object { $_.Line -notmatch "import\|const\|key:" }

# 3. Replace Deprecated APIs
Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $replacements = @{
        'RaisedButton' = 'ElevatedButton'
        'FlatButton' = 'TextButton'
        'OutlineButton' = 'OutlinedButton'
    }

    $newContent = $content
    foreach ($old in $replacements.Keys) {
        $new = $replacements[$old]
        $newContent = $newContent -replace $old, $new
    }

    if ($content -ne $newContent) {
        Set-Content -Path $_.FullName -Value $newContent
        Write-Host "🔄 Updated deprecated widgets in: $($_.Name)"
    }
}
```

### Verification Commands

```powershell
# 1. Count Issues by Type
flutter analyze 2>&1 | Select-String "warning\|error\|info" | Group-Object { ($_ -split ' - ')[0] }

# 2. List Files with Issues
flutter analyze 2>&1 | Select-String "lib/" | ForEach-Object { ($_ -split ' - ')[1] } | Sort-Object -Unique

# 3. Progress Tracking
$before = (flutter analyze 2>&1 | Select-String "issue found").ToString()
# ... apply fixes ...
$after = (flutter analyze 2>&1 | Select-String "issue found").ToString()
Write-Host "Before: $before"
Write-Host "After: $after"
```

## 📝 Best Practices

### 1. Backup Strategy

```powershell
# Create backup before bulk operations
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
git add -A
git commit -m "Backup before bulk fix - $timestamp"

# Or create manual backup
Copy-Item -Path "lib" -Destination "lib_backup_$timestamp" -Recurse
```

### 2. Incremental Fixing

```powershell
# Fix one type of error at a time
# 1. Fix withOpacity issues
# 2. Run flutter analyze
# 3. Fix print statements
# 4. Run flutter analyze
# 5. Fix unused variables
# 6. Final verification
```

### 3. Testing After Fixes

```powershell
# Comprehensive testing sequence
flutter analyze                    # Static analysis
flutter test                      # Unit tests
flutter build apk --debug         # Build verification
```

### 4. Pattern Validation

```powershell
# Test regex pattern on single file first
$testFile = "lib\features\auth\auth_screen.dart"
$content = Get-Content $testFile -Raw
$newContent = $content -replace '\.withOpacity\(([^)]+)\)', '.withValues(alpha: $1)'
Write-Host "Original matches:"
[regex]::Matches($content, '\.withOpacity\([^)]+\)') | ForEach-Object { $_.Value }
Write-Host "After replacement:"
[regex]::Matches($newContent, '\.withValues\(alpha: [^)]+\)') | ForEach-Object { $_.Value }
```

## 🎛️ Advanced Techniques

### 1. Conditional Processing

```powershell
# Only process files modified in last 7 days
Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" |
Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-7) } |
ForEach-Object {
    # Apply fixes only to recently modified files
}
```

### 2. Progress Reporting

```powershell
# Progress bar for large operations
$files = Get-ChildItem -Path "lib" -Recurse -Filter "*.dart"
$total = $files.Count
$current = 0

foreach ($file in $files) {
    $current++
    $percent = [math]::Round(($current / $total) * 100)
    Write-Progress -Activity "Processing Files" -Status "$current of $total files" -PercentComplete $percent

    # Apply fixes
    Start-Sleep -Milliseconds 100  # Simulate processing time
}
```

### 3. Custom Functions

```powershell
# Create reusable functions
function Fix-WithOpacity {
    param([string]$Path)

    Get-ChildItem -Path $Path -Recurse -Filter "*.dart" | ForEach-Object {
        $content = Get-Content $_.FullName -Raw
        $newContent = $content -replace '\.withOpacity\(([^)]+)\)', '.withValues(alpha: $1)'
        if ($content -ne $newContent) {
            Set-Content -Path $_.FullName -Value $newContent
            Write-Host "✅ Fixed withOpacity in: $($_.Name)"
            return $true
        }
        return $false
    }
}

function Remove-PrintStatements {
    param([string]$Path)

    Get-ChildItem -Path $Path -Recurse -Filter "*.dart" | ForEach-Object {
        $content = Get-Content $_.FullName -Raw
        $newContent = $content -replace "^\s*print\([^)]*\);\s*$", ""
        $newContent = $newContent -replace "\n\s*print\([^)]*\);\s*\n", "`n"
        if ($content -ne $newContent) {
            Set-Content -Path $_.FullName -Value $newContent
            Write-Host "🧹 Cleaned prints in: $($_.Name)"
            return $true
        }
        return $false
    }
}

# Usage
$withOpacityFixed = Fix-WithOpacity "lib"
$printsRemoved = Remove-PrintStatements "lib"
```

## 🔍 Troubleshooting

### Common Issues

#### 1. Regex Not Matching

```powershell
# Debug regex pattern
$pattern = '\.withOpacity\(([^)]+)\)'
$testString = "Colors.blue.withOpacity(0.5)"
if ($testString -match $pattern) {
    Write-Host "Match found: $($matches[0])"
    Write-Host "Captured group: $($matches[1])"
} else {
    Write-Host "No match found"
}
```

#### 2. File Access Issues

```powershell
# Check file permissions
Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | ForEach-Object {
    try {
        $content = Get-Content $_.FullName -Raw
        # Process file
    } catch {
        Write-Warning "Cannot access file: $($_.FullName) - $($_.Exception.Message)"
    }
}
```

#### 3. PowerShell Execution Policy

```powershell
# Check current policy
Get-ExecutionPolicy

# Set policy for current user
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## 📊 Performance Optimization

### 1. Parallel Processing

```powershell
# Process files in parallel (PowerShell 7+)
Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | ForEach-Object -Parallel {
    $content = Get-Content $_.FullName -Raw
    $newContent = $content -replace '\.withOpacity\(([^)]+)\)', '.withValues(alpha: $1)'
    if ($content -ne $newContent) {
        Set-Content -Path $_.FullName -Value $newContent
        Write-Host "Updated: $($_.Name)"
    }
} -ThrottleLimit 5
```

### 2. Memory Efficient Processing

```powershell
# Process large files efficiently
Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | ForEach-Object {
    # Use -ReadCount to process in chunks
    $lines = Get-Content $_.FullName -ReadCount 1000
    # Process in chunks instead of loading entire file
}
```

## 📈 Metrics and Reporting

### Generate Comprehensive Report

```powershell
# Create detailed analysis report
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$reportPath = "reports/flutter_analysis_$((Get-Date).ToString('yyyyMMdd_HHmmss')).md"

$report = @"
# Flutter Code Quality Report
**Generated:** $timestamp

## Summary
$(flutter analyze 2>&1 | Select-String "issue found\|No issues found")

## Issues by Type
$(flutter analyze 2>&1 | Select-String "warning\|error\|info" | Group-Object { ($_ -split ' - ')[0] } | ForEach-Object { "- $($_.Name): $($_.Count)" })

## Files with Issues
$(flutter analyze 2>&1 | Select-String "lib/" | ForEach-Object { "- $(($_ -split ' - ')[1])" } | Sort-Object -Unique)

## Recommendations
- Run `dart format lib/` for formatting
- Consider adding linter rules in `analysis_options.yaml`
- Regular code reviews to prevent common issues

"@

New-Item -Path (Split-Path $reportPath) -ItemType Directory -Force
Set-Content -Path $reportPath -Value $report
Write-Host "📊 Report generated: $reportPath"
```

## 🎯 Kesimpulan

Teknik command line untuk fixing Flutter errors memberikan:

### **Keunggulan:**

- ⚡ **Speed**: Bulk processing ratusan file
- 🎯 **Accuracy**: Pattern matching yang presisi
- 🔄 **Consistency**: Penerapan yang seragam
- 📊 **Tracking**: Progress monitoring yang detail
- 🔁 **Reproducible**: Dapat diulang dengan hasil sama

### **Use Cases Ideal:**

- Large codebase maintenance
- Migration ke Flutter versi baru
- Code quality improvements
- Standardization across teams
- Legacy code cleanup

### **Tips Sukses:**

1. **Selalu backup** sebelum bulk operations
2. **Test patterns** pada file kecil dulu
3. **Verify results** dengan flutter analyze
4. **Document changes** untuk team knowledge
5. **Automate frequent tasks** dengan scripts

---

**📚 Resources:**

- [Flutter Analyzer Rules](https://dart.dev/tools/linter-rules)
- [PowerShell Documentation](https://docs.microsoft.com/en-us/powershell/)
- [Regex Testing Tool](https://regex101.com/)

**🤝 Contributing:**
Feel free to add more patterns and techniques to this guide!
