import 'package:flutter/material.dart';
import 'package:clarity/utils/design_system/app_colors.dart';
import 'package:clarity/utils/design_system/app_spacing.dart';
import 'package:clarity/utils/design_system/app_typography.dart';
import 'package:clarity/utils/design_system/app_components.dart';

class StandardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const StandardAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.leading,
    this.centerTitle = false,
    this.elevation = 0,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      backgroundColor:
          backgroundColor ??
          (isDarkMode ? const Color(0xFF2D2D2D) : Colors.white),
      foregroundColor:
          foregroundColor ?? (isDarkMode ? Colors.white : AppColors.blackColor),
      iconTheme: IconThemeData(
        color:
            foregroundColor ??
            (isDarkMode ? Colors.white : AppColors.blackColor),
        size: 24,
      ),
      elevation: elevation,
      centerTitle: centerTitle,
      leading: leading,
      title: subtitle != null
          ? Column(
              crossAxisAlignment: centerTitle
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color:
                        foregroundColor ??
                        (isDarkMode ? Colors.white : AppColors.blackColor),
                  ),
                ),
                Text(
                  subtitle!,
                  style: AppTypography.labelSmall.copyWith(
                    color: isDarkMode
                        ? Colors.grey[400]
                        : AppColors.greyDarkColor,
                  ),
                ),
              ],
            )
          : Text(
              title,
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
                color:
                    foregroundColor ??
                    (isDarkMode ? Colors.white : AppColors.blackColor),
              ),
            ),
      actions: actions != null
          ? [...actions!, const SizedBox(width: AppSpacing.sm)]
          : null,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.grey.withOpacity(0.2)
                : AppColors.greyLightColor.withOpacity(0.3),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}

class AppBarFilterChip extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final Color color;
  final String label;

  const AppBarFilterChip({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48, // Match ActionButton height (36 + padding)
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(
          12,
        ), // Match ActionButton border radius
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          icon: Icon(Icons.keyboard_arrow_down, color: color, size: 18),
          style: AppTypography.labelMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final Color? color;

  const ActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(right: AppSpacing.xs),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.grey.withOpacity(0.2)
            : AppColors.greyExtraLightColor,
        borderRadius: BorderRadius.circular(AppComponents.smallRadius),
        border: Border.all(
          color: isDarkMode
              ? Colors.grey.withOpacity(0.3)
              : AppColors.greyLightColor.withOpacity(0.5),
        ),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color:
              color ??
              (isDarkMode ? Colors.grey[300] : AppColors.greyDarkColor),
          size: 20,
        ),
        onPressed: onPressed,
        tooltip: tooltip,
        padding: const EdgeInsets.all(AppSpacing.xs),
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      ),
    );
  }
}
