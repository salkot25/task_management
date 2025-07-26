import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/core/theme/theme_provider.dart';
import 'package:myapp/utils/design_system/design_system.dart';

/// Widget untuk memilih theme mode
class ThemeSelector extends StatelessWidget {
  final bool showLabel;
  final bool isCompact;

  const ThemeSelector({
    super.key,
    this.showLabel = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        if (isCompact) {
          return _buildCompactSelector(context, themeProvider);
        }
        return _buildFullSelector(context, themeProvider);
      },
    );
  }

  Widget _buildCompactSelector(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    return PopupMenuButton<ThemeMode>(
      icon: Icon(
        themeProvider.getThemeIcon(),
        color: Theme.of(context).iconTheme.color,
      ),
      tooltip: 'Change Theme',
      onSelected: (ThemeMode mode) {
        themeProvider.setThemeMode(mode);
        _showThemeChangedSnackBar(context, mode);
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem(
          value: ThemeMode.light,
          child: Row(
            children: [
              Icon(
                Icons.light_mode,
                color: themeProvider.themeMode == ThemeMode.light
                    ? AppColors.primaryColor
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                'Light',
                style: TextStyle(
                  fontWeight: themeProvider.themeMode == ThemeMode.light
                      ? FontWeight.w600
                      : FontWeight.normal,
                  color: themeProvider.themeMode == ThemeMode.light
                      ? AppColors.primaryColor
                      : null,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: ThemeMode.dark,
          child: Row(
            children: [
              Icon(
                Icons.dark_mode,
                color: themeProvider.themeMode == ThemeMode.dark
                    ? AppColors.primaryColor
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                'Dark',
                style: TextStyle(
                  fontWeight: themeProvider.themeMode == ThemeMode.dark
                      ? FontWeight.w600
                      : FontWeight.normal,
                  color: themeProvider.themeMode == ThemeMode.dark
                      ? AppColors.primaryColor
                      : null,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: ThemeMode.system,
          child: Row(
            children: [
              Icon(
                Icons.brightness_auto,
                color: themeProvider.themeMode == ThemeMode.system
                    ? AppColors.primaryColor
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                'System',
                style: TextStyle(
                  fontWeight: themeProvider.themeMode == ThemeMode.system
                      ? FontWeight.w600
                      : FontWeight.normal,
                  color: themeProvider.themeMode == ThemeMode.system
                      ? AppColors.primaryColor
                      : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFullSelector(BuildContext context, ThemeProvider themeProvider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showLabel) ...[
              Row(
                children: [
                  Icon(
                    Icons.palette_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Theme Mode',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Theme Options
            _buildThemeOption(
              context,
              themeProvider,
              ThemeMode.light,
              Icons.light_mode,
              'Light',
              'Light theme with bright colors',
            ),

            const SizedBox(height: 8),

            _buildThemeOption(
              context,
              themeProvider,
              ThemeMode.dark,
              Icons.dark_mode,
              'Dark',
              'Dark theme for low-light environments',
            ),

            const SizedBox(height: 8),

            _buildThemeOption(
              context,
              themeProvider,
              ThemeMode.system,
              Icons.brightness_auto,
              'System',
              'Follow system theme settings',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    ThemeProvider themeProvider,
    ThemeMode mode,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final isSelected = themeProvider.themeMode == mode;

    return InkWell(
      onTap: () {
        themeProvider.setThemeMode(mode);
        _showThemeChangedSnackBar(context, mode);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primaryColor
                  : Theme.of(context).iconTheme.color,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isSelected ? AppColors.primaryColor : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.primaryColor, size: 20),
          ],
        ),
      ),
    );
  }

  void _showThemeChangedSnackBar(BuildContext context, ThemeMode mode) {
    String message;
    switch (mode) {
      case ThemeMode.light:
        message = 'Switched to Light theme';
        break;
      case ThemeMode.dark:
        message = 'Switched to Dark theme';
        break;
      case ThemeMode.system:
        message = 'Using System theme';
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Widget toggle sederhana untuk dark mode
class DarkModeToggle extends StatelessWidget {
  final bool showLabel;

  const DarkModeToggle({super.key, this.showLabel = true});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode(context);

        return InkWell(
          onTap: () {
            themeProvider.toggleTheme();
            _showToggleSnackBar(context, !isDarkMode);
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: Theme.of(context).iconTheme.color,
                ),
                if (showLabel) ...[
                  const SizedBox(width: 8),
                  Text(
                    isDarkMode ? 'Dark Mode' : 'Light Mode',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(width: 8),
                Switch(
                  value: isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                    _showToggleSnackBar(context, value);
                  },
                  activeColor: AppColors.primaryColor,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showToggleSnackBar(BuildContext context, bool isDarkMode) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(isDarkMode ? 'Dark mode enabled' : 'Light mode enabled'),
          ],
        ),
        backgroundColor: AppColors.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Bottom sheet untuk theme settings
class ThemeSettingsBottomSheet extends StatelessWidget {
  const ThemeSettingsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.palette_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Theme Settings',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          const ThemeSelector(showLabel: false),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Theme changes are automatically saved and will persist between app sessions.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
