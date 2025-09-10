import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;
import '../../../core/routes/app_routes.dart';
import '../../../data/models/video_model.dart';
import '../../../logic/auth/admin_cubit.dart';
import '../../../logic/auth/admin_state.dart';
import '../../../core/routes/app_router.dart';

// Screen for admins to manage content (subjects and courses)
class ManageContentScreen extends StatefulWidget {
  const ManageContentScreen({super.key});

  @override
  State<ManageContentScreen> createState() => _ManageContentScreenState();
}

class _ManageContentScreenState extends State<ManageContentScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    developer.log('Initializing ContentManageScreen');
    context.read<AdminCubit>().fetchContent();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filter content based on search query
  List<ContentModel> _filterContent(List<ContentModel> content) {
    return content.where((item) {
      return _searchQuery.isEmpty ||
          item.title.toLowerCase().contains(_searchQuery) ||
          item.description.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  // Show dialog to add/edit content
  void _showContentDialog(BuildContext context, {ContentModel? content}) {
    final titleController = TextEditingController(text: content?.title ?? '');
    final descriptionController = TextEditingController(text: content?.description ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(content == null ? 'Add Content' : 'Edit Content'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              final description = descriptionController.text.trim();
              if (title.isNotEmpty) {
                if (content == null) {
                  context.read<AdminCubit>().addContent(title, description);
                } else {
                  context.read<AdminCubit>().updateContent(content.id, title, description);
                }
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Title cannot be empty')),
                );
              }
            },
            child: Text(content == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  // Confirm content deletion
  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this content?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AdminCubit>().deleteContent(id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Content'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search by title or description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: BlocConsumer<AdminCubit, AdminState>(
              listener: (context, state) {
                developer.log('AdminCubit state: $state');
                if (state is AdminActionSuccess && state.action.contains('content')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                  context.read<AdminCubit>().fetchContent();
                } else if (state is AdminError) {
                  String message = state.message;
                  if (state.errorCode == 'PERMISSION_DENIED') {
                    message = 'Permission denied. Ensure you are logged in as an admin.';
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(message)),
                  );
                }
              },
              builder: (context, state) {
                if (state is AdminLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                List<ContentModel> content = [];
                if (state is ContentLoaded) {
                  content = state.content;
                } else {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('No content found'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.read<AdminCubit>().fetchContent(),
                          child: const Text('Refresh'),
                        ),
                      ],
                    ),
                  );
                }
                final filteredContent = _filterContent(content);
                if (filteredContent.isEmpty) {
                  return const Center(child: Text('No matching content found'));
                }
                return ListView.builder(
                  itemCount: filteredContent.length,
                  itemBuilder: (context, index) {
                    final item = filteredContent[index];
                    return ListTile(
                      title: Text(item.title),
                      subtitle: Text(item.description),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showContentDialog(context, content: item),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(context, item.id),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Section for managing courses/videos
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: ElevatedButton(
          //     onPressed: () => context.go(AppRoutes.videoForm),
          //     child: const Text('Manage Courses & Videos'),
          //   ),
          // ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showContentDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}