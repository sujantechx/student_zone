
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

import '../models/chapter_model.dart';
import '../models/courses_moddel.dart';
import '../models/pdf_model.dart';
import '../models/question_model.dart';
import '../models/result_model.dart';
import '../models/subject_model.dart';
import '../models/video_model.dart';

class AdminRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Helper to get the base collection reference
  CollectionReference _coursesRef() => _firestore.collection('courses');

  // Helper to get the questions collection reference
  CollectionReference _questionsRef({
    required String courseId,
    required String subjectId,
    required String chapterId,
  }) {
    return _coursesRef()
        .doc(courseId)
        .collection('subjects')
        .doc(subjectId)
        .collection('chapters')
        .doc(chapterId)
        .collection('questions');
  }

  // Helper to get the videos collection reference
  CollectionReference _videosRef({
    required String courseId,
    required String subjectId,
    required String chapterId,
  }) {
    return _coursesRef()
        .doc(courseId)
        .collection('subjects')
        .doc(subjectId)
        .collection('chapters')
        .doc(chapterId)
        .collection('videos');
  }

  // Helper to get the PDFs collection reference
  CollectionReference _pdfsRef({
    required String courseId,
    required String subjectId,
    required String chapterId,
  }) {
    return _coursesRef()
        .doc(courseId)
        .collection('subjects')
        .doc(subjectId)
        .collection('chapters')
        .doc(chapterId)
        .collection('pdfs');
  }

  /// Fetches a list of all courses.
  Future<List<CoursesModel>> getCourses() async {
    try {
      final snapshot = await _coursesRef().get();
      return snapshot.docs.map((doc) => CoursesModel.fromSnapshot(doc)).toList();
    } catch (e) {
      developer.log("Error fetching courses: $e");
      throw Exception('Failed to load courses.');
    }
  }

  /// Fetches all subjects for a given course.
  Future<List<SubjectModel>> getSubjects({required String courseId}) async {
    try {
      final snapshot = await _coursesRef().doc(courseId).collection('subjects').get();
      return snapshot.docs.map((doc) => SubjectModel.fromSnapshot(doc)).toList();
    } catch (e) {
      developer.log("Error fetching subjects: $e");
      throw Exception('Failed to load subjects.');
    }
  }

  /// Fetches all chapters for a given subject.
  Future<List<ChapterModel>> getChapters(
      {required String courseId, required String subjectId}) async {
    try {
      final snapshot = await _coursesRef()
          .doc(courseId)
          .collection('subjects')
          .doc(subjectId)
          .collection('chapters')
          .get();
      return snapshot.docs.map((doc) => ChapterModel.fromSnapshot(doc)).toList();
    } catch (e) {
      developer.log("Error fetching chapters: $e");
      throw Exception('Failed to load chapters.');
    }
  }

  /// Fetches all videos for a given chapter.
  Future<List<VideoModel>> getVideos(
      {required String courseId,
        required String subjectId,
        required String chapterId}) async {
    try {
      final snapshot = await _videosRef(
          courseId: courseId, subjectId: subjectId, chapterId: chapterId)
          .get();
      return snapshot.docs
          .map((doc) => VideoModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      developer.log("Error fetching videos: $e");
      throw Exception('Failed to load videos.');
    }
  }

  /// Fetches all PDFs for a given chapter.
  Future<List<PdfModel>> getPdfs(
      {required String courseId,
        required String subjectId,
        required String chapterId}) async {
    try {
      final snapshot = await _pdfsRef(
          courseId: courseId, subjectId: subjectId, chapterId: chapterId)
          .get();
      return snapshot.docs
          .map((doc) => PdfModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      developer.log("Error fetching PDFs: $e");
      throw Exception('Failed to load PDFs.');
    }
  }

  /// Fetches all questions for a specific chapter.
  Future<List<QuestionModel>> getQuestions({
    required String courseId,
    required String subjectId,
    required String chapterId,
  }) async {
    try {
      final snapshot = await _questionsRef(
          courseId: courseId, subjectId: subjectId, chapterId: chapterId)
          .get();
      if (snapshot.docs.isEmpty) return <QuestionModel>[];
      return snapshot.docs
          .map((doc) => QuestionModel.fromFirestore(doc))
          .toList();
    } catch (e, st) {
      developer.log('Error fetching questions: $e', error: e, stackTrace: st);
      throw Exception('Failed to load questions.');
    }
  }

  /// Adds a new course document.
  Future<void> addCourse({required String title, required String description}) async {
    try {
      await _coursesRef().add({
        'title': title,
        'description': description,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'price': 0, // Default price
        'imageUrl': null, // Default image URL
      });
    } catch (e) {
      developer.log("Error adding course: $e");
      throw Exception('Failed to add course.');
    }
  }

  /// Adds a new subject to a course.
  Future<void> addSubject(
      {required String courseId,
        required String title,
        required String description,
        required int subjectNumber
      }) async {
    try {
      await _coursesRef().doc(courseId).collection('subjects').add({
        'title': title,
        'description': description,
        'subjectNumber': subjectNumber,
      });
    } catch (e) {
      developer.log("Error adding subject: $e");
      throw Exception('Failed to add subject.');
    }
  }

  /// Adds a new chapter to a subject.
  Future<void> addChapter(
      {required String courseId,
        required String subjectId,
        required String title,
        required int    chapterNumber
      }) async {
    try {
      await _coursesRef()
          .doc(courseId)
          .collection('subjects')
          .doc(subjectId)
          .collection('chapters')
          .add({
        'title': title,
        'chapterNumber': chapterNumber
      });
    } catch (e) {
      developer.log("Error adding chapter: $e");
      throw Exception('Failed to add chapter.');
    }
  }

  /// Adds a new video to a chapter.
  Future<void> addVideo(
      {required String courseId,
        required String subjectId,
        required String chapterId,
        required String title,
        required String videoId,
        required String duration,
        required int videoNumber}) async {
    try {
      await _videosRef(
        courseId: courseId, subjectId: subjectId, chapterId: chapterId, )
          .add({
        'title': title,
        'videoId': videoId,
        'duration': duration,
        'videoNumber': videoNumber,
      });
    } catch (e) {
      developer.log("Error adding video: $e");
      throw Exception('Failed to add video.');
    }
  }

  /// Adds a new PDF to a chapter.
  Future<void> addPdf(
      {required String courseId,
        required String subjectId,
        required String chapterId,
        required String title,
        required String url,
        required int pdfNumber
      }) async {
    try {
      await _pdfsRef(
          courseId: courseId, subjectId: subjectId, chapterId: chapterId)
          .add({
        'title': title,
        'url': url,
        'pdfNumber': pdfNumber,
      });
    } catch (e) {
      developer.log("Error adding PDF: $e");
      throw Exception('Failed to add PDF.');
    }
  }

  /// Adds a new question to a specific chapter.
  Future<void> addQuestion(
      {required String courseId,
        required String subjectId,
        required String chapterId,
        required QuestionModel question,
        required int questionNumber
      }) async {
    try {
      await _questionsRef(
          courseId: courseId, subjectId: subjectId, chapterId: chapterId)
          .add(question.toFirestore(
        questionNumber: questionNumber,
      ));
    } catch (e) {
      developer.log("Error adding question: $e");
      throw Exception('Failed to add question.');
    }
  }

  /// Updates an existing course's data.
  Future<void> updateCourse(
      {required String courseId, required Map<String, dynamic> data}) async {
    try {
      await _coursesRef().doc(courseId).update(data);
    } catch (e) {
      developer.log("Error updating course: $e");
      throw Exception('Failed to update course.');
    }
  }

  /// Updates an existing subject's data.
  Future<void> updateSubject(
      {required String courseId,
        required String subjectId,
        required int subjectNumber,
        required Map<String, dynamic> data}) async {
    try {
      final updatedData = Map<String, dynamic>.from(data);
      updatedData['subjectNumber'] = subjectNumber;
      await _coursesRef()
          .doc(courseId)
          .collection('subjects')
          .doc(subjectId)
          .update(updatedData);
    } catch (e) {
      developer.log("Error updating subject: $e");
      throw Exception('Failed to update subject.');
    }
  }

  /// Updates an existing chapter's data.
  Future<void> updateChapter({
    required String courseId,
    required String subjectId,
    required String chapterId,
    required Map<String, dynamic> data, // 💡 Now just one map
  }) async {
    try {
      await _coursesRef()
          .doc(courseId)
          .collection('subjects')
          .doc(subjectId)
          .collection('chapters')
          .doc(chapterId)
          .update(data); // 💡 Use the provided data map directly
    } catch (e) {
      developer.log("Error updating chapter: $e");
      throw Exception('Failed to update chapter.');
    }
  }
  // deferent way to update chapter number
  /* Future<void> updateChapter(
      {required String courseId,
        required String subjectId,
        required String chapterId,
        required int chapterNumber,
        required Map<String, dynamic> data}) async {
    try {
      final updatedData = Map<String, dynamic>.from(data);
      updatedData['chapterNumber'] = chapterNumber;
      await _coursesRef()
          .doc(courseId)
          .collection('subjects')
          .doc(subjectId)
          .collection('chapters')
          .doc(chapterId)
          .update(data);
    } catch (e) {
      developer.log("Error updating chapter: $e");
      throw Exception('Failed to update chapter.');
    }
  }*/

  /// Updates an existing video's data.
  Future<void> updateVideo(
      {required String courseId,
        required String subjectId,
        required String chapterId,
        required String videoId,
        required int videoNumber,
        required Map<String, dynamic> data}) async {
    try {
      final updatedData = Map<String, dynamic>.from(data);
      updatedData['videoNumber'] = videoNumber;
      await _videosRef(
          courseId: courseId, subjectId: subjectId, chapterId: chapterId)
          .doc(videoId)
          .update(updatedData);
    } catch (e) {
      developer.log("Error updating video: $e");
      throw Exception('Failed to update video.');
    }
  }

  /// Updates an existing PDF's data.
  Future<void> updatePdf(
      {required String courseId,
        required String subjectId,
        required String chapterId,
        required String pdfId,
        required Map<String, dynamic> data,

      }) async {
    try {
      await _pdfsRef(
          courseId: courseId, subjectId: subjectId, chapterId: chapterId)
          .doc(pdfId)
          .update(data);
    } catch (e) {
      developer.log("Error updating PDF: $e");
      throw Exception('Failed to update PDF.');
    }
  }
  /// Updates an existing question.
  Future<void> updateQuestion(
      {required String courseId,
        required String subjectId,
        required String chapterId,
        required int questionNumber,
        required QuestionModel question}) async {
    try {
      await _questionsRef(
          courseId: courseId, subjectId: subjectId, chapterId: chapterId)
          .doc(question.id)
          .update(question.toFirestore(questionNumber: questionNumber));
    } catch (e) {
      developer.log("Error updating question: $e");
      throw Exception('Failed to update question.');
    }
  }

  /// Deletes a course document.
  Future<void> deleteCourse({required String courseId}) async {
    try {
      await _coursesRef().doc(courseId).delete();
    } catch (e) {
      developer.log("Error deleting course: $e");
      throw Exception('Failed to delete course.');
    }
  }

  /// Deletes a specific video.
  Future<void> deleteVideo(
      {required String courseId,
        required String subjectId,
        required String chapterId,
        required String videoId}) async {
    try {
      await _videosRef(
          courseId: courseId, subjectId: subjectId, chapterId: chapterId)
          .doc(videoId)
          .delete();
    } catch (e) {
      developer.log("Error deleting video: $e");
      throw Exception('Failed to delete video.');
    }
  }

  /// Deletes a specific PDF.
  Future<void> deletePdf(
      {required String courseId,
        required String subjectId,
        required String chapterId,
        required String pdfId}) async {
    try {
      await _pdfsRef(
          courseId: courseId, subjectId: subjectId, chapterId: chapterId)
          .doc(pdfId)
          .delete();
    } catch (e) {
      developer.log("Error deleting PDF: $e");
      throw Exception('Failed to delete PDF.');
    }
  }

  /// Deletes a specific question.
  Future<void> deleteQuestion(
      {required String courseId,
        required String subjectId,
        required String chapterId,
        required String questionId}) async {
    try {
      await _questionsRef(
          courseId: courseId, subjectId: subjectId, chapterId: chapterId)
          .doc(questionId)
          .delete();
    } catch (e) {
      developer.log("Error deleting question: $e");
      throw Exception('Failed to delete question.');
    }
  }

  /// Deletes a chapter.
  Future<void> deleteChapter(
      {required String courseId,
        required String subjectId,
        required String chapterId}) async {
    try {
      await _coursesRef()
          .doc(courseId)
          .collection('subjects')
          .doc(subjectId)
          .collection('chapters')
          .doc(chapterId)
          .delete();
    } catch (e) {
      developer.log("Error deleting chapter: $e");
      throw Exception('Failed to delete chapter.');
    }
  }

  /// Deletes a subject.
  Future<void> deleteSubject(
      {required String courseId, required String subjectId}) async {
    try {
      await _coursesRef()
          .doc(courseId)
          .collection('subjects')
          .doc(subjectId)
          .delete();
    } catch (e) {
      developer.log("Error deleting subject: $e");
      throw Exception('Failed to delete subject.');
    }
  }
/// Fetches the latest result for a given user & chapter using timestamp ordering.
/// Returns null if no result found.
  Future<ResultModel?> getResultForUserAndChapter({
    required String userId,
    required String chapterId,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('results')
          .where('userId', isEqualTo: userId)
          .where('chapterId', isEqualTo: chapterId)
          .orderBy('timestamp', descending: true) // Order by timestamp
          .limit(1) // Get only the latest result
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null; // No result found
      } else {
        return ResultModel.fromFirestore(querySnapshot.docs.first);
      }
    } catch (e) {
      developer.log("Error fetching result: $e");

      throw Exception('Failed to fetch result.');
    }
  }
  Future<ResultModel?> getPreviousResult({
    required String userId,
    required String chapterId,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('results')
          .where('userId', isEqualTo: userId)
          .where('chapterId', isEqualTo: chapterId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return ResultModel.fromFirestore(querySnapshot.docs.first);
    } catch (e, st) {
      developer.log('Error fetching previous result: $e', error: e, stackTrace: st);
      rethrow;
    }
  }
  /// Submits (creates/overwrites) a result using the canonical doc id.
  /// Uses set(...) to overwrite previous content.
  Future<void> submitResult({required ResultModel result}) async {
    try {
      final resultDocId = '${result.userId}_${result.chapterId}';
      await _firestore.collection('results').doc(resultDocId).set(result.toFirestore());
    } catch (e, st) {
      developer.log('Error submitting result: $e', error: e, stackTrace: st);
      throw Exception('Failed to submit result.');
    }
  }
  /// Updates an existing result document for retests.
  /// If the document doesn't exist, falls back to creating it (upsert).
  Future<void> updateResult({required ResultModel result}) async {
    final resultDocId = '${result.userId}_${result.chapterId}';
    final docRef = _firestore.collection('results').doc(resultDocId);

    try {
      // Try update first (this will fail if doc doesn't exist)
      await docRef.update(result.toFirestore());
    } on FirebaseException catch (firebaseError) {
      // If the document is not found, write it instead (upsert).
      // Other FirebaseExceptions are rethrown.
      if (firebaseError.code == 'not-found' || firebaseError.message?.contains('No document to update') == true) {
        developer.log('Result doc not found when updating; creating new doc instead.', error: firebaseError);
        try {
          await docRef.set(result.toFirestore());
        } catch (setError, st) {
          developer.log('Error setting result after update fallback: $setError', error: setError, stackTrace: st);
          throw Exception('Failed to create result after update fallback.');
        }
      } else {
        developer.log('FirebaseException updating result: $firebaseError', error: firebaseError);
        throw Exception('Failed to update result: ${firebaseError.message}');
      }
    } catch (e, st) {
      developer.log('Error updating result: $e', error: e, stackTrace: st);
      throw Exception('Failed to update result.');
    }
  }


}