import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/question_model.dart';
import '../../../data/models/result_model.dart';
import '../../../logic/test/quiz_cubit.dart';

class QuizResultScreen extends StatelessWidget {
  final ResultModel result;
  final List<QuestionModel> questions;
  final String courseId;
  final String subjectId;
  final String chapterId;

  const QuizResultScreen({
    Key? key,
    required this.result,
    required this.questions,
    required this.courseId,
    required this.subjectId,
    required this.chapterId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Test Results")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🟢 Score Summary
            Card(
              color: Colors.green.withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Text(
                      'Your Score ',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${result.correctAnswers} / ${result.totalQuestions}',
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Answer Review',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(thickness: 1.2),

            // 🧠 List of Questions
            ...result.answers.asMap().entries.map((entry) {
              final answer = entry.value;
              final question = questions.firstWhere(
                    (q) => q.id == answer['questionId'],
                orElse: () => throw Exception('Question not found for ID: ${answer['questionId']}'),
              );

              final userAnswerIndex = answer['userAnswer'] as int?;
              final correctAnswerIndex = answer['correctAnswer'] as int?;
              final isCorrect = userAnswerIndex == correctAnswerIndex;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question Text or Image
                      if (question.type == 'image' && question.imageUrl != null)
                        Image.network(question.imageUrl!),
                      if (question.text != null) ...[
                        Text(
                          question.text!,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // 🟨 Show all options
                      Column(
                        children: question.options.asMap().entries.map((opt) {
                          final optIndex = opt.key;
                          final optText = opt.value;

                          // Decide the background color for each option
                          Color? bgColor;
                          Color? borderColor;
                          Color textColor = Colors.black87;

                          if (optIndex == correctAnswerIndex) {
                            // ✅ Correct answer — always green
                            bgColor = Colors.green.withOpacity(0.15);
                            borderColor = Colors.green;
                            textColor = Colors.green.shade900;
                          }

                          if (userAnswerIndex == optIndex && userAnswerIndex != correctAnswerIndex) {
                            // ❌ Wrong answer user chose — red
                            bgColor = Colors.red.withOpacity(0.15);
                            borderColor = Colors.red;
                            textColor = Colors.red.shade900;
                          }

                          // Option tile
                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: bgColor ?? Colors.grey.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: borderColor ?? Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  optIndex == correctAnswerIndex
                                      ? Icons.check_circle
                                      : optIndex == userAnswerIndex
                                      ? Icons.cancel
                                      : Icons.circle_outlined,
                                  color: optIndex == correctAnswerIndex
                                      ? Colors.green
                                      : optIndex == userAnswerIndex
                                      ? Colors.red
                                      : Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    optText,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 20),

            // 🧩 Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<QuizCubit>().retest();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retake Test'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final shouldFinish = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Finish Test?'),
                          content: const Text(
                            'Once you finish, you cannot retake this test for this chapter.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Finish'),
                            ),
                          ],
                        ),
                      );

                      if (shouldFinish == true) {
                        context.pop();
                      }
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Finish'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }
}
