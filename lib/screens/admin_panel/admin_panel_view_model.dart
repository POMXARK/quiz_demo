import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../models/answer.dart';
import '../../models/question.dart';

class AdminPanelViewModel extends ChangeNotifier {
  List<Question> _questions = [];

  List<Question> get questions => _questions;

  void loadQuestions() {
    final box = Hive.box<Question>('questions');
    _questions = box.values.toList();
    notifyListeners();
  }

  void deleteQuestion(int index) {
    final box = Hive.box<Question>('questions');
    box.deleteAt(index);
    loadQuestions();
  }

  void addOrUpdateQuestion(Question? questionToEdit, String questionText, List<Answer> answers, int? editIndex) {
    final box = Hive.box<Question>('questions');
    if (questionToEdit != null && editIndex != null) {
      // Редактируем существующий вопрос
      questionToEdit.questionText = questionText;
      questionToEdit.answers = answers;
      box.putAt(editIndex, questionToEdit);
    } else {
      // Добавляем новый вопрос
      final newQuestion = Question(
        questionText: questionText,
        answers: answers,
      );
      box.add(newQuestion);
    }
    loadQuestions();
  }
}
