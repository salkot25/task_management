import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/features/auth/presentation/provider/auth_provider.dart';
import 'package:myapp/features/auth/domain/entities/profile.dart';
import 'dart:developer' as developer; // Import developer for logging
import 'package:intl/intl.dart'; // Import for date formatting

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  @override
  void initState() {
    super.initState();
    developer.log('ProfilePage initState', name: 'ProfilePage');
    _loadProfile();
  }

  @override
  void dispose() {
    developer.log('ProfilePage dispose', name: 'ProfilePage');
    super.dispose();
  }

  Future<void> _loadProfile() async {
    developer.log('_loadProfile called', name: 'ProfilePage');
    if (!mounted) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.getCurrentUserProfile();
  }

  void _showEditProfileDialog(Profile profile) {
    developer.log('_showEditProfileDialog called', name: 'ProfilePage');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditProfileDialog(profile: profile);
      },
    );
  }

  void _logout() async {
    developer.log('_logout called', name: 'ProfilePage');
    if (!mounted) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.signOut();
    // Optionally navigate to the login page or home page after logout
    // Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final profile = authProvider.profile; // Get profile from provider state
    developer.log(
      'ProfilePage build, profile: ${profile?.uid}',
      name: 'ProfilePage',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body:
          authProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Card
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary.withOpacity(0.7),
                              Theme.of(context).colorScheme.primary,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Avatar
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundColor: Colors.white.withOpacity(0.8),
                                    backgroundImage: profile?.profilePictureUrl != null
                                        ? NetworkImage(profile!.profilePictureUrl!) as ImageProvider
                                        : const AssetImage('assets/images/default_avatar.png'), // Use a default asset or handle null
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          profile?.name ?? 'N/A',
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          profile?.email ?? 'N/A',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Colors.white.withOpacity(0.8),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // Add phone number if available
                                         if (profile?.whatsapp != null && profile!.whatsapp!.isNotEmpty)
                                           Text(
                                            profile.whatsapp!,
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  // Edit Button
                                  if (profile != null)
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.white),
                                      onPressed: () => _showEditProfileDialog(profile),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24.0),

                    // Account Information Section
                    Text(
                      'Account Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16.0),

                    // WhatsApp Number Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Row(
                          children: [
                            Icon(Icons.chat_bubble_outline, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('WhatsApp Number', style: Theme.of(context).textTheme.titleMedium),
                                  const SizedBox(height: 4),
                                  Text(profile?.whatsapp ?? 'N/A', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),

                    // Role Card
                     Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Row(
                          children: [
                            Icon(Icons.work_outline, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Role', style: Theme.of(context).textTheme.titleMedium),
                                  const SizedBox(height: 4),
                                  Text(profile?.role ?? 'N/A', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),

                    // Account Created Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_outlined, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Account Created', style: Theme.of(context).textTheme.titleMedium),
                                  const SizedBox(height: 4),
                                  Text(
                                    profile?.createdAt != null
                                        ? 'Joined on ${DateFormat('MMM d, yyyy').format(profile!.createdAt!)}'
                                        : 'N/A',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),

                    // Last Sign In Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Row(
                          children: [
                            Icon(Icons.access_time, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Last Sign In', style: Theme.of(context).textTheme.titleMedium),
                                  const SizedBox(height: 4),
                                   Text(
                                    profile?.lastSignInAt != null
                                        ? 'Last signed in on ${DateFormat('MMM d, yyyy').format(profile!.lastSignInAt!)}'
                                        : 'N/A',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),

                    // Email Verified Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Row(
                          children: [
                            Icon(Icons.email_outlined, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Email Verified', style: Theme.of(context).textTheme.titleMedium),
                                ],
                              ),
                            ),
                            Icon(
                              profile?.isEmailVerified == true ? Icons.verified_user : Icons.warning_amber,
                              color: profile?.isEmailVerified == true ? Colors.green : Colors.red,
                            ),
                             const SizedBox(width: 8),
                            Text(
                              profile?.isEmailVerified == true ? 'Verified' : 'Not Verified',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: profile?.isEmailVerified == true ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                     const SizedBox(height: 24.0),

                    // Logout Button
                    ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context)
                                .colorScheme
                                .error, // Use error color for danger action
                        foregroundColor:
                            Theme.of(context).colorScheme.onError, // Text color
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Logout'),
                    ),

                    if (authProvider.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: Text(
                          authProvider.errorMessage!,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
    );
  }
}

// Widget for the Edit Profile Dialog
class EditProfileDialog extends StatefulWidget {
  final Profile profile;

  const EditProfileDialog({super.key, required this.profile});

  @override
  _EditProfileDialogState createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Form key for validation

  @override
  void initState() {
    super.initState();
    developer.log('EditProfileDialog initState', name: 'ProfilePage');
    // Initialize controllers with current profile data
    _nameController.text = widget.profile.name;
    _usernameController.text = widget.profile.username ?? '';
    _whatsappController.text = widget.profile.whatsapp ?? '';
  }

  @override
  void dispose() {
    developer.log('EditProfileDialog dispose', name: 'ProfilePage');
    _nameController.dispose();
    _usernameController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile(BuildContext context) async {
    developer.log('_saveProfile called in dialog', name: 'ProfilePage');
    if (_formKey.currentState!.validate()) {
      // Validate the form
      // Check if the widget is still mounted before accessing context
      if (!mounted) return;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final updatedProfile = widget.profile.copyWith(
        name: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        whatsapp: _whatsappController.text.trim(),
      );
      await authProvider.updateProfile(updatedProfile);
      // Close the dialog after saving
      // Check if the widget is still mounted before navigating
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    developer.log('EditProfileDialog build', name: 'ProfilePage');

    return AlertDialog(
      title: const Text('Edit Profile'),
      content: SingleChildScrollView(
        // Use SingleChildScrollView for dialog content
        child: Form(
          // Wrap with Form for validation
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min, // Make column take minimum space
            children: [
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
                keyboardType: TextInputType.name,
                validator: (value) {
                  // Add validator
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Username Field
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: const Icon(Icons.alternate_email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
                keyboardType: TextInputType.text,
                validator: (value) {
                  // Add validator
                  // Optional: Add more specific username validation if needed
                  return null; // Username is optional
                },
              ),
              const SizedBox(height: 16),
              // WhatsApp Field
              TextFormField(
                controller: _whatsappController,
                decoration: InputDecoration(
                  labelText: 'WhatsApp',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  // Add validator
                  // Optional: Add more specific WhatsApp validation if needed
                  return null; // WhatsApp is optional
                },
              ),
              if (authProvider.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    authProvider.errorMessage!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Check if the widget is still mounted before navigating
            if (mounted) {
              Navigator.of(context).pop(); // Close the dialog
            }
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed:
              authProvider.isLoading
                  ? null
                  : () => _saveProfile(context), // Pass context
          style: ElevatedButton.styleFrom(
            // Style can be inherited from theme or defined here
          ),
          child:
              authProvider.isLoading
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                  : const Text('Save'),
        ),
      ],
    );
  }
}
