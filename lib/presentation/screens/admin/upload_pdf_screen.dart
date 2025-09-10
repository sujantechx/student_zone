/// after lunch update

/*
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart'; // Added import for file_picker
import 'dart:io';
import '../../../data/models/subject_model.dart';
import '../../../data/models/chapter_model.dart';
import '../../../logic/content/content_cubit.dart';
import '../../../logic/content/content_state.dart';
import '../../../services/firebase_storage_service.dart';

// Screen for uploading or editing a PDF for a specific chapter
class UploadPdfScreen extends StatefulWidget {
  final SubjectModel subject;

  const UploadPdfScreen({super.key, required this.subject, required ChapterModel chapter});

  @override
  _UploadPdfScreenState createState() => _UploadPdfScreenState();
}

class _UploadPdfScreenState extends State<UploadPdfScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final FirebaseStorageService _storageService = FirebaseStorageService();
  String? _selectedChapterId;

  @override
  void initState() {
    super.initState();
    // Fetch chapters for the subject when the screen is initialized
    context.read<ContentCubit>().fetchChapters(subjectId: widget.subject.id);
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _titleController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  // Handle PDF file selection and upload to Firebase Storage
  Future<void> _pickAndUploadPdf() async {
    try {
      // Use file_picker to select a PDF file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null && _selectedChapterId != null) {
        // Upload the selected PDF to Firebase Storage and get the download URL
        String url = await _storageService.uploadPdf(
          File(result.files.single.path!),
          widget.subject.id,
          _selectedChapterId!,
        );
        _urlController.text = url; // Update the URL field with the download URL
      }
    } catch (e) {
      // Show error message if file selection or upload fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload PDF for ${widget.subject.title}'),
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
            // Navigate back on successful PDF upload
            else if (state is ContentActionSuccess && state.action == 'add_pdf') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PDF uploaded successfully')),
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
                  // PDF title input
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'PDF Title'),
                    validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
                  ),
                  // PDF URL input (populated after file upload)
                  TextFormField(
                    controller: _urlController,
                    decoration: const InputDecoration(labelText: 'PDF URL'),
                    validator: (value) => value!.isEmpty ? 'Please upload a PDF' : null,
                    readOnly: true, // URL is set by file picker
                  ),
                  // Button to pick and upload PDF
                  ElevatedButton(
                    onPressed: _pickAndUploadPdf,
                    child: const Text('Pick PDF'),
                  ),
                  const SizedBox(height: 16),
                  // Submit button to upload the PDF metadata to Firestore
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate() && _selectedChapterId != null) {
                        context.read<ContentCubit>().addPdf(
                          subjectId: widget.subject.id,
                          chapterId: _selectedChapterId!,
                          title: _titleController.text,
                          url: _urlController.text,
                        );
                      }
                    },
                    child: const Text('Upload PDF'),
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
