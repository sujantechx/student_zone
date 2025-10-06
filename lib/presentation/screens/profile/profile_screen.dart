// lib/presentation/screens/profile/profile_screen_modern_ui.dart
// Modernized UI for ProfileScreen (keeps same logic and state management)

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../data/models/user_model.dart';
import '../../../logic/auth/auth_bloc.dart';
import '../../../logic/auth/auth_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _collageController = TextEditingController();
  final _branchController = TextEditingController();
  final _phoneController = TextEditingController();
  final _coursesNameController = TextEditingController();

  bool _isEditing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _collageController.dispose();
    _branchController.dispose();
    _phoneController.dispose();
    _coursesNameController.dispose();
    super.dispose();
  }


  void _initializeControllers(UserModel user) {
    _nameController.text = user.name;
    _collageController.text = user.college;
    _branchController.text = user.branch;
    _phoneController.text = user.phone;
    _coursesNameController.text = user.courseId;
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final user = (context.read<AuthCubit>().state as Authenticated).userModel;
      context.read<AuthCubit>().updateProfile(
        name: _nameController.text.trim(),
        college: _collageController.text.trim(),
        branch: _branchController.text.trim(),
        phone: _phoneController.text.trim(),
        courseName: _coursesNameController.text.trim(),
      );
      setState(() => _isEditing = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is Authenticated) {
              _initializeControllers(state.userModel);
            }
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            }
            if (state is Unauthenticated) {
              context.go(AppRoutes.login);
            }
          },
          builder: (context, state) {
            if (state is! Authenticated) {
              return const Center(child: CircularProgressIndicator());
            }

            final user = state.userModel;

            return Column(
              children: [
                _buildHeader(user, context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildProfileCard(user),

                        // Animated switch between view and edit
                        AnimatedCrossFade(
                          firstChild: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                              onPressed: () => setState(() => _isEditing = true),
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit Profile'),
                            ),
                          ),
                          secondChild: _buildEditForm(user),
                          crossFadeState: _isEditing ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 300),
                        ),

                        const SizedBox(height: 24),
                        Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          child: ListTile(
                            leading: const Icon(Icons.help_outline),
                            title: const Text('Help & Support'),
                            subtitle: const Text('Contact support or view FAQs'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(height: 12),
                        Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          child: ListTile(
                            leading: const Icon(Icons.lock_outline),
                            title: const Text('Change Password'),
                            subtitle: const Text('Secure your account'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(UserModel user, BuildContext context) {
    final initials = (user.name.isNotEmpty)
        ? user.name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
        : "U";

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white.withOpacity(0.15),
            child: Text(initials, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 4),
                Text(user.email, style: const TextStyle(fontSize: 14, color: Colors.white70)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Chip(label: Text(user.branch.isEmpty ? 'No branch' : user.branch)),
                    Chip(label: Text(user.college.isEmpty ? 'No college' : user.college)),
                  ],
                ),
              ],
            ),
          ),
         /* IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => context.read<AuthCubit>().signOut(),
            tooltip: 'Sign out',
          ),*/
        ],
      ),
    );
  }

  Widget _buildProfileCard(UserModel user) {
    return Card(
      margin: const EdgeInsets.only(top: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Account', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _infoRow(icon: Icons.person, title: 'Name', value: user.name),
            const SizedBox(height: 8),
            _infoRow(icon: Icons.email, title: 'Email', value: user.email),
            const SizedBox(height: 8),
            _infoRow(icon: Icons.school, title: 'College', value: user.college),
            const SizedBox(height: 8),
            _infoRow(icon: Icons.account_tree, title: 'Branch', value: user.branch),
            const SizedBox(height: 8),
            _infoRow(icon: Icons.phone, title: 'Phone', value: user.phone),
            const SizedBox(height: 8),
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('courses').doc(user.courseId).get(),
              builder: (context, snapshot) {
                String courseName = 'Loading...';
                if (snapshot.connectionState == ConnectionState.waiting) {
                  courseName = 'Loading...';
                } else if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
                  courseName = 'Not Found';
                } else {
                  final courseData = snapshot.data!.data() as Map<String, dynamic>;
                  courseName = courseData['title'] ?? 'Unknown';
                }
                return _infoRow(icon: Icons.menu_book, title: 'Course', value: courseName);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow({required IconData icon, required String title, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12,)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm(UserModel user) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _styledField(controller: _nameController, label: 'Name', icon: Icons.person, validator: (v) => v!.isEmpty ? 'Name cannot be empty' : null),
              const SizedBox(height: 12),
              TextFormField(
                decoration: _inputDecoration(label: 'Email', icon: Icons.email),
                controller: TextEditingController(text: user.email),
                readOnly: true,
              ),
              const SizedBox(height: 12),
              _styledField(controller: _collageController, label: 'College', icon: Icons.school, validator: (v) => v!.isEmpty ? 'College cannot be empty' : null),
              const SizedBox(height: 12),
              _styledField(controller: _branchController, label: 'Branch', icon: Icons.account_tree, validator: (v) => v!.isEmpty ? 'Branch cannot be empty' : null),
              const SizedBox(height: 12),
              _styledField(controller: _phoneController, label: 'Phone', icon: Icons.phone, keyboardType: TextInputType.phone, validator: (v) => v!.isEmpty ? 'Phone cannot be empty' : null),
              const SizedBox(height: 12),
              TextFormField(
                decoration: _inputDecoration(label: 'Course Name', icon: Icons.menu_book),
                controller: _coursesNameController,
                readOnly: true,
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _updateProfile,
                      icon: const Icon(Icons.save),
                      label: const Text('Save'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () {
                      _initializeControllers(user);
                      setState(() => _isEditing = false);
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _styledField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: _inputDecoration(label: label, icon: icon),
    );
  }


}



/*
// lib/presentation/screens/profile/profile_screen.dart
// ... all imports
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../data/models/user_model.dart';
import '../../../logic/auth/auth_bloc.dart';
import '../../../logic/auth/auth_state.dart';



class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _collageController = TextEditingController();
  final _branchController = TextEditingController();
  final _phoneController = TextEditingController();
  final _coursesNameController = TextEditingController();

  bool _isEditing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _collageController.dispose();
    _branchController.dispose();
    _phoneController.dispose();
    _coursesNameController.dispose();
    super.dispose();
  }

  void _initializeControllers(UserModel user) {
    _nameController.text = user.name;
    _collageController.text = user.college;
    _branchController.text = user.branch;
    _phoneController.text = user.phone;
    _coursesNameController.text = user.courseId;
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final user = (context.read<AuthCubit>().state as Authenticated).userModel;
      context.read<AuthCubit>().updateProfile(
        name: _nameController.text.trim(),
        college: _collageController.text.trim(),
        branch: _branchController.text.trim(),
        phone: _phoneController.text.trim(),
        courseName: _coursesNameController.text.trim(),
      );
      setState(() => _isEditing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthCubit>().signOut(),
          ),
        ],
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            _initializeControllers(state.userModel);
          }
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          if (state is Unauthenticated) {
            context.go(AppRoutes.login);
          }
        },
        builder: (context, state) {
          if (state is! Authenticated) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = state.userModel;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User Profile',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),

                if (!_isEditing)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Name: ${user.name}', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text('Email: ${user.email}'),
                          const SizedBox(height: 8),
                          Text('Coollege: ${user.college}'),
                          const SizedBox(height: 8),
                          Text('Branch: ${user.branch}'),
                          const SizedBox(height: 8),
                          Text('Phone: ${user.phone}'),
                          // Text(' ${user.role}'),
                          // const SizedBox(height: 8),
                          // Text('Status: ${user.status}'),
                          const SizedBox(height: 8),
                          // Correctly using FutureBuilder
                          FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance.collection('courses').doc(user.courseId).get(),
                            builder: (context, snapshot) {
                              String courseName = 'Loading...';
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                courseName = 'Loading...';
                              } else if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
                                courseName = 'Not Found';
                              } else {
                                final courseData = snapshot.data!.data() as Map<String, dynamic>;
                                courseName = courseData['title'] ?? 'Unknown';
                              }
                              return Text('Course Name: $courseName');
                            },
                          ),
                          const SizedBox(height: 8),
                          // Text('Course id: ${user.courseId}'),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                _isEditing
                    ? Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.grey)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.blue)),
                        ),
                        validator: (v) => v!.isEmpty ? 'Name cannot be empty' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Email',
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.grey)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.blue)),
                        ),
                        controller: TextEditingController(text: user.email),
                        readOnly: true,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _collageController,
                        decoration: InputDecoration(
                          labelText: 'College',
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.grey)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.blue)),
                        ),
                        validator: (v) => v!.isEmpty ? 'College cannot be empty' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _branchController,
                        decoration: InputDecoration(
                          labelText: 'Branch',
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.grey)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.blue)),
                        ),
                        validator: (v) => v!.isEmpty ? 'Branch cannot be empty' : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'Phone',
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.grey)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.blue)),
                        ),
                        validator: (v) => v!.isEmpty ? 'Phone cannot be empty' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Course Name',
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.grey)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.blue)),
                        ),
                        controller:_coursesNameController,
                        readOnly: true,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _updateProfile,
                              child: const Text('Save'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () {
                              _initializeControllers(user);
                              setState(() => _isEditing = false);
                            },
                            child: const Text('Cancel'),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
                    : ElevatedButton(
                  onPressed: () => setState(() => _isEditing = true),
                  child: const Text('Edit Profile'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


///device hestor
*/
/*  Text(
                  'Device History',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _fetchDeviceHistory(user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Error loading device history');
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final devices = snapshot.data!;
                    if (devices.isEmpty) {
                      return const Text('No device history available');
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: devices.length,
                      itemBuilder: (context, index) {
                        final device = devices[index];
                        return ListTile(
                          title: Text(device['name'] ?? 'Unknown Device'),
                          subtitle: Text(
                            'Type: ${device['type']}\n'
                                'Token: ${device['token']}\n'
                                'Login: ${device['loginTime'].toDate()}\n'
                                'Logout: ${device['logoutTime']?.toDate() ?? 'Active'}',
                          ),
                        );
                      },
                    );
                  },
                ),*/
