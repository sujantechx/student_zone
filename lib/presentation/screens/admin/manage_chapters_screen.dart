import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/subject_model.dart';



class ManageChaptersScreen extends StatelessWidget {
  final SubjectModel subject;

  const ManageChaptersScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    // Chapters are not used, redirect to videos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.pushReplacement(AppRoutes.videosList, extra: subject);
    });

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

/*
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../data/models/chapter_model.dart';
import '../../../data/models/subject_model.dart';
import '../../../data/repositories/content_repository.dart';
import '../../../logic/content/content_cubit.dart';
import '../../../logic/content/content_state.dart';

class ManageChaptersScreen extends StatelessWidget {
  final SubjectModel subject;
  const ManageChaptersScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ContentCubit(contentRepository: context.read<ContentRepository>())..loadChapters(subjectId: subject.id),
      child: Scaffold(
        appBar: AppBar(title: Text('Manage Chapters: ${subject.title}')),
        body: BlocConsumer<ContentCubit, ContentState>(
          listener: (context, state) {
            if (state is ContentSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            } else if (state is ContentError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            if (state is ContentLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ChaptersLoaded) {
              return StreamBuilder<List<ChapterModel>>(
                stream: state.chapters,
                builder: (context, snapshot) {
                  if (snapshot.hasError) return const Center(child: Text('Error loading chapters'));
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final chapters = snapshot.data!;
                  return ListView.builder(
                    itemCount: chapters.length,
                    itemBuilder: (context, index) {
                      final chapter = chapters[index];
                      return ListTile(
                        title: Text(chapter.title),
                        subtitle: Text('Order: ${chapter.order}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                // Show update dialog
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => context.read<ContentCubit>().deleteChapter(subjectId: subject.id, chapterId: chapter.id),
                            ),
                            IconButton(
                              icon: const Icon(Icons.video_call),
                              onPressed: () => context.push(AppRoutes.uploadVideo, extra: {'subject': subject, 'chapter': chapter}),
                            ),
                            IconButton(
                              icon: const Icon(Icons.upload_file),
                              onPressed: () => context.push(AppRoutes.uploadPdf, extra: {'subject': subject, 'chapter': chapter}),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            }
            return const Center(child: Text('No chapters loaded'));
          },
        ),
      ),
    );
  }
}*/
