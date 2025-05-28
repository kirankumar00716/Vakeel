import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/legal_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditingProfile = false;
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  
  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final legalService = Provider.of<LegalService>(context);
    final user = authService.currentUser;
    
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutConfirmation();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(authService),
            _buildStatsSection(legalService),
            _buildAboutSection(),
            _buildSettingsSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProfileHeader(AuthService authService) {
    final user = authService.currentUser!;
    final username = user['username'] ?? '';
    final email = user['email'] ?? '';
    
    return Container(
      padding: const EdgeInsets.all(20),
      color: Theme.of(context).primaryColor,
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              size: 60,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            username,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              setState(() {
                _isEditingProfile = !_isEditingProfile;
              });
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white),
              padding: const EdgeInsets.symmetric(horizontal: 24),
            ),
            child: Text(_isEditingProfile ? 'Cancel Editing' : 'Edit Profile'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatsSection(LegalService legalService) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Stats',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard(
                'Queries',
                legalService.queryHistory.length.toString(),
                Icons.chat_bubble_outline,
              ),
              _buildStatCard(
                'Saved',
                legalService.savedQueries.length.toString(),
                Icons.bookmark_outline,
              ),
              _buildStatCard(
                'Categories',
                _getUniqueCategories(legalService).length.toString(),
                Icons.category_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAboutSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About Vakeel',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vakeel is your personal legal assistant designed to provide accurate legal information and guidance. We aim to bridge the gap between legal experts and the general public.',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 8),
                Text(
                  'Note: The responses provided are for informational purposes only and do not constitute legal advice.',
                  style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSettingsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildSettingItem(
            'Change Password',
            Icons.lock_outline,
            () {
              // Show password change dialog
              _showChangePasswordDialog();
            },
          ),
          _buildSettingItem(
            'Privacy Policy',
            Icons.privacy_tip_outlined,
            () {
              // Show privacy policy
            },
          ),
          _buildSettingItem(
            'Terms of Service',
            Icons.description_outlined,
            () {
              // Show terms of service
            },
          ),
          _buildSettingItem(
            'App Version',
            Icons.info_outline,
            null,
            trailing: const Text('1.0.0'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSettingItem(
    String title,
    IconData icon,
    VoidCallback? onTap, {
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
  
  void _showChangePasswordDialog() {
    final TextEditingController currentPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: currentPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Current Password',
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your current password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: newPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'New Password',
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a new password';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Handle password change
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password changed successfully')),
                  );
                }
              },
              child: const Text('CHANGE'),
            ),
          ],
        );
      },
    );
  }
  
  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                final authService = Provider.of<AuthService>(context, listen: false);
                authService.logout();
                Navigator.pop(context);
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: const Text('LOGOUT'),
            ),
          ],
        );
      },
    );
  }
  
  List<String> _getUniqueCategories(LegalService legalService) {
    final Set<String> categories = {};
    
    for (final query in legalService.queryHistory) {
      if (query.category != null) {
        categories.add(query.category!);
      }
    }
    
    return categories.toList();
  }
}