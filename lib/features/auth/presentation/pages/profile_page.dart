import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/features/auth/presentation/provider/auth_provider.dart';
import 'package:myapp/features/auth/domain/entities/profile.dart';
import 'package:intl/intl.dart';
import 'package:myapp/presentation/widgets/standard_app_bar.dart';
import 'package:myapp/utils/design_system/design_system.dart';
import 'package:myapp/core/sync/widgets/sync_status_widget.dart';
import 'package:myapp/core/sync/services/auto_sync_service.dart';
import 'package:myapp/core/sync/services/connectivity_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isRefreshing = false;
  String? _lastError;

  // App settings state
  bool _notificationsEnabled = true;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    // Defer initialization until after the build phase is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProfileData();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Initialize profile data with comprehensive error handling
  Future<void> _initializeProfileData() async {
    // Ensure widget is still mounted before proceeding
    if (!mounted) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Check if user is authenticated
      if (authProvider.user == null) {
        if (mounted) {
          setState(() {
            _lastError = 'User not authenticated';
          });
        }
        return;
      }

      // Clear previous errors
      if (mounted) {
        setState(() {
          _lastError = null;
        });
      }

      // Load profile data from backend
      await authProvider.getCurrentUserProfile();

      // Only update state if widget is still mounted
      if (!mounted) return;

      // Check for any errors after loading
      if (authProvider.errorMessage != null) {
        setState(() {
          _lastError = authProvider.errorMessage;
        });
      } else if (authProvider.profile == null) {
        // Profile doesn't exist - this might be a new user
        setState(() {
          _lastError =
              'Profile not found. This might be a new account that needs profile setup.';
        });
      } else {
        setState(() {
          _lastError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _lastError = 'Failed to load profile data: ${e.toString()}';
        });
      }
    }
  }

  /// Refresh profile data with user feedback
  Future<void> _refreshProfileData() async {
    if (!mounted || _isRefreshing) return;

    setState(() {
      _isRefreshing = true;
      _lastError = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (authProvider.user == null) {
        throw Exception('User not authenticated');
      }

      await authProvider.getCurrentUserProfile();

      if (authProvider.errorMessage != null) {
        setState(() {
          _lastError = authProvider.errorMessage;
        });
        _showErrorSnackBar(
          'Failed to refresh profile: ${authProvider.errorMessage}',
        );
      } else {
        _showSuccessSnackBar('Profile refreshed successfully');
      }
    } catch (e) {
      setState(() {
        _lastError = e.toString();
      });
      _showErrorSnackBar('Failed to refresh profile data');
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  /// Show error snackbar with consistent styling
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Show success snackbar with consistent styling
  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Handle profile edit with backend integration
  Future<void> _showEditProfileDialog(Profile profile) async {
    try {
      final result = await showDialog<Profile>(
        context: context,
        builder: (BuildContext context) {
          return EditProfileDialog(profile: profile);
        },
      );

      // If profile was updated, refresh the data
      if (result != null && mounted) {
        await _refreshProfileData();
      }
    } catch (e) {
      _showErrorSnackBar('Failed to open edit dialog');
    }
  }

  /// Enhanced logout with user confirmation and proper cleanup
  Future<void> _logout() async {
    // Show confirmation dialog
    final confirmed = await _showLogoutConfirmationDialog();
    if (!confirmed || !mounted) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();

      if (authProvider.errorMessage != null) {
        _showErrorSnackBar('Logout failed: ${authProvider.errorMessage}');
      } else {
        _showSuccessSnackBar('Successfully logged out');
        // Navigation will be handled by auth state listener
      }
    } catch (e) {
      _showErrorSnackBar('Failed to logout');
    }
  }

  /// Show logout confirmation dialog
  Future<bool> _showLogoutConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.errorColor,
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Check if the current error is an actual error vs expected "profile not found"
  bool _isActualError() {
    final authError = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).errorMessage;

    // These are not actual errors - they indicate a new user without profile
    if (authError != null) {
      final lowercaseError = authError.toLowerCase();
      if (lowercaseError.contains('no document') ||
          lowercaseError.contains('not found') ||
          lowercaseError.contains('document does not exist')) {
        return false; // Not an actual error
      }

      // Special handling for "unexpected error" - only treat as non-error if related to profile
      if (lowercaseError.contains('unexpected error') &&
          (_lastError?.toLowerCase().contains('profile not found') == true ||
              _lastError?.toLowerCase().contains('new account') == true ||
              _lastError?.toLowerCase().contains('profile setup') == true)) {
        return false; // This unexpected error is related to missing profile
      }
    }

    // Check for specific non-error cases in _lastError
    if (_lastError != null) {
      final lowercaseLastError = _lastError!.toLowerCase();
      if (lowercaseLastError.contains('profile not found') ||
          lowercaseLastError.contains('new account') ||
          lowercaseLastError.contains('profile setup')) {
        return false; // Not an actual error
      }
    }

    return true; // This is an actual error
  }

  /// Wrapper for refresh that doesn't return Future for VoidCallback compatibility
  void _handleRefresh() {
    _refreshProfileData();
  }

  /// Wrapper for logout that doesn't return Future for VoidCallback compatibility
  void _handleLogout() {
    _logout();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final profile = authProvider.profile;
        final isLoading = authProvider.isLoading || _isRefreshing;
        final hasError =
            _lastError != null || authProvider.errorMessage != null;

        return Scaffold(
          appBar: StandardAppBar(
            title: 'Profile',
            subtitle: 'Manage your account',
            actions: [
              // Sync Status Widget
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: SyncStatusWidget(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => const SyncDetailsDialog(),
                    );
                  },
                ),
              ),
              if (!isLoading)
                ActionButton(
                  icon: Icons.refresh_outlined,
                  onPressed: _handleRefresh,
                  tooltip: 'Refresh Profile',
                ),
              if (!isLoading)
                ActionButton(
                  icon: Icons.logout_outlined,
                  onPressed: _handleLogout,
                  tooltip: 'Logout',
                  color: AppColors.errorColor,
                ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _refreshProfileData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Loading state
                  if (isLoading && profile == null)
                    _buildLoadingState()
                  // Profile content (when profile exists)
                  else if (profile != null) ...[
                    _buildProfileCard(profile, isLoading),
                    const SizedBox(height: 24.0),
                    _buildAppSettings(),
                    const SizedBox(height: 24.0),
                    _buildAccountActions(isLoading),
                  ]
                  // Error state (only for actual errors, not missing profile)
                  else if (hasError && _isActualError())
                    _buildErrorState()
                  // No profile state (new user or missing profile)
                  else
                    _buildNoProfileState(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build loading state widget
  Widget _buildLoadingState() {
    return SizedBox(
      height: 400,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading profile data...'),
          ],
        ),
      ),
    );
  }

  /// Build error state widget
  Widget _buildErrorState() {
    final errorMessage = _lastError ?? 'Failed to load profile data';

    return SizedBox(
      height: 400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.errorColor),
            const SizedBox(height: 16),
            Text(
              'Error Loading Profile',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _initializeProfileData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build no profile state widget (fallback case)
  Widget _buildNoProfileState() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isNewUser = authProvider.user != null && authProvider.profile == null;

    return SizedBox(
      height: 400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isNewUser ? Icons.person_add_outlined : Icons.person_outline,
              size: 64,
              color: isNewUser ? AppColors.primaryColor : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              isNewUser ? 'Welcome! Setup Your Profile' : 'No Profile Data',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                isNewUser
                    ? 'It looks like this is your first time here.\nLet\'s create your profile to get started!'
                    : 'Unable to load profile information.\nPlease try refreshing or check your connection.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 24),
            if (isNewUser) ...[
              ElevatedButton.icon(
                onPressed: () => _createNewProfile(),
                icon: const Icon(Icons.person_add),
                label: const Text('Create Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: _initializeProfileData,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _initializeProfileData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _handleLogout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.errorColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Create new profile for first-time users
  Future<void> _createNewProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.user == null) {
      _showErrorSnackBar('User not authenticated');
      return;
    }

    try {
      // Create a basic profile with user's email and required fields
      final newProfile = Profile(
        uid: authProvider.user!.uid,
        name: authProvider.user!.email?.split('@').first ?? 'User',
        email: authProvider.user!.email ?? '',
        createdAt: DateTime.now(),
        isEmailVerified:
            false, // Will be updated later when we have proper auth info
      );

      // Show edit dialog to let user customize their profile
      final result = await showDialog<Profile>(
        context: context,
        builder: (BuildContext context) {
          return EditProfileDialog(profile: newProfile);
        },
      );

      if (result != null && mounted) {
        // Profile was created/updated, refresh the page
        await _refreshProfileData();
      }
    } catch (e) {
      _showErrorSnackBar('Failed to create profile: ${e.toString()}');
    }
  }

  /// Build profile card with business card design
  Widget _buildProfileCard(Profile profile, bool isLoading) {
    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.6, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  // Left section - Avatar and basic info
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Avatar with loading indicator
                            Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 35,
                                    backgroundColor: Colors.grey[300],
                                    backgroundImage:
                                        profile.profilePictureUrl != null
                                        ? NetworkImage(
                                            profile.profilePictureUrl!,
                                          )
                                        : const AssetImage(
                                                'assets/images/default_avatar.png',
                                              )
                                              as ImageProvider,
                                  ),
                                ),
                                if (isLoading)
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.black.withOpacity(0.3),
                                      ),
                                      child: const Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            // Name and role
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile.name.isNotEmpty
                                        ? profile.name
                                        : 'No Name',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  if (profile.role != null &&
                                      profile.role!.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Text(
                                        profile.role!.toUpperCase(),
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Contact info section
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Email
                              Row(
                                children: [
                                  Icon(
                                    Icons.email_outlined,
                                    size: 16,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      profile.email ?? 'No Email',
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              // WhatsApp Number
                              if (profile.whatsapp != null &&
                                  profile.whatsapp!.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.phone_outlined,
                                      size: 16,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        profile.whatsapp!,
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Right section - Status and actions
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Edit Button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.edit_outlined,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                            onPressed: isLoading
                                ? null
                                : () => _showEditProfileDialog(profile),
                          ),
                        ),
                        const Spacer(),
                        // Status indicators
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (profile.isEmailVerified == true)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.successColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.verified,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Verified',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (profile.lastSignInAt != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Active ${_formatLastSignIn(profile.lastSignInAt!)}',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                            if (profile.createdAt != null) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Since ${DateFormat('MMM yyyy').format(profile.createdAt!)}',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.8),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build app settings section
  Widget _buildAppSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('App Settings', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16.0),

        // Notification Toggle
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Push Notifications',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Receive notifications for tasks and reminders',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _notificationsEnabled,
                  onChanged: _toggleNotifications,
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12.0),

        // Theme Toggle
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Row(
              children: [
                Icon(
                  _isDarkMode
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dark Mode',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isDarkMode
                            ? 'Switch to light theme'
                            : 'Switch to dark theme',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isDarkMode,
                  onChanged: _toggleTheme,
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12.0),

        // Auto Sync Toggle
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.sync_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Auto Sync',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Consumer2<AutoSyncService, ConnectivityService>(
                        builder:
                            (
                              context,
                              autoSyncService,
                              connectivityService,
                              child,
                            ) {
                              String subtitle;
                              if (!connectivityService.isConnected) {
                                subtitle = 'Offline - sync when connected';
                              } else if (autoSyncService.isAutoSyncEnabled) {
                                subtitle =
                                    'Automatically sync data in background';
                              } else {
                                subtitle = 'Manual sync only';
                              }

                              return Text(
                                subtitle,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.grey[700]),
                              );
                            },
                      ),
                    ],
                  ),
                ),
                Consumer2<AutoSyncService, ConnectivityService>(
                  builder:
                      (context, autoSyncService, connectivityService, child) {
                        return Switch(
                          value: autoSyncService.isAutoSyncEnabled,
                          onChanged: connectivityService.isConnected
                              ? (value) {
                                  // Update actual auto sync service
                                  autoSyncService.toggleAutoSync();

                                  _showSuccessSnackBar(
                                    value
                                        ? 'Auto sync enabled'
                                        : 'Auto sync disabled',
                                  );
                                }
                              : null,
                          activeColor: Theme.of(context).colorScheme.primary,
                        );
                      },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build information card widget
  /// Build account actions section
  Widget _buildAccountActions(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Account Actions', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16.0),

        // Action buttons
        _buildActionButton(
          icon: Icons.sync_outlined,
          title: 'Sync Settings',
          subtitle: 'Manage data synchronization',
          onTap: isLoading
              ? null
              : () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => const SyncSettingsBottomSheet(),
                  );
                },
        ),

        const SizedBox(height: 12.0),

        _buildActionButton(
          icon: Icons.security_outlined,
          title: 'Security Settings',
          subtitle: 'Manage password and security options',
          onTap: isLoading
              ? null
              : () {
                  // Navigate to security settings
                  _showErrorSnackBar('Security settings coming soon');
                },
        ),

        const SizedBox(height: 12.0),

        _buildActionButton(
          icon: Icons.notifications_outlined,
          title: 'Notification Settings',
          subtitle: 'Configure notification preferences',
          onTap: isLoading
              ? null
              : () {
                  // Navigate to notification settings
                  _showErrorSnackBar('Notification settings coming soon');
                },
        ),

        const SizedBox(height: 12.0),

        _buildActionButton(
          icon: Icons.help_outline,
          title: 'Help & Support',
          subtitle: 'Get help and contact support',
          onTap: isLoading
              ? null
              : () {
                  // Navigate to help
                  _showErrorSnackBar('Help section coming soon');
                },
        ),

        const SizedBox(height: 20.0),

        // Logout button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : _logout,
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build action button widget
  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// Format last sign in date
  String _formatLastSignIn(DateTime lastSignIn) {
    final now = DateTime.now();
    final difference = now.difference(lastSignIn);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM dd').format(lastSignIn);
    }
  }

  /// Toggle notifications setting
  void _toggleNotifications(bool value) {
    setState(() {
      _notificationsEnabled = value;
    });
    // TODO: Save to SharedPreferences or backend
    _showSuccessSnackBar(
      value ? 'Notifications enabled' : 'Notifications disabled',
    );
  }

  /// Toggle dark mode theme
  void _toggleTheme(bool value) {
    setState(() {
      _isDarkMode = value;
    });
    // TODO: Implement theme switching logic
    _showSuccessSnackBar(value ? 'Dark mode enabled' : 'Light mode enabled');
  }
}

/// Edit Profile Dialog Widget
class EditProfileDialog extends StatefulWidget {
  final Profile profile;

  const EditProfileDialog({super.key, required this.profile});

  @override
  _EditProfileDialogState createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _whatsappController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _usernameController = TextEditingController(
      text: widget.profile.username ?? '',
    );
    _whatsappController = TextEditingController(
      text: widget.profile.whatsapp ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Validate required fields
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final now = DateTime.now();
      final updatedProfile = widget.profile.copyWith(
        name: _nameController.text.trim(),
        username: _usernameController.text.trim().isEmpty
            ? null
            : _usernameController.text.trim(),
        whatsapp: _whatsappController.text.trim().isEmpty
            ? null
            : _whatsappController.text.trim(),
        // Ensure required fields are present
        email: widget.profile.email ?? authProvider.user?.email ?? '',
        createdAt: widget.profile.createdAt ?? now,
      );

      // Check if this is a new profile (no existing profile in provider)
      final isNewProfile = authProvider.profile == null;

      if (isNewProfile) {
        // Create new profile using the public method
        await authProvider.createProfile(updatedProfile);
      } else {
        // Update existing profile
        await authProvider.updateProfile(updatedProfile);
      }

      if (mounted) {
        if (authProvider.errorMessage == null) {
          Navigator.of(context).pop(updatedProfile);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isNewProfile
                    ? 'Profile created successfully!'
                    : 'Profile updated successfully!',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
        // Error handling is done in the provider and displayed in the dialog
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outlined),
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Username Field
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.alternate_email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // WhatsApp Field
                TextFormField(
                  controller: _whatsappController,
                  decoration: const InputDecoration(
                    labelText: 'WhatsApp Number',
                    prefixIcon: Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                ),

                // Error message
                if (authProvider.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      authProvider.errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: authProvider.isLoading
                  ? null
                  : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: authProvider.isLoading ? null : _saveProfile,
              child: authProvider.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
