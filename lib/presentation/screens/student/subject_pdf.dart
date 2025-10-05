// lib/presentation/screens/student/subjects_list_screen_modern.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../data/models/subject_model.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../logic/auth/auth_bloc.dart';
import '../../../logic/auth/auth_state.dart';

class SubjectPdf extends StatelessWidget {
  const SubjectPdf({super.key});

  @override
  Widget build(BuildContext context) {
    // Getting the authenticated user state
    final authState = context.watch<AuthCubit>().state;

    // A simple guard clause is cleaner than nesting the whole UI
    if (authState is! Authenticated) {
      return const Scaffold(
        body: Center(child: Text("User not authenticated.")),
      );
    }

    final user = authState.userModel;

    return Scaffold(
      // A cleaner AppBar style
      appBar: AppBar(
        title: const Text('Subjects PDF', style: TextStyle(fontWeight: FontWeight.bold)),
        // centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      body: FutureBuilder<List<SubjectModel>>(
        future: context.read<AdminRepository>().getSubjects(courseId: user.courseId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No subjects available for your course.'));
          }

          // Sorting logic remains the same, it's perfect.
          final sortedSubjects = List<SubjectModel>.from(snapshot.data!)
            ..sort((a, b) {
              if (a.subjectNumber != null && b.subjectNumber != null) {
                return a.subjectNumber!.compareTo(b.subjectNumber!);
              } else if (a.subjectNumber != null) {
                return -1;
              } else if (b.subjectNumber != null) {
                return 1;
              } else {
                return a.title.compareTo(b.title);
              }
            });

          // Using GridView for a more modern layout
          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,          // 2 cards per row
              crossAxisSpacing: 16,       // Horizontal spacing
              mainAxisSpacing: 16,        // Vertical spacing
              childAspectRatio: 0.85,     // Adjust aspect ratio (width/height) for best look
            ),
            itemCount: sortedSubjects.length,
            itemBuilder: (context, index) {
              final subject = sortedSubjects[index];
              return _SubjectGridItem(
                subject: subject,
                onTap: () {
                  final courseId = user.courseId;
                  context.push(
                    AppRoutes.chapterPDF,
                    extra: {
                      'subject': subject,
                      'courseId': courseId,
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

/// A custom widget for displaying a single subject in the grid.
/// This makes the UI code cleaner and reusable.
class _SubjectGridItem extends StatelessWidget {
  const _SubjectGridItem({
    required this.subject,
    required this.onTap,
  });

  final SubjectModel subject;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias, // Ensures content respects the card's rounded corners
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top section with gradient and icon
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade300, Colors.blue.shade500],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),
            // Bottom section with text
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Subject ${subject.subjectNumber ?? ''}'.trim(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subject.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}