/// after lunch update


/*
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/subject_model.dart';
import '../../../data/models/chapter_model.dart';
import '../../../logic/content/content_cubit.dart';
import '../../../logic/content/content_state.dart';

// Screen for uploading or editing a video for a specific chapter
class UploadVideoScreen extends StatefulWidget {
  final SubjectModel subject;

  const UploadVideoScreen({super.key, required this.subject, required ChapterModel chapter});

  @override
  _UploadVideoScreenState createState() => _UploadVideoScreenState();
}

class _UploadVideoScreenState extends State<UploadVideoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _videoIdController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  String? _selectedChapterId;

  @override
  void initState() {
    super.initState();
    // Fetch chapters for the subject when the screen is initialized
    context.read<ContentCubit>().fetchChapters(subjectId: widget.subject.id);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _videoIdController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Video for ${widget.subject.title}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocConsumer<ContentCubit, ContentState>(
          listener: (context, state) {
            // Show error message if the operation fails
            if (state is ContentError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
            // Navigate back on successful video upload
            else if (state is ContentActionSuccess && state.action == 'add_video') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Video uploaded successfully')),
              );
              Navigator.of(context).pop();
            }
          },
          builder: (context, state) {
            // Show loading indicator during operations
            if (state is ContentLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return Form(
              key: _formKey,
              child: Column(
                children: [
                  // Dropdown to select a chapter
                  BlocBuilder<ContentCubit, ContentState>(
                    builder: (context, state) {
                      List<ChapterModel> chapters = [];
                      if (state is ContentChaptersLoaded) {
                        chapters = state.chapters;
                      }
                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Select Chapter'),
                        items: chapters.map((chapter) {
                          return DropdownMenuItem<String>(
                            value: chapter.id,
                            child: Text(chapter.title),
                          );
                        }).toList(),
                        value: _selectedChapterId,
                        onChanged: (value) {
                          setState(() {
                            _selectedChapterId = value;
                          });
                        },
                        validator: (value) => value == null ? 'Please select a chapter' : null,
                      );
                    },
                  ),
                  // Video title input
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Video Title'),
                    validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
                  ),
                  // YouTube video ID input
                  TextFormField(
                    controller: _videoIdController,
                    decoration: const InputDecoration(labelText: 'YouTube Video ID'),
                    validator: (value) => value!.isEmpty ? 'Please enter a video ID' : null,
                  ),
                  // Video duration input
                  TextFormField(
                    controller: _durationController,
                    decoration: const InputDecoration(labelText: 'Duration (e.g., 10:45)'),
                    validator: (value) => value!.isEmpty ? 'Please enter a duration' : null,
                  ),
                  const SizedBox(height: 16),
                  // Submit button to upload the video
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate() && _selectedChapterId != null) {
                        context.read<ContentCubit>().addVideo(
                          subjectId: widget.subject.id,
                          chapterId: _selectedChapterId!,
                          title: _titleController.text,
                          videoId: _videoIdController.text,
                          duration: _durationController.text,
                        );
                      }
                    },
                    child: const Text('Upload Video'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}*/
