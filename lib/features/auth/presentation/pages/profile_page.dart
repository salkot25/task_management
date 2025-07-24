import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/features/auth/presentation/provider/auth_provider.dart';
import 'package:myapp/features/auth/domain/entities/profile.dart';
import 'dart:developer' as developer; // Import developer for logging

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Profile? _initialProfile; // This field was unused

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
    // Check if the widget is still mounted before accessing context
    if (!mounted) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final profile = await authProvider.getCurrentUserProfile();
    if (profile != null) {
      // Check if the widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          // _initialProfile = profile; // This field was unused
          developer.log('Profile loaded: ${profile.uid}', name: 'ProfilePage');
        });
      }
    } else {
      developer.log('Profile is null after loading', name: 'ProfilePage');
    }
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
    // Check if the widget is still mounted before accessing context
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
      appBar: AppBar(title: const Text('Profile'), elevation: 0),
      body:
          authProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ID Card Section
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          // Use Column for ID Card layout
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start, // Align content to start
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Avatar Section (Left Side)
                                Stack(
                                  // Use Stack to place edit button over avatar
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          // Add box shadow for depth
                                          BoxShadow(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.3),
                                            blurRadius: 10,
                                            spreadRadius: 3,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: CircleAvatar(
                                        radius: 40,
                                        backgroundColor: Theme.of(
                                          context,
                                        ).colorScheme.primary.withOpacity(0.2),
                                        child:
                                            profile?.profilePictureUrl != null
                                                ? ClipOval(
                                                  child: Image.network(
                                                    profile!.profilePictureUrl!,
                                                    width: 80,
                                                    height: 80,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) => Icon(
                                                          Icons.person_outline,
                                                          size: 40,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                        ),
                                                  ),
                                                )
                                                : Icon(
                                                  Icons.person_outline,
                                                  size: 40,
                                                  color:
                                                      Theme.of(
                                                        context,
                                                      ).colorScheme.primary,
                                                ),
                                      ),
                                    ),
                                    // Edit button over avatar
                                    if (profile !=
                                        null) // Only show edit button if profile is not null
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: InkWell(
                                          onTap: () {
                                            developer.log(
                                              'Edit button tapped, profile: ${profile.uid}',
                                              name: 'ProfilePage',
                                            );
                                            _showEditProfileDialog(
                                              profile,
                                            ); // Now we are sure profile is not null
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                            ),
                                            child: const Icon(
                                              Icons.edit,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(
                                  width: 20,
                                ), // Space between avatar and details
                                // Profile Details Section (Right Side)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Name
                                      Text(
                                        profile?.name ?? 'N/A',
                                        style:
                                            Theme.of(context)
                                                .textTheme
                                                .titleLarge, // Use titleLarge for name
                                      ),
                                      const SizedBox(height: 8),
                                      // Username
                                      if (profile?.username != null &&
                                          profile!.username!.isNotEmpty)
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.alternate_email_outlined,
                                              size: 18,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '@${profile.username!}',
                                              style:
                                                  Theme.of(
                                                    context,
                                                  ).textTheme.bodyMedium,
                                            ),
                                          ],
                                        ),
                                      const SizedBox(height: 8),
                                      // Email (Display only)
                                      if (profile != null &&
                                          profile.email != null)
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.email_outlined,
                                              size: 18,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              profile.email!,
                                              style:
                                                  Theme.of(
                                                    context,
                                                  ).textTheme.bodyMedium,
                                            ),
                                          ],
                                        ),
                                      const SizedBox(height: 8),
                                      // WhatsApp
                                      if (profile?.whatsapp != null &&
                                          profile!.whatsapp!.isNotEmpty)
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.phone_outlined,
                                              size: 18,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              profile.whatsapp!,
                                              style:
                                                  Theme.of(
                                                    context,
                                                  ).textTheme.bodyMedium,
                                            ),
                                          ],
                                        ),
                                      const SizedBox(height: 8),
                                      // User ID
                                      if (profile != null)
                                        Text(
                                          'UID: ${profile.uid}',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall?.copyWith(
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32.0), // Space after ID Card
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
