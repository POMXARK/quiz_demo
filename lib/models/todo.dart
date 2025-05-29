import 'package:hive/hive.dart';

part 'todo.g.dart';  // Эта строка должна быть

@HiveType(typeId: 0)
class Todo extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  bool complete;

  @HiveField(2)
  String note;

  @HiveField(3)
  String task;

  Todo({
    required this.id,
    this.complete = false,
    this.note = '',
    required this.task,
  });
}
