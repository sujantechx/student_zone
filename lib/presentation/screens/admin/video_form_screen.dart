/// after lunch update

/*
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/subject_model.dart';
import '../../../logic/content/content_cubit.dart';
import '../../../logic/content/content_state.dart';



// Screen for admins to manage subjects, chapters, videos, and PDFs
class VideoFormScreen extends StatefulWidget {
  final SubjectModel? subject; // Optional subject for pre-selection

  const VideoFormScreen({super.key, this.subject});

  @override
  _VideoFormScreenState createState() => _VideoFormScreenState();
}

class _VideoFormScreenState extends State<VideoFormScreen> {
  final _subjectFormKey = GlobalKey<FormState>();
  final _chapterFormKey = GlobalKey<FormState>();
  final _videoFormKey = GlobalKey<FormState>();
  final _pdfFormKey = GlobalKey<FormState>();

  // Form controllers for subject
  final _subjectNameController = TextEditingController();
  final _subjectDescriptionController = TextEditingController();

  // Form controllers for chapter
  final _chapterTitleController = TextEditingController();
  final _chapterOrderController = TextEditingController();

  // Form controllers for video
  final _videoTitleController = TextEditingController();
  final _videoIdController = TextEditingController();
  final _videoDurationController = TextEditingController();

  // Form controllers for PDF
  final _pdfTitleController = TextEditingController();
  final _pdfUrlController = TextEditingController();

  String? _selectedSubjectId;
  String? _selectedChapterId;
  String? _editingVideoId;
  String? _editingPdfId;

  @override
  void initState() {
    super.initState();
    // If a subject is provided, pre-select it and fetch its chapters
    if (widget.subject != null) {
      _selectedSubjectId = widget.subject!.id;
      context.read<ContentCubit>().fetchChapters(subjectId: _selectedSubjectId!);
    }
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _subjectNameController.dispose();
    _subjectDescriptionController.dispose();
    _chapterTitleController.dispose();
    _chapterOrderController.dispose();
    _videoTitleController.dispose();
    _videoIdController.dispose();
    _videoDurationController.dispose();
    _pdfTitleController.dispose();
    _pdfUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Content'),
        actions: [
          // Navigate to admin dashboard
          IconButton(
            icon: const Icon(Icons.dashboard),
            onPressed: () => context.go(AppRoutes.adminDashboard),
          ),
        ],
      ),
      body: BlocConsumer<ContentCubit, ContentState>(
        listener: (context, state) {
          // Show error messages to the user
          if (state is ContentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          // Show success messages and refresh relevant data
          if (state is ContentActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${state.action.replaceAll('_', ' ').toUpperCase()} successful')),
            );
            if (state.action.contains('subject')) {
              context.read<ContentCubit>().fetchSubjects();
            } else if (state.action.contains('chapter') && _selectedSubjectId != null) {
              context.read<ContentCubit>().fetchChapters(subjectId: _selectedSubjectId!);
            } else if (state.action.contains('video') || state.action.contains('pdf')) {
              if (_selectedSubjectId != null && _selectedChapterId != null) {
                context.read<ContentCubit>().fetchVideos(subjectId: _selectedSubjectId!, chapterId: _selectedChapterId!);
                context.read<ContentCubit>().fetchPdfs(subjectId: _selectedSubjectId!, chapterId: _selectedChapterId!);
              }
            }
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subject Management Section
                const Text('Manage Subjects', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                _buildSubjectForm(context),
                _buildSubjectList(context, state),

                const SizedBox(height: 20),

                // Chapter Management Section (shown if a subject is selected)
                if (_selectedSubjectId != null) ...[
                  const Text('Manage Chapters', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  _buildChapterForm(context),
                  _buildChapterList(context, state),
                ],

                const SizedBox(height: 20),

                // Video Management Section (shown if a chapter is selected)
                if (_selectedSubjectId != null && _selectedChapterId != null) ...[
                  const Text('Manage Videos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  _buildVideoForm(context),
                  _buildVideoList(context, state),
                ],

                const SizedBox(height: 20),

                // PDF Management Section (shown if a chapter is selected)
                if (_selectedSubjectId != null && _selectedChapterId != null) ...[
                  const Text('Manage PDFs', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  _buildPdfForm(context),
                  _buildPdfList(context, state),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // Form to add a new subject
  Widget _buildSubjectForm(BuildContext context) {
    return Form(
      key: _subjectFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _subjectNameController,
            decoration: const InputDecoration(labelText: 'Subject Name'),
            validator: (value) => value!.isEmpty ? 'Required' : null,
          ),
          TextFormField(
            controller: _subjectDescriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_subjectFormKey.currentState!.validate()) {
                context.read<ContentCubit>().addSubject(
                  name: _subjectNameController.text,
                  description: _subjectDescriptionController.text,
                );
                _subjectNameController.clear();
                _subjectDescriptionController.clear();
              }
            },
            child: const Text('Add Subject'),
          ),
        ],
      ),
    );
  }

  // List of subjects with edit and delete options
  Widget _buildSubjectList(BuildContext context, ContentState state) {
    if (state is ContentSubjectsLoaded) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: state.subjects.length,
        itemBuilder: (context, index) {
          final subject = state.subjects[index];
          return ListTile(
            title: Text(subject.title),
            subtitle: Text(subject.description),
            onTap: () {
              setState(() {
                _selectedSubjectId = subject.id;
                _selectedChapterId = null;
                context.read<ContentCubit>().fetchChapters(subjectId: subject.id);
              });
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _subjectNameController.text = subject.title;
                    _subjectDescriptionController.text = subject.description;
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Edit Subject'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: _subjectNameController,
                              decoration: const InputDecoration(labelText: 'Subject Name'),
                              validator: (value) => value!.isEmpty ? 'Required' : null,
                            ),
                            TextFormField(
                              controller: _subjectDescriptionController,
                              decoration: const InputDecoration(labelText: 'Description'),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              context.read<ContentCubit>().updateSubject(
                                subjectId: subject.id,
                                name: _subjectNameController.text,
                                description: _subjectDescriptionController.text,
                              );
                              Navigator.pop(context);
                            },
                            child: const Text('Update'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    context.read<ContentCubit>().deleteSubject(subjectId: subject.id);
                  },
                ),
              ],
            ),
          );
        },
      );
    } else if (state is ContentLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is ContentError) {
      return Text(state.message);
    }
    return Container();
  }

  // Form to add a new chapter
  Widget _buildChapterForm(BuildContext context) {
    return Form(
      key: _chapterFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _chapterTitleController,
            decoration: const InputDecoration(labelText: 'Chapter Title'),
            validator: (value) => value!.isEmpty ? 'Required' : null,
          ),
          TextFormField(
            controller: _chapterOrderController,
            decoration: const InputDecoration(labelText: 'Order'),
            keyboardType: TextInputType.number,
            validator: (value) => value!.isEmpty ? 'Required' : null,
          ),
          ElevatedButton(
            onPressed: () {
              if (_chapterFormKey.currentState!.validate()) {
                context.read<ContentCubit>().addChapter(
                  subjectId: _selectedSubjectId!,
                  title: _chapterTitleController.text,
                  order: int.parse(_chapterOrderController.text),
                );
                _chapterTitleController.clear();
                _chapterOrderController.clear();
              }
            },
            child: const Text('Add Chapter'),
          ),
        ],
      ),
    );
  }

  // List of chapters with edit and delete options
  Widget _buildChapterList(BuildContext context, ContentState state) {
    if (state is ContentChaptersLoaded) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: state.chapters.length,
        itemBuilder: (context, index) {
          final chapter = state.chapters[index];
          return ListTile(
            title: Text(chapter.title),
            subtitle: Text('Order: ${chapter.order}'),
            onTap: () {
              setState(() {
                _selectedChapterId = chapter.id;
                context.read<ContentCubit>().fetchVideos(subjectId: _selectedSubjectId!, chapterId: chapter.id);
                context.read<ContentCubit>().fetchPdfs(subjectId: _selectedSubjectId!, chapterId: chapter.id);
              });
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _chapterTitleController.text = chapter.title;
                    _chapterOrderController.text = chapter.order.toString();
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Edit Chapter'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: _chapterTitleController,
                              decoration: const InputDecoration(labelText: 'Chapter Title'),
                              validator: (value) => value!.isEmpty ? 'Required' : null,
                            ),
                            TextFormField(
                              controller: _chapterOrderController,
                              decoration: const InputDecoration(labelText: 'Order'),
                              keyboardType: TextInputType.number,
                              validator: (value) => value!.isEmpty ? 'Required' : null,
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              context.read<ContentCubit>().updateChapter(
                                subjectId: _selectedSubjectId!,
                                chapterId: chapter.id,
                                title: _chapterTitleController.text,
                                order: int.parse(_chapterOrderController.text),
                              );
                              Navigator.pop(context);
                            },
                            child: const Text('Update'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    context.read<ContentCubit>().deleteChapter(subjectId: _selectedSubjectId!, chapterId: chapter.id);
                  },
                ),
              ],
            ),
          );
        },
      );
    } else if (state is ContentLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is ContentError) {
      return Text(state.message);
    }
    return Container();
  }

  // Form to add or edit a video
  Widget _buildVideoForm(BuildContext context) {
    return Form(
      key: _videoFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _videoTitleController,
            decoration: const InputDecoration(labelText: 'Video Title'),
            validator: (value) => value!.isEmpty ? 'Required' : null,
          ),
          TextFormField(
            controller: _videoIdController,
            decoration: const InputDecoration(labelText: 'YouTube Video ID'),
            validator: (value) => value!.isEmpty ? 'Required' : null,
          ),
          TextFormField(
            controller: _videoDurationController,
            decoration: const InputDecoration(labelText: 'Duration (e.g., 10:45)'),
            validator: (value) => value!.isEmpty ? 'Required' : null,
          ),
          ElevatedButton(
            onPressed: () {
              if (_videoFormKey.currentState!.validate()) {
                if (_editingVideoId == null) {
                  context.read<ContentCubit>().addVideo(
                    subjectId: _selectedSubjectId!,
                    chapterId: _selectedChapterId!,
                    title: _videoTitleController.text,
                    videoId: _videoIdController.text,
                    duration: _videoDurationController.text,
                  );
                } else {
                  context.read<ContentCubit>().updateVideo(
                    subjectId: _selectedSubjectId!,
                    chapterId: _selectedChapterId!,
                    videoId: _editingVideoId!,
                    title: _videoTitleController.text,
                    videoIdField: _videoIdController.text,
                    duration: _videoDurationController.text,
                  );
                  setState(() => _editingVideoId = null);
                }
                _videoTitleController.clear();
                _videoIdController.clear();
                _videoDurationController.clear();
              }
            },
            child: Text(_editingVideoId == null ? 'Add Video' : 'Update Video'),
          ),
        ],
      ),
    );
  }

  // List of videos with edit and delete options
  Widget _buildVideoList(BuildContext context, ContentState state) {
    if (state is ContentVideosLoaded) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: state.videos.length,
        itemBuilder: (context, index) {
          final video = state.videos[index];
          return ListTile(
            title: Text(video.title),
            subtitle: Text('Duration: ${video.duration}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _videoTitleController.text = video.title;
                    _videoIdController.text = video.videoId;
                    _videoDurationController.text = video.duration;
                    setState(() => _editingVideoId = video.id);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    context.read<ContentCubit>().deleteVideo(
                      subjectId: _selectedSubjectId!,
                      chapterId: _selectedChapterId!,
                      videoId: video.id,
                    );
                  },
                ),
              ],
            ),
          );
        },
      );
    } else if (state is ContentLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is ContentError) {
      return Text(state.message);
    }
    return Container();
  }

  // Form to add or edit a PDF
  Widget _buildPdfForm(BuildContext context) {
    return Form(
      key: _pdfFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _pdfTitleController,
            decoration: const InputDecoration(labelText: 'PDF Title'),
            validator: (value) => value!.isEmpty ? 'Required' : null,
          ),
          TextFormField(
            controller: _pdfUrlController,
            decoration: const InputDecoration(labelText: 'PDF URL'),
            validator: (value) => value!.isEmpty ? 'Required' : null,
          ),
          ElevatedButton(
            onPressed: () {
              if (_pdfFormKey.currentState!.validate()) {
                if (_editingPdfId == null) {
                  context.read<ContentCubit>().addPdf(
                    subjectId: _selectedSubjectId!,
                    chapterId: _selectedChapterId!,
                    title: _pdfTitleController.text,
                    url: _pdfUrlController.text,
                  );
                } else {
                  context.read<ContentCubit>().updatePdf(
                    subjectId: _selectedSubjectId!,
                    chapterId: _selectedChapterId!,
                    pdfId: _editingPdfId!,
                    title: _pdfTitleController.text,
                    url: _pdfUrlController.text,
                  );
                  setState(() => _editingPdfId = null);
                }
                _pdfTitleController.clear();
                _pdfUrlController.clear();
              }
            },
            child: Text(_editingPdfId == null ? 'Add PDF' : 'Update PDF'),
          ),
        ],
      ),
    );
  }

  // List of PDFs with edit and delete options
  Widget _buildPdfList(BuildContext context, ContentState state) {
    if (state is ContentPdfsLoaded) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: state.pdfs.length,
        itemBuilder: (context, index) {
          final pdf = state.pdfs[index];
          return ListTile(
            title: Text(pdf.title),
            subtitle: Text(pdf.url),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _pdfTitleController.text = pdf.title;
                    _pdfUrlController.text = pdf.url;
                    setState(() => _editingPdfId = pdf.id);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    context.read<ContentCubit>().deletePdf(
                      subjectId: _selectedSubjectId!,
                      chapterId: _selectedChapterId!,
                      pdfId: pdf.id,
                    );
                  },
                ),
              ],
            ),
          );
        },
      );
    } else if (state is ContentLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is ContentError) {
      return Text(state.message);
    }
    return Container();
  }
}*/
