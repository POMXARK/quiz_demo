import 'package:hive/hive.dart';

part 'answer.g.dart';  // Не забудьте добавить эту строку

@HiveType(typeId: 2)
class Answer {
  @HiveField(0)
  String answerText;

  @HiveField(1)
  bool isCorrect;

  Answer({required this.answerText, this.isCorrect = false});
}