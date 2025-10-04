// lib/data/models/result_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';


class ResultModel extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String chapterId;
  final int totalQuestions;
  final int correctAnswers;
  final List<Map<String, dynamic>> answers;

  const ResultModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.chapterId,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.answers,
  });

  ResultModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? chapterId,
    int? totalQuestions,
    int? correctAnswers,
    List<Map<String, dynamic>>? answers,
  }) {
    return ResultModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      chapterId: chapterId ?? this.chapterId,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      answers: answers ?? this.answers,
    );
  }

  factory ResultModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) throw Exception("Result data is null.");
    return ResultModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      chapterId: data['chapterId'] ?? '',
      totalQuestions: data['totalQuestions'] ?? 0,
      correctAnswers: data['correctAnswers'] ?? 0,
      answers: List<Map<String, dynamic>>.from(data['answers'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'chapterId': chapterId,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'answers': answers,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    userName,
    chapterId,
    totalQuestions,
    correctAnswers,
    answers,
  ];
}