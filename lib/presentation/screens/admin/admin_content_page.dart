// lib/presentation/pages/admin/admin_content_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/chapter_model.dart';
import '../../../data/models/subject_model.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../logic/pdf/pdfs_bloc.dart';
import '../../../logic/pdf/pdfs_event.dart';
import '../../../logic/video/videos_bloc.dart';
import '../../../logic/video/videos_event.dart';
import 'admin_pdfs_list.dart';
import 'admin_videos_list.dart';


class AdminContentPage extends StatelessWidget {
  final SubjectModel subject;
  final ChapterModel chapter;
  final String courseId = 'ojee_2025_2026_batch';

  const AdminContentPage({
    super.key,
    required this.subject,
    required this.chapter,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => VideosBloc(AdminRepository())
            ..add(LoadVideos(
                courseId: courseId,
                subjectId: subject.id,
                chapterId: chapter.id)),
        ),
        BlocProvider(
          create: (context) => PdfsBloc(AdminRepository())
            ..add(LoadPdfs(
                courseId: courseId,
                subjectId: subject.id,
                chapterId: chapter.id)),
        ),
      ],
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(chapter.title),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.videocam), text: 'Videos'),
                Tab(icon: Icon(Icons.picture_as_pdf), text: 'PDFs'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              AdminVideosList(courseId: courseId, subjectId: subject.id, chapterId: chapter.id),
              AdminPdfsList(courseId: courseId, subjectId: subject.id, chapterId: chapter.id),
            ],
          ),
        ),
      ),
    );
  }
}