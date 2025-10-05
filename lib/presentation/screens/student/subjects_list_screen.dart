// lib/presentation/screens/student/subjects_list_modern_ui.dart
// Modernized UI for SubjectsListScreen — keeps all original data & navigation logic.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../data/models/subject_model.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../logic/auth/auth_bloc.dart';
import '../../../logic/auth/auth_state.dart';

class SubjectsListScreen extends StatefulWidget {
  const SubjectsListScreen({super.key});

  @override
  State<SubjectsListScreen> createState() => _SubjectsListScreenState();
}

class _SubjectsListScreenState extends State<SubjectsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _search = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() => _search = _searchController.text.trim().toLowerCase()));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SubjectModel> _applySearch(List<SubjectModel> subjects) {
    if (_search.isEmpty) return subjects;
    return subjects.where((s) {
      final title = s.title.toLowerCase();
      final num = s.subjectNumber?.toString() ?? '';
      return title.contains(_search) || num.contains(_search);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;

    if (authState is! Authenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = authState.userModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subjects'),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.refresh),
            onPressed: () => setState(() {}), // simple refresh by rebuilding
            tooltip: 'Refresh',
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search subjects or number...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => setState(() => _searchController.clear()),
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear'),
                  style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                )
              ],
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<SubjectModel>>(
        future: context.read<AdminRepository>().getSubjects(courseId: user.courseId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error: ${snapshot.error}', textAlign: TextAlign.center),
            ));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No subjects available for this course.'));
          }

          final sortedSubjects = List<SubjectModel>.from(snapshot.data!)
            ..sort((a, b) {
              if (a.subjectNumber != null && b.subjectNumber != null) {
                return a.subjectNumber!.compareTo(b.subjectNumber!);
              } else if (a.subjectNumber != null && b.subjectNumber == null) {
                return -1;
              } else if (a.subjectNumber == null && b.subjectNumber != null) {
                return 1;
              } else {
                return a.title.compareTo(b.title);
              }
            });

          final displaySubjects = _applySearch(sortedSubjects);

          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 3 / 2,
                ),
                itemCount: displaySubjects.length,
                itemBuilder: (context, index) {
                  final subject = displaySubjects[index];

                  return Material(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        final authState = context.read<AuthCubit>().state;
                        if (authState is Authenticated) {
                          final user = authState.userModel;
                          final courseId = user.courseId;

                          context.push(
                            AppRoutes.chaptersList,
                            extra: {
                              'subject': subject,
                              'courseId': courseId,
                            },
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                                  child: Text(
                                    subject.subjectNumber != null ? '${subject.subjectNumber}' : '?',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const Icon(Icons.play_circle_fill, size: 22),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: Text(
                                subject.title,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Text('${subject. ?? 0} lessons', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                Icon(Icons.chevron_right, size: 18, color: Colors.grey[700]),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
