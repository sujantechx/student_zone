// lib/data/models/video_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

// Represents a single video document from the 'videos' sub-collection.
class VideoModel {
  final String id;
  final String title;
  final String duration;
  final String videoId; // The YouTube video ID
  final int? videoNumber; // Make this field nullable

  VideoModel({
    required this.id,
    required this.title,
    required this.duration,
    required this.videoId,
    this.videoNumber, // Make this parameter optional
  });

  // Factory to create a VideoModel from a Firestore document snapshot.
  factory VideoModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VideoModel(
      id: doc.id,
      title: data['title'] ?? 'No Title',
      duration: data['duration'] ?? '00:00',
      videoId: data['videoId'] ?? '',
      // Do not use a default value. Let it be null if not present.
      videoNumber: data['videoNumber'] as int?,
    );
  }
}