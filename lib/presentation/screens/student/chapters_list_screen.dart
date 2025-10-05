// lib/presentation/screens/student/chapters_list_modern_ui.dart
// Modernized UI for ChaptersListScreen — keeps original logic and navigation.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../data/models/chapter_model.dart';
import '../../../data/models/subject_model.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../logic/auth/auth_bloc.dart';
import '../../../logic/auth/auth_state.dart';

class ChaptersListScreen extends StatefulWidget {
  final SubjectModel subject;
  final String courseId;
  const ChaptersListScreen({super.key, required this.subject, required this.courseId});

  @override
  State<ChaptersListScreen> createState() => _ChaptersListScreenState();
}

class _ChaptersListScreenState extends State<ChaptersListScreen> {
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

  List<ChapterModel> _applySearch(List<ChapterModel> chapters) {
    if (_search.isEmpty) return chapters;
    return chapters.where((c) {
      final title = c.title.toLowerCase();
      final num = c.chapterNumber?.toString() ?? '';
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
        title: Text(widget.subject.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(62),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search chapters or number...',
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
      body: FutureBuilder<List<ChapterModel>>(
        future: context.read<AdminRepository>().getChapters(subjectId: widget.subject.id, courseId: user.courseId),
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
            return const Center(child: Text('No chapters found for this subject.'));
          }

          final sortedChapters = List<ChapterModel>.from(snapshot.data!)
            ..sort((a, b) {
              if (a.chapterNumber != null && b.chapterNumber != null) {
                return a.chapterNumber!.compareTo(b.chapterNumber!);
              } else if (a.chapterNumber != null && b.chapterNumber == null) {
                return -1;
              } else if (a.chapterNumber == null && b.chapterNumber != null) {
                return 1;
              } else {
                return a.title.compareTo(b.title);
              }
            });

          final displayChapters = _applySearch(sortedChapters);

          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: displayChapters.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final chapter = displayChapters[index];
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
                          AppRoutes.videosList,
                          extra: {
                            'subject': widget.subject,
                            'courseId': courseId,
                            'chapter': chapter,
                          },
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                            ),
                            child: Center(
                              child: Text(
                                chapter.chapterNumber != null ? '${chapter.chapterNumber}' : '?',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(chapter.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 6),
                                // Text('${chapter.lessonsCount ?? 0} lessons · ${chapter.duration ?? ""}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: Colors.grey[700]),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
