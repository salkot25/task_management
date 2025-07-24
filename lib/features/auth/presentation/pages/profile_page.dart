import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/features/auth/presentation/provider/auth_provider.dart';
import 'package:myapp/features/auth/domain/entities/profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController(); // Added username controller
  final _whatsappController = TextEditingController(); // Added whatsapp controller
  Profile? _initialProfile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose(); // Dispose username controller
    _whatsappController.dispose(); // Dispose whatsapp controller
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final profile = await authProvider.getCurrentUserProfile();
    if (profile != null) {
      setState(() {
        _initialProfile = profile;
        _nameController.text = profile.name;
        _usernameController.text = profile.username ?? ''; // Populate username
        _whatsappController.text = profile.whatsapp ?? ''; // Populate whatsapp
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_initialProfile == null) return; // Cannot save if no initial profile loaded

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final updatedProfile = _initialProfile!.copyWith(
      name: _nameController.text.trim(),
      username: _usernameController.text.trim(), // Include username
      whatsapp: _whatsappController.text.trim(), // Include whatsapp
    );
    await authProvider.updateProfile(updatedProfile);
    // Optionally show a success message or navigate back
     ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final profile = authProvider.profile; // Get profile from provider state

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: authProvider.isLoading // Show loading indicator while saving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView( // Use SingleChildScrollView to prevent overflow
              padding: const EdgeInsets.all(20.0), // Increased padding for better spacing
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Placeholder Avatar
                  Center(
                    child: CircleAvatar(
                      radius: 50, // Adjust size as needed
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      child: profile?.profilePictureUrl != null // Use profile picture if available
                          ? ClipOval(
                              child: Image.network(
                                profile!.profilePictureUrl!,
                                width: 100, // Must match radius * 2
                                height: 100, // Must match radius * 2
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Icon(
                                  Icons.person_outline,
                                  size: 50,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.person_outline,
                              size: 50,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                    ),
                  ),
                  const SizedBox(height: 24.0), // Spasi setelah avatar

                  if (profile != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text('User ID: ${profile.uid}', style: Theme.of(context).textTheme.bodySmall), // Display UID
                    ),
                  // Name Field
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                       border: OutlineInputBorder(), // Use OutlineInputBorder for consistency
                       prefixIcon: const Icon(Icons.person_outline), // Icon for name
                    ),
                     keyboardType: TextInputType.name,
                  ),
                  const SizedBox(height: 16),
                  // Username Field
                   TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                       border: OutlineInputBorder(),
                       prefixIcon: const Icon(Icons.alternate_email_outlined), // Icon for username
                    ),
                     keyboardType: TextInputType.text,
                  ),
                   const SizedBox(height: 16),
                  // WhatsApp Field
                   TextField(
                    controller: _whatsappController,
                    decoration: InputDecoration(
                      labelText: 'WhatsApp',
                       border: OutlineInputBorder(),
                       prefixIcon: const Icon(Icons.phone_outlined), // Icon for whatsapp
                    ),
                     keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                   // Email Field (Display only, usually not editable via profile page)
                  if (profile != null && profile.email != null)
                     Padding(
                       padding: const EdgeInsets.only(bottom: 16.0), // Add some space below
                       child: TextField(
                         readOnly: true, // Make email read-only
                          controller: TextEditingController(text: profile.email), // Use a temporary controller for display
                          decoration: InputDecoration(
                           labelText: 'Email',
                           border: OutlineInputBorder(),
                           prefixIcon: const Icon(Icons.email_outlined),
                         ),
                       ),
                     ),

                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      child: const Text('Save Profile'),
                    ),
                  ),
                  if (authProvider.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        authProvider.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center, // Center the error message
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
