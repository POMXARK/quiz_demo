import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:quiz_demo/models/question.dart';
import 'package:quiz_demo/models/answer.dart';

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> questions = [];
  int currentQuestionIndex = 0;
  bool showAnswer = false;
  String? selectedOption;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    final box = Hive.box<Question>('questions');
    setState(() {
      questions = box.values.toList();
    });
  }

  void nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        showAnswer = false;
        selectedOption = null;
      });
    } else {
      Navigator.pop(context); // Возврат на главный экран после последнего вопроса
    }
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Тестирование'),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentQuestion = questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Тестирование'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              currentQuestion.questionText,
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ...currentQuestion.answers.map((answer) {
              final isSelected = selectedOption == answer.answerText;
              Color? buttonColor;

              if (showAnswer) {
                if (answer.isCorrect) {
                  buttonColor = Colors.green;
                } else if (isSelected && !answer.isCorrect) {
                  buttonColor = Colors.red;
                } else {
                  buttonColor = Colors.grey.shade300;
                }
              } else {
                buttonColor = isSelected ? Colors.blueAccent : Colors.blue;
              }

              return Container(
                margin: EdgeInsets.symmetric(vertical: 5),
                child: ElevatedButton(
                  onPressed: showAnswer
                      ? null
                      : () {
                    setState(() {
                      selectedOption = answer.answerText;
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(buttonColor),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(answer.answerText),
                  ),
                ),
              );
            }).toList(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: selectedOption == null
                  ? null
                  : () {
                if (!showAnswer) {
                  setState(() {
                    showAnswer = true;
                  });
                } else {
                  nextQuestion();
                }
              },
              child: Text(showAnswer ? 'Продолжить' : 'Показать ответ'),
            ),
          ],
        ),
      ),
    );
  }
}
