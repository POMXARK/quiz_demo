import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/answer.dart';
import '../../models/question.dart';

class QuestionWithKey {
  final dynamic key; // Hive ключ может быть int или String
  final Question question;

  QuestionWithKey(this.key, this.question);
}

class AdminPanelViewModel extends ChangeNotifier {
  List<QuestionWithKey> _questionsWithKeys = [];

  List<Question> get questions => _questionsWithKeys.map((e) => e.question).toList();

  void loadQuestions() {
    final box = Hive.box<Question>('questions');
    _questionsWithKeys = box.keys.map((key) {
      final q = box.get(key)!;
      return QuestionWithKey(key, q);
    }).toList();
    print("Loaded questions: ${_questionsWithKeys.length}"); // Отладочное сообщение
    notifyListeners();
  }

  void deleteQuestion(int index) {
    final box = Hive.box<Question>('questions');
    final key = _questionsWithKeys[index].key;
    box.delete(key);
    loadQuestions();
  }

  void addOrUpdateQuestion(Question? questionToEdit, String questionText, List<Answer> answers, int? editIndex) {
    final box = Hive.box<Question>('questions');
    if (questionToEdit != null && editIndex != null) {
      // Редактируем существующий вопрос
      final key = _questionsWithKeys[editIndex].key;
      questionToEdit.questionText = questionText;
      questionToEdit.answers = answers;
      box.put(key, questionToEdit);
    } else {
      // Добавляем новый вопрос
      final newQuestion = Question(
        questionText: questionText,
        answers: answers,
        // Можно задать значения по умолчанию, если конструктор требует
        correctAnswersCount: 0,
        totalAnswersCount: 0,
        lastAnswered: DateTime.fromMillisecondsSinceEpoch(0),
      );
      box.add(newQuestion);
      print("Question added: ${newQuestion.questionText}"); // Отладочное сообщение
    }
    loadQuestions();
  }

  List<Question> getQuestionsToStudy() {
    // Сначала загружаем вопросы из Hive
    loadQuestions(); // Загружаем вопросы

    final now = DateTime.now();

    // Добавьте отладочное сообщение
    print("Получение вопросов для изучения...");

    double score(Question q) {
      final total = q.totalAnswersCount ?? 0;
      if (total == 0) {
        return double.infinity; // Если нет ответов, возвращаем бесконечность
      }
      final lastAnswered = q.lastAnswered ?? DateTime.fromMillisecondsSinceEpoch(0);
      final hoursSinceLast = now.difference(lastAnswered).inMinutes / 60.0;
      final correct = q.correctAnswersCount ?? 0;
      final accuracy = correct / total; // Вычисляем точность
      return (1 - accuracy) * 100 + hoursSinceLast; // Алгоритм забывания
    }

    final questionsCopy = _questionsWithKeys.map((e) => e.question).toList();

    // Выводим количество вопросов
    print("Количество вопросов: ${questionsCopy.length}");

    // Сортируем вопросы на основе их оценок
    questionsCopy.sort((a, b) {
      final scoreA = score(a);
      final scoreB = score(b);
      return scoreB.compareTo(scoreA); // Сортируем по убыванию
    });

    return questionsCopy; // Возвращаем отсортированные вопросы
  }

  void updateQuestionProgress(Question question) {
    final box = Hive.box<Question>('questions');
    // Найдем ключ по вопросу
    final pair = _questionsWithKeys.firstWhere((element) => element.question == question);

    question.totalAnswersCount = (question.totalAnswersCount ?? 0) + 1;

    if ((question.correctAnswersCount ?? 0) < (question.totalAnswersCount ?? 0)) {
      question.correctAnswersCount = (question.correctAnswersCount ?? 0) + 1;
    }

    question.lastAnswered = DateTime.now();
    box.put(pair.key, question);
    notifyListeners();
  }

  Future<void> exportQuestions() async {
    final box = Hive.box<Question>('questions');
    final questions = box.values.toList();

    // Создаем список вопросов в формате JSON
    final jsonQuestions = questions.map((q) {
      return {
        'questionText': q.questionText,
        'answers': q.answers.map((a) => {
          'answerText': a.answerText,
          'isCorrect': a.isCorrect,
        }).toList(),
        // Добавляем поля для экспорта
        'correctAnswersCount': q.correctAnswersCount,
        'totalAnswersCount': q.totalAnswersCount,
        'lastAnswered': q.lastAnswered?.toIso8601String(),
      };
    }).toList();

    // Получаем путь для сохранения файла
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/questions_export.json');

    // Записываем данные в файл
    await file.writeAsString(jsonEncode(jsonQuestions));
    print("Questions exported to ${file.path}");
  }

  Future<void> importQuestions({bool clearExisting = false}) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/questions_export.json');

    if (!await file.exists()) {
      print("Import file not found");
      return;
    }

    final jsonString = await file.readAsString();
    final List<dynamic> jsonQuestions = jsonDecode(jsonString);

    final box = Hive.box<Question>('questions');

    if (clearExisting) {
      await box.clear(); // Очистить существующие вопросы, если указано
    }

    for (var jsonQuestion in jsonQuestions) {
      final question = Question(
        questionText: jsonQuestion['questionText'],
        answers: (jsonQuestion['answers'] as List).map((a) {
          return Answer(
            answerText: a['answerText'],
            isCorrect: a['isCorrect'],
          );
        }).toList(),
        correctAnswersCount: jsonQuestion['correctAnswersCount'],
        totalAnswersCount: jsonQuestion['totalAnswersCount'],
        lastAnswered: jsonQuestion['lastAnswered'] != null
            ? DateTime.parse(jsonQuestion['lastAnswered'])
            : null,
      );
      await box.add(question);
    }

    loadQuestions(); // Обновляем список вопросов после импорта
    print("Questions imported from ${file.path}");
  }
}
