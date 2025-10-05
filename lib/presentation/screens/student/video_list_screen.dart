import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../data/models/chapter_model.dart';
import '../../../data/models/subject_model.dart';
import '../../../data/models/video_model.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../logic/auth/auth_bloc.dart';
import '../../../logic/auth/auth_state.dart';

class VideosListScreen extends StatelessWidget {
  final String courseId;
  final SubjectModel subject;
  final ChapterModel chapter;
  const VideosListScreen({
    super.key,
    required this.subject,
    required this.chapter,
    required this.courseId,
  });

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    if (authState is! Authenticated) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(chapter.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: FutureBuilder<List<VideoModel>>(
        future: context.read<AdminRepository>().getVideos(
          subjectId: subject.id,
          chapterId: chapter.id,
          courseId: courseId,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No videos found for this chapter.', style: TextStyle(fontSize: 16)),
            );
          }

          final sortedVideos = List<VideoModel>.from(snapshot.data!)
            ..sort((a, b) {
              if (a.videoNumber != null && b.videoNumber != null) {
                return a.videoNumber!.compareTo(b.videoNumber!);
              } else if (a.videoNumber != null && b.videoNumber == null) {
                return -1;
              } else if (a.videoNumber == null && b.videoNumber != null) {
                return 1;
              } else {
                return a.title.compareTo(b.title);
              }
            });

          return RefreshIndicator(
            onRefresh: () async {
              context.read<AdminRepository>().getVideos(
                subjectId: subject.id,
                chapterId: chapter.id,
                courseId: courseId,
              );
            },
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemCount: sortedVideos.length,
              itemBuilder: (context, index) {
                final video = sortedVideos[index];
                return GestureDetector(
                  onTap: () => context.push('${AppRoutes.videoPlayer}/${video.videoId}'),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Stack(
                              children: [
                                Container(
                                  color: Colors.black12,
                                  child: const Center(
                                    child: Icon(Icons.play_circle_fill_rounded, size: 48, color: Colors.red),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      video.videoNumber != null ? '#${video.videoNumber}' : '',
                                      style: const TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                video.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '⏱ Duration: ${video.duration}',
                                style: TextStyle(color: Colors.grey[700], fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
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