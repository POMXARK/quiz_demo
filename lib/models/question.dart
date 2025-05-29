import 'package:hive/hive.dart';
import 'answer.dart';

part 'question.g.dart';  // Не забудьте добавить эту строку для генерации адаптера Hive

@HiveType(typeId: 1)
class Question {
  @HiveField(0)
  /// Текст вопроса, который будет отображаться пользователю.
  String questionText;

  @HiveField(1)
  /// Список возможных ответов на вопрос.
  /// Каждый ответ представлен объектом класса [Answer].
  List<Answer> answers;

  @HiveField(2)
  /// Количество правильных ответов, которые были даны на этот вопрос.
  /// Используется для вычисления статистики.
  int? correctAnswersCount;

  @HiveField(3)
  /// Общее количество ответов на этот вопрос.
  /// Это значение необходимо для расчета точности ответов.
  int? totalAnswersCount;

  @HiveField(4)
  /// Дата и время последнего ответа на этот вопрос.
  /// Используется для анализа времени, прошедшего с последнего ответа,
  /// и для определения актуальности вопроса.
  DateTime? lastAnswered;

  Question({
    required this.questionText,
    required this.answers,
    this.correctAnswersCount,
    this.totalAnswersCount,
    this.lastAnswered,
  });

  // Геттеры с дефолтами, чтобы не ломать логику
  int get correctCount => correctAnswersCount ?? 0; // Возвращает количество правильных ответов, по умолчанию 0.
  int get totalCount => totalAnswersCount ?? 0; // Возвращает общее количество ответов, по умолчанию 0.
  DateTime get lastAnsweredDate => lastAnswered ?? DateTime.fromMillisecondsSinceEpoch(0); // Возвращает дату последнего ответа, по умолчанию - 0 (начало эпохи).
}
