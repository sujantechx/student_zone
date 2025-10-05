// lib/presentation/screens/student/test_chapter.dart


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

class TestChapter extends StatelessWidget {
  final SubjectModel subject;
  final String courseId;

  const TestChapter({
    super.key,
    required this.subject,
    required this.courseId,
  });

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    if (authState is! Authenticated) {
      return const Center(child: CircularProgressIndicator());
    }
    final user = authState.userModel;

    return Scaffold(
      appBar: AppBar(title: Text(subject.title)),
      body: FutureBuilder<List<ChapterModel>>(
        future: context.read<AdminRepository>().getChapters(subjectId: subject.id, courseId: user.courseId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No chapters found for this subject.'));
          }

          final chapters = snapshot.data!;
          return ListView.builder(
            itemCount: chapters.length,
            itemBuilder: (context, index) {
              final chapter = chapters[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: const Icon(Icons.article_rounded, color: Colors.green),
                  title: Text(chapter.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () async {
                    final authState = context.read<AuthCubit>().state;
                    if (authState is Authenticated) {
                      final user = authState.userModel;
                      final userId = user.uid;
                      final courseIdFromUser = user.courseId;

                      final testRepository = context.read<AdminRepository>();
                      final existingResult = await testRepository.getResultForUserAndChapter(
                        userId: userId,
                        chapterId: chapter.id,
                      );

                      if (existingResult != null) {
                        final questions = await testRepository.getQuestions(
                          courseId: courseIdFromUser,
                          subjectId: subject.id,
                          chapterId: chapter.id,
                        );

                        // ✅ Correct: Use push to navigate to the nested route
                        context.pushNamed(
                          AppRoutes.quizResult,
                          extra: {
                            'result': existingResult,
                            'questions': questions,
                            'courseId': courseIdFromUser,
                            'subjectId': subject.id,
                            'chapterId': chapter.id,
                          },
                        );
                      } else {
                        // ✅ Correct: Use push to navigate to the nested route
                        context.pushNamed(
                          AppRoutes.testScreen,
                          extra: {
                            'subject': subject,
                            'chapter': chapter,
                            'courseId': courseIdFromUser,
                            'subjectId': subject.id, // Pass subjectId for consistency
                          },
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please log in to take the quiz.')),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}