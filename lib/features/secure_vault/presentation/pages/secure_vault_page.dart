import 'package:flutter/material.dart';
import 'package:myapp/utils/design_system/app_colors.dart';
import 'package:myapp/utils/design_system/app_spacing.dart';
import 'package:myapp/utils/design_system/app_typography.dart';
import 'package:myapp/utils/design_system/app_components.dart';
import 'package:myapp/presentation/widgets/standard_app_bar.dart';

class SecureVaultPage extends StatefulWidget {
  const SecureVaultPage({super.key});

  @override
  State<SecureVaultPage> createState() => _SecureVaultPageState();
}

class _SecureVaultPageState extends State<SecureVaultPage> {
  bool _isGridView = false;
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Passwords',
    'Cards',
    'Notes',
    'Files',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyExtraLightColor,
      appBar: StandardAppBar(
        title: 'Secure Vault',
        subtitle: 'Your encrypted data storage',
        actions: [
          AppBarFilterChip(
            value: _selectedCategory,
            items: _categories,
            color: AppColors.primaryColor,
            label: 'Category',
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedCategory = newValue;
                });
              }
            },
          ),
          const SizedBox(width: AppSpacing.sm),
          ActionButton(
            icon: _isGridView ? Icons.list : Icons.grid_view,
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            tooltip: _isGridView ? 'List View' : 'Grid View',
          ),
          ActionButton(
            icon: Icons.search,
            onPressed: () {
              // Search functionality
            },
            tooltip: 'Search',
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Stats Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryColor,
                      AppColors.primaryDarkColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AppComponents.largeBorderRadius,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Items',
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            '24',
                            style: AppTypography.displaySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.security,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Category Overview
              Text(
                'Categories',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Category Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.5,
                children: [
                  _buildCategoryCard(
                    'Passwords',
                    Icons.lock_outline,
                    '12 items',
                    AppColors.primaryColor,
                  ),
                  _buildCategoryCard(
                    'Credit Cards',
                    Icons.credit_card,
                    '4 items',
                    AppColors.successColor,
                  ),
                  _buildCategoryCard(
                    'Secure Notes',
                    Icons.note_outlined,
                    '6 items',
                    AppColors.warningColor,
                  ),
                  _buildCategoryCard(
                    'Documents',
                    Icons.folder_outlined,
                    '2 items',
                    AppColors.infoColor,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // Recent Items
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Items',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'View All',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              // Recent Items List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  return _buildRecentItem(
                    'Google Account',
                    'Password',
                    Icons.lock_outline,
                    AppColors.primaryColor,
                  );
                },
              ),

              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Add new vault item
        },
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
    );
  }

  Widget _buildCategoryCard(
    String title,
    IconData icon,
    String subtitle,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppComponents.standardBorderRadius,
        border: Border.all(color: AppColors.greyLightColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: AppTypography.bodySmall.copyWith(color: AppColors.greyColor),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentItem(
    String title,
    String type,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppComponents.standardBorderRadius,
        border: Border.all(color: AppColors.greyLightColor, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  type,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.greyColor,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.greyColor),
        ],
      ),
    );
  }
}
