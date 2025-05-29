import 'package:hive/hive.dart';

import 'answer.dart';

part 'question.g.dart';  // Не забудьте добавить эту строку

@HiveType(typeId: 1)
class Question {
  @HiveField(0)
  String questionText;

  @HiveField(1)
  List<Answer> answers;

  Question({required this.questionText, required this.answers});
}
