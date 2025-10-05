// lib/presentation/screens/student/test_subjects_modern_ui.dart
// Modern UI for TestSubjects screen — keeps your logic and navigation intact.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';

import '../../../core/routes/app_routes.dart';
import '../../../data/models/subject_model.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../logic/auth/auth_bloc.dart';
import '../../../logic/auth/auth_state.dart';

class TestSubjects extends StatefulWidget {
  const TestSubjects({super.key});

  @override
  State<TestSubjects> createState() => _TestSubjectsState();
}

class _TestSubjectsState extends State<TestSubjects> {
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
        title: const Text('Test Subjects', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(68),
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
                ElevatedButton(
                  onPressed: () => setState(() => _searchController.clear()),
                  child: const Icon(Icons.clear),
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
                  childAspectRatio: 0.95,
                ),
                itemCount: displaySubjects.length,
                itemBuilder: (context, index) {
                  final subject = displaySubjects[index];
                  return FadeInUp(
                    duration: Duration(milliseconds: 250 + (index * 60)),
                    child: Material(
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
                              AppRoutes.testChapter,
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
                                    radius: 20,
                                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                                    child: Text(
                                      subject.subjectNumber != null ? '${subject.subjectNumber}' : '?',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios, size: 18),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: Text(
                                  subject.title,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Text('${subject.testsCount ?? 0} tests', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            ],
                          ),
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
