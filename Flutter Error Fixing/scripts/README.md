# Flutter Error Fixing Scripts

Kumpulan script PowerShell untuk menyelesaikan error Flutter secara otomatis dan efisien.

## 📁 File Structure

```
scripts/
├── flutter_fix.ps1           # Main script dengan UI interaktif
├── flutter_patterns.ps1      # Pattern database dan konfigurasi
└── README.md                 # Dokumentasi ini

docs/
└── FLUTTER_ERROR_FIXING_GUIDE.md  # Panduan lengkap dan dokumentasi
```

## 🚀 Quick Start

### 1. Interactive Mode (Recommended)

```powershell
cd scripts
.\flutter_fix.ps1
```

### 2. Quick Fix Mode (Automatic)

```powershell
.\flutter_fix.ps1 -QuickFix
```

### 3. Show Help

```powershell
.\flutter_fix.ps1 -Help
```

## 🎯 Features

### ✅ Automated Fixes

- **withOpacity Deprecation**: `Colors.blue.withOpacity(0.5)` → `Colors.blue.withValues(alpha: 0.5)`
- **Print Statements**: Remove production `print()` statements (keep `debugPrint`)
- **Deprecated Widgets**: `RaisedButton` → `ElevatedButton`, `FlatButton` → `TextButton`
- **String Interpolation**: `${variable}` → `$variable` (for simple cases)
- **Unused Imports**: Remove with `dart fix --apply`

### 📊 Analysis & Reporting

- Flutter analyze integration
- Detailed fix reports
- Progress tracking
- Before/after comparisons

### 🛡️ Safety Features

- Automatic Git backups
- Manual backup fallback
- Dry-run mode
- Pattern validation
- Exclude generated files

## 💻 Usage Examples

### Basic Commands

```powershell
# Run interactive menu
.\flutter_fix.ps1

# Fix only withOpacity issues
Fix-WithOpacityDeprecation

# Remove all print statements
Remove-PrintStatements

# Check current analysis status
Get-FlutterAnalysis

# Test a regex pattern before applying
Test-RegexPattern -Pattern '\.withOpacity\(([^)]+)\)' -TestString 'Colors.red.withOpacity(0.5)' -Replacement '.withValues(alpha: $1)'
```

### Advanced Usage

```powershell
# Load pattern configurations
. .\flutter_patterns.ps1

# Get available patterns
$patterns = Get-FlutterPatterns
$patterns.WithOpacity

# Apply migration patterns for specific Flutter version
$migration = Get-MigrationPatterns -Version 'Flutter3_27'
```

## 🎛️ Interactive Menu Options

```
1. Fix withOpacity deprecation
2. Remove print statements
3. Fix deprecated widgets
4. Fix string interpolation
5. Remove unused imports
6. Run flutter analyze
7. Generate report
8. Quick fix all
9. Exit
```

## 📋 Supported Error Types

| Error Type                          | Auto Fix | Description                     |
| ----------------------------------- | -------- | ------------------------------- |
| `deprecated_member_use`             | ✅       | withOpacity, deprecated widgets |
| `avoid_print`                       | ✅       | Production print statements     |
| `unnecessary_string_interpolations` | ✅       | Simple string interpolation     |
| `unused_import`                     | ✅       | Via dart fix                    |
| `unused_local_variable`             | ❌       | Manual review required          |
| `undefined_identifier`              | ❌       | Missing imports/typos           |

## 🔧 Configuration

Edit variables at the top of `flutter_fix.ps1`:

```powershell
$ProjectPath = "lib"        # Source code directory
$BackupPath = "backups"     # Backup location
$ReportPath = "reports"     # Report output
```

## 📖 Documentation

### Complete Guide

- **[FLUTTER_ERROR_FIXING_GUIDE.md](../docs/FLUTTER_ERROR_FIXING_GUIDE.md)** - Comprehensive documentation with examples

### Pattern Database

- **[flutter_patterns.ps1](./flutter_patterns.ps1)** - All regex patterns and configurations

## 🛠️ Requirements

- **PowerShell 5.1+** (Windows)
- **Flutter SDK** (in PATH)
- **Git** (recommended for backups)
- **Dart SDK** (for dart fix command)

### Setup

```powershell
# Check PowerShell version
$PSVersionTable.PSVersion

# Check Flutter
flutter --version

# Set execution policy if needed
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## 📊 Example Output

```
🚀 Starting Quick Fix Process...
This will fix common Flutter errors automatically.

✅ Git backup created: Quick fix before automated fixes

🔧 Fixing withOpacity deprecation...
  ✅ Fixed 12 occurrences in: analytics_dashboard_screen.dart
  ✅ Fixed 3 occurrences in: facilities_list_screen.dart
📊 Summary: Fixed 15 withOpacity calls in 2 files

🧹 Removing print statements...
  ✅ Removed 5 print statements from: auth_repository.dart
📊 Summary: Removed 5 print statements from 1 files

🔍 Running final analysis...
📊 Final Result: No issues found!

📊 Report generated: reports\fix_report_20250803_143022.md
```

## 🎯 Best Practices

### Before Running Scripts

1. **Commit current changes** to git
2. **Run flutter test** to ensure working state
3. **Review large changes** before applying

### Pattern Testing

```powershell
# Always test patterns first
Test-RegexPattern -Pattern 'your_pattern' -TestString 'test_case' -Replacement 'replacement'
```

### Incremental Fixing

```powershell
# Fix one type at a time
Fix-WithOpacityDeprecation
flutter analyze              # Check results
Remove-PrintStatements
flutter analyze              # Check results
```

## 🔍 Troubleshooting

### Common Issues

#### PowerShell Execution Policy

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

#### File Access Denied

```powershell
# Check if files are open in IDE
# Close VS Code/Android Studio and retry
```

#### Git Not Found

```powershell
# Manual backup will be used instead
# Install Git for automatic version control
```

### Debug Mode

```powershell
# Enable detailed output
$VerbosePreference = "Continue"
.\flutter_fix.ps1
```

## 📈 Performance Tips

### Large Codebases

- Use **Quick Fix** mode for bulk operations
- Process during **low activity** periods
- Monitor **memory usage** for very large projects

### Parallel Processing

```powershell
# For PowerShell 7+ (optional)
Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" |
ForEach-Object -Parallel { /* process */ } -ThrottleLimit 5
```

## 🤝 Contributing

### Adding New Patterns

1. Edit `flutter_patterns.ps1`
2. Add pattern to `$PATTERNS` hashtable
3. Test thoroughly
4. Update documentation

### Example Pattern Addition

```powershell
$PATTERNS.NewPattern = @{
    Pattern = 'regex_pattern_here'
    Replacement = 'replacement_here'
    Description = 'What this pattern fixes'
    Example = 'before → after'
}
```

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Flutter team for excellent tooling
- Community for sharing common error patterns
- PowerShell team for powerful scripting capabilities

---

**💡 Pro Tip**: Run `flutter analyze` before and after using these scripts to see the improvement in your code quality!

For detailed examples and advanced usage, see the complete guide: [FLUTTER_ERROR_FIXING_GUIDE.md](../docs/FLUTTER_ERROR_FIXING_GUIDE.md)
