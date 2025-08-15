# Flutter Error Patterns Configuration
# File ini berisi pattern regex dan command yang sering digunakan untuk fixing Flutter errors

# =============================================================================
# COMMON REGEX PATTERNS
# =============================================================================

# Deprecated API Patterns
$PATTERNS = @{
    # Flutter 3.27+ withOpacity deprecation
    WithOpacity = @{
        Pattern = '\.withOpacity\(([^)]+)\)'
        Replacement = '.withValues(alpha: $1)'
        Description = 'Replace deprecated withOpacity with withValues'
        Example = 'Colors.blue.withOpacity(0.5) → Colors.blue.withValues(alpha: 0.5)'
    }
    
    # Print statements (excluding debugPrint)
    PrintStatements = @{
        Pattern = '(?<!debug)print\s*\([^)]*\);?'
        Replacement = ''
        Description = 'Remove print statements (keep debugPrint)'
        Example = 'print("debug"); → (removed)'
    }
    
    # Deprecated widget names
    RaisedButton = @{
        Pattern = '\bRaisedButton\b'
        Replacement = 'ElevatedButton'
        Description = 'Replace deprecated RaisedButton'
        Example = 'RaisedButton → ElevatedButton'
    }
    
    FlatButton = @{
        Pattern = '\bFlatButton\b'  
        Replacement = 'TextButton'
        Description = 'Replace deprecated FlatButton'
        Example = 'FlatButton → TextButton'
    }
    
    OutlineButton = @{
        Pattern = '\bOutlineButton\b'
        Replacement = 'OutlinedButton'
        Description = 'Replace deprecated OutlineButton'
        Example = 'OutlineButton → OutlinedButton'
    }
    
    # Unnecessary string interpolation
    StringInterpolation = @{
        Pattern = '\$\{([a-zA-Z_][a-zA-Z0-9_]*(?:\.[a-zA-Z_][a-zA-Z0-9_]*)*)\}'
        Replacement = '$$1'
        Description = 'Simplify string interpolation for simple expressions'
        Example = '${variable} → $variable'
    }
    
    # Deprecated text input formatters
    WhitelistingFormatter = @{
        Pattern = '\bWhitelistingTextInputFormatter\b'
        Replacement = 'AllowlistTextInputFormatter'
        Description = 'Replace deprecated WhitelistingTextInputFormatter'
        Example = 'WhitelistingTextInputFormatter → AllowlistTextInputFormatter'
    }
    
    BlacklistingFormatter = @{
        Pattern = '\bBlacklistingTextInputFormatter\b'
        Replacement = 'DenylistTextInputFormatter'
        Description = 'Replace deprecated BlacklistingTextInputFormatter'  
        Example = 'BlacklistingTextInputFormatter → DenylistTextInputFormatter'
    }
    
    # Material Design 2 to 3 migrations
    accentColor = @{
        Pattern = '\baccentColor\s*:'
        Replacement = 'colorScheme: ColorScheme.fromSeed(seedColor:'
        Description = 'Replace deprecated accentColor'
        Example = 'accentColor: Colors.blue → colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)'
    }
    
    primarySwatch = @{
        Pattern = '\bprimarySwatch\s*:'
        Replacement = 'colorScheme: ColorScheme.fromSeed(seedColor:'
        Description = 'Replace deprecated primarySwatch'
        Example = 'primarySwatch: Colors.blue → colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)'
    }
    
    # Deprecated TextTheme methods
    headline1 = @{
        Pattern = '\bheadline1\b'
        Replacement = 'displayLarge'
        Description = 'Replace deprecated headline1'
        Example = 'headline1 → displayLarge'
    }
    
    headline2 = @{
        Pattern = '\bheadline2\b'
        Replacement = 'displayMedium'
        Description = 'Replace deprecated headline2'
        Example = 'headline2 → displayMedium'
    }
    
    headline3 = @{
        Pattern = '\bheadline3\b'
        Replacement = 'displaySmall'
        Description = 'Replace deprecated headline3'
        Example = 'headline3 → displaySmall'
    }
    
    headline4 = @{
        Pattern = '\bheadline4\b'
        Replacement = 'headlineMedium'
        Description = 'Replace deprecated headline4'
        Example = 'headline4 → headlineMedium'
    }
    
    headline5 = @{
        Pattern = '\bheadline5\b'
        Replacement = 'headlineSmall'
        Description = 'Replace deprecated headline5'
        Example = 'headline5 → headlineSmall'
    }
    
    headline6 = @{
        Pattern = '\bheadline6\b'
        Replacement = 'titleLarge'
        Description = 'Replace deprecated headline6'
        Example = 'headline6 → titleLarge'
    }
    
    bodyText1 = @{
        Pattern = '\bbodyText1\b'
        Replacement = 'bodyLarge'
        Description = 'Replace deprecated bodyText1'
        Example = 'bodyText1 → bodyLarge'
    }
    
    bodyText2 = @{
        Pattern = '\bbodyText2\b'
        Replacement = 'bodyMedium'
        Description = 'Replace deprecated bodyText2'  
        Example = 'bodyText2 → bodyMedium'
    }
    
    # FloatingActionButton theme changes
    FloatingActionButtonTheme = @{
        Pattern = 'floatingActionButtonTheme:\s*FloatingActionButtonThemeData\('
        Replacement = 'floatingActionButtonTheme: const FloatingActionButtonThemeData('
        Description = 'Add const to FloatingActionButtonThemeData'
        Example = 'FloatingActionButtonThemeData( → const FloatingActionButtonThemeData('
    }
}

# =============================================================================
# COMMON FLUTTER ANALYZE ERRORS AND FIXES
# =============================================================================

$COMMON_ERRORS = @{
    'unused_local_variable' = @{
        Description = 'Local variable is declared but not used'
        AutoFix = $false
        ManualSteps = @(
            '1. Identify the unused variable in the reported line',
            '2. Either use the variable or remove the declaration',
            '3. If needed for future use, prefix with underscore: _unusedVar'
        )
        Command = 'flutter analyze | Select-String "unused_local_variable"'
    }
    
    'undefined_identifier' = @{
        Description = 'Identifier is not defined in the current scope'
        AutoFix = $false
        ManualSteps = @(
            '1. Check if import statement is missing',
            '2. Verify spelling of the identifier',
            '3. Check if the identifier is in the correct scope'
        )
        Command = 'flutter analyze | Select-String "undefined_identifier"'
    }
    
    'dead_code' = @{
        Description = 'Code that will never be executed'
        AutoFix = $true
        Command = 'dart fix --apply'
    }
    
    'unnecessary_string_interpolations' = @{
        Description = 'String interpolation is not necessary'
        AutoFix = $true
        Pattern = '\$\{([a-zA-Z_][a-zA-Z0-9_]*)\}'
        Replacement = '$$1'
    }
    
    'prefer_const_constructors' = @{
        Description = 'Constructor should be const when possible'
        AutoFix = $true
        Command = 'dart fix --apply'
    }
    
    'prefer_final_locals' = @{
        Description = 'Local variable should be final'
        AutoFix = $true
        Command = 'dart fix --apply'
    }
}

# =============================================================================
# MIGRATION PATTERNS (Flutter Version Updates)
# =============================================================================

$MIGRATION_PATTERNS = @{
    # Flutter 3.0 to 3.10
    'Flutter3_10' = @{
        'deprecated_member_use' = @(
            @{ Pattern = '\.withOpacity\('; Replacement = '.withValues(alpha: '; File = '*.dart' },
            @{ Pattern = 'primarySwatch'; Replacement = 'colorScheme'; File = '*.dart' }
        )
    }
    
    # Flutter 3.10 to 3.16  
    'Flutter3_16' = @{
        'material_design_3' = @(
            @{ Pattern = 'useMaterial3:\s*false'; Replacement = 'useMaterial3: true'; File = '*.dart' },
            @{ Pattern = 'headline1'; Replacement = 'displayLarge'; File = '*.dart' }
        )
    }
    
    # Flutter 3.16 to 3.24
    'Flutter3_24' = @{
        'context_api_changes' = @(
            @{ Pattern = 'MediaQuery\.of\(context\)\.size'; Replacement = 'MediaQuery.sizeOf(context)'; File = '*.dart' },
            @{ Pattern = 'Theme\.of\(context\)\.textTheme'; Replacement = 'Theme.of(context).textTheme'; File = '*.dart' }
        )
    }
    
    # Flutter 3.24 to 3.27+
    'Flutter3_27' = @{
        'color_api_changes' = @(
            @{ Pattern = '\.withOpacity\(([^)]+)\)'; Replacement = '.withValues(alpha: $1)'; File = '*.dart' }
        )
    }
}

# =============================================================================
# COMMAND TEMPLATES
# =============================================================================

$COMMAND_TEMPLATES = @{
    # Search commands
    FindPattern = 'Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | Select-String "{pattern}"'
    CountPattern = 'Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | Select-String "{pattern}" | Measure-Object'
    
    # Replace commands  
    BulkReplace = @'
Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $newContent = $content -replace '{pattern}', '{replacement}'
    if ($content -ne $newContent) {
        Set-Content -Path $_.FullName -Value $newContent
        Write-Host "Updated: $($_.Name)"
    }
}
'@
    
    # Analysis commands
    FlutterAnalyze = 'flutter analyze'
    FlutterAnalyzeCount = 'flutter analyze 2>&1 | Select-String "issue found|No issues found"'
    FlutterAnalyzeByType = 'flutter analyze 2>&1 | Select-String "warning|error|info" | Group-Object { ($_ -split " - ")[0] }'
    
    # Testing commands
    TestRegex = @'
$pattern = "{pattern}"
$testString = "{testString}"
if ($testString -match $pattern) {
    Write-Host "Match found: $($matches[0])"
    Write-Host "Groups: $($matches[1..$matches.Count])"
} else {
    Write-Host "No match found"
}
'@
}

# =============================================================================
# VALIDATION RULES
# =============================================================================

$VALIDATION_RULES = @{
    # Files that should not be modified
    ExcludeFiles = @(
        '*.g.dart',           # Generated files
        '*.freezed.dart',     # Freezed generated files  
        '*.gr.dart',          # Auto route generated files
        '*.mocks.dart',       # Mock files
        'test/**/*.dart'      # Test files (optional)
    )
    
    # Patterns that should be carefully reviewed
    CriticalPatterns = @(
        'import\s+[''"]package:',   # Import statements
        'class\s+\w+',              # Class declarations
        'function\s+\w+',           # Function declarations
        '@override',                # Override annotations
        'extends\s+\w+',            # Class inheritance
        'implements\s+\w+'          # Interface implementation
    )
    
    # Required imports for certain patterns
    RequiredImports = @{
        'MaterialApp' = "import 'package:flutter/material.dart';"
        'Scaffold' = "import 'package:flutter/material.dart';"
        'StatefulWidget' = "import 'package:flutter/material.dart';"
        'StatelessWidget' = "import 'package:flutter/material.dart';"
        'Provider' = "import 'package:provider/provider.dart';"
        'BlocBuilder' = "import 'package:flutter_bloc/flutter_bloc.dart';"
    }
}

# =============================================================================
# USAGE EXAMPLES
# =============================================================================

$USAGE_EXAMPLES = @'
# BASIC USAGE EXAMPLES

# 1. Test a regex pattern
$pattern = $PATTERNS.WithOpacity.Pattern
$testString = "Colors.blue.withOpacity(0.5)"
Test-RegexPattern -Pattern $pattern -TestString $testString -Replacement $PATTERNS.WithOpacity.Replacement

# 2. Apply specific fix
$files = Get-ChildItem -Path "lib" -Recurse -Filter "*.dart"
foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    $newContent = $content -replace $PATTERNS.WithOpacity.Pattern, $PATTERNS.WithOpacity.Replacement
    if ($content -ne $newContent) {
        Set-Content -Path $file.FullName -Value $newContent
        Write-Host "Fixed: $($file.Name)"
    }
}

# 3. Count issues before fixing
$beforeCount = (flutter analyze 2>&1 | Select-String "issue found").ToString()
Write-Host "Before: $beforeCount"

# Apply fixes here...

$afterCount = (flutter analyze 2>&1 | Select-String "issue found").ToString()  
Write-Host "After: $afterCount"

# 4. Search for specific error type
flutter analyze | Select-String "unused_local_variable"

# 5. Apply multiple patterns
foreach ($patternName in $PATTERNS.Keys) {
    $pattern = $PATTERNS[$patternName]
    Write-Host "Applying: $($pattern.Description)"
    # Apply pattern...
}

# 6. Generate migration script
$migrationPatterns = $MIGRATION_PATTERNS['Flutter3_27']['color_api_changes']
foreach ($migration in $migrationPatterns) {
    Write-Host "Pattern: $($migration.Pattern)"
    Write-Host "Replacement: $($migration.Replacement)"
    Write-Host "Files: $($migration.File)"
}
'@

# =============================================================================
# EXPORT FUNCTIONS
# =============================================================================

function Get-FlutterPatterns {
    return $PATTERNS
}

function Get-CommonErrors {
    return $COMMON_ERRORS  
}

function Get-MigrationPatterns {
    param([string]$Version)
    if ($Version) {
        return $MIGRATION_PATTERNS[$Version]
    }
    return $MIGRATION_PATTERNS
}

function Get-CommandTemplates {
    return $COMMAND_TEMPLATES
}

function Show-UsageExamples {
    Write-Host $USAGE_EXAMPLES
}

# Export for use in other scripts
Export-ModuleMember -Function Get-FlutterPatterns, Get-CommonErrors, Get-MigrationPatterns, Get-CommandTemplates, Show-UsageExamples
Export-ModuleMember -Variable PATTERNS, COMMON_ERRORS, MIGRATION_PATTERNS, COMMAND_TEMPLATES, VALIDATION_RULES
