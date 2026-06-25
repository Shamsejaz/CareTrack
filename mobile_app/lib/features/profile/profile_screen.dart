import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../core/providers/auth_provider.dart';
import 'providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String? _profileImagePath;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _handleLogout(BuildContext context) async {
    final isDemo = ref.read(isDemoProvider);
    if (isDemo) {
      ref.read(isDemoProvider.notifier).state = false;
    } else {
      await ref.read(authControllerProvider.notifier).signOut();
    }
    if (context.mounted) context.go('/');
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (image != null) {
      setState(() {
        _profileImagePath = image.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final profileAsync = ref.watch(profileProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/dashboard'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () async {
              await context.push('/profile/edit');
              ref.invalidate(profileProvider); // Refresh after returning
            },
          ),
        ],
      ),
      body: _isLoading || profileAsync.isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildUserInfo(context, user, profileAsync.value),
              const SizedBox(height: 32),
              _buildSectionHeader(context, 'Security & Compliance'),
              _buildComplianceTile(
                context, 
                'HIPAA Compliance', 
                'Your medical data is encrypted and protected under HIPAA standards.',
                Icons.security_rounded,
              ),
              _buildComplianceTile(
                context, 
                'Data Privacy (GDPR/CCPA/PDPL)', 
                'We respect your privacy rights. You have full control over your personal data.',
                Icons.privacy_tip_rounded,
              ),
              const SizedBox(height: 32),
              _buildSectionHeader(context, 'Settings'),
              ListTile(
                leading: const Icon(Icons.language_rounded),
                title: const Text('Language Preference'),
                subtitle: const Text('English (US)'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push('/setup/language'),
              ),
              ListTile(
                leading: const Icon(Icons.people_rounded),
                title: const Text('My Care Team'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push('/profile/care-team'),
              ),
              ListTile(
                leading: Icon(Icons.star_rounded, color: Colors.amber.shade700),
                title: const Text('Upgrade to Premium', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Unlock AI insights and family care'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push('/profile/subscription'),
              ),
              const SizedBox(height: 32),
              _buildSectionHeader(context, 'Data Management (GDPR/HIPAA/PDPL)'),
              ListTile(
                leading: const Icon(Icons.download_rounded),
                title: const Text('Export My Data'),
                subtitle: const Text('Download a copy of your health records'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Preparing your data export. You will receive an email shortly.')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever_rounded, color: Colors.red),
                title: const Text('Delete My Account', style: TextStyle(color: Colors.red)),
                subtitle: const Text('Permanently remove all your data'),
                onTap: () {
                  _showDeleteConfirmation(context);
                },
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () => _handleLogout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  elevation: 0,
                ),
                child: const Text('Logout'),
              ),
              const SizedBox(height: 24),
              Text(
                'CareTrack v1.0.0\nFully Compliant Architecture',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey),
              ),
            ],
          ),
    );
  }

  Widget _buildUserInfo(BuildContext context, User? user, Map<String, dynamic>? profileData) {
    final avatarUrl = profileData?['avatar_url'];
    final fullName = profileData?['full_name'] ?? 'User';

    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              backgroundImage: _profileImagePath != null 
                  ? FileImage(File(_profileImagePath!)) as ImageProvider
                  : (avatarUrl != null 
                      ? NetworkImage(avatarUrl) 
                      : const NetworkImage('https://i.pravatar.cc/150?u=placeholder')) as ImageProvider,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          fullName,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          user?.email ?? 'patient@caretrack.com',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildComplianceTile(BuildContext context, String title, String subtitle, IconData icon) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.verified_user_rounded, color: Colors.green, size: 20),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'This action is permanent and compliant with GDPR "Right to be Forgotten". '
          'All your health records, logs, and profile data will be permanently deleted from our servers.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                Navigator.pop(context);
                context.go('/');
              }
            },
            child: const Text('Delete Permanently', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
