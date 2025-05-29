import 'package:flutter/material.dart';
import 'package:quiz_demo/models/question.dart';
import '../admin_panel/admin_panel_view_model.dart';

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late Future<List<Question>> futureQuestions; // Объявляем Future для вопросов
  final AdminPanelViewModel viewModel = AdminPanelViewModel();

  @override
  void initState() {
    super.initState();
    futureQuestions = loadQuestions(); // Инициализируем загрузку вопросов
  }

  Future<List<Question>> loadQuestions() async {
    // Загрузите вопросы с использованием метода getQuestionsToStudy()
    return viewModel.getQuestionsToStudy();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Тестирование'),
      ),
      body: FutureBuilder<List<Question>>(
        future: futureQuestions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка загрузки вопросов: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Нет доступных вопросов.'));
          }

          // Если данные загружены
          final questions = snapshot.data!;
          return QuizContent(questions: questions);
        },
      ),
    );
  }
}

class QuizContent extends StatefulWidget {
  final List<Question> questions;

  QuizContent({required this.questions});

  @override
  _QuizContentState createState() => _QuizContentState();
}

class _QuizContentState extends State<QuizContent> {
  int currentQuestionIndex = 0;
  bool showAnswer = false;
  String? selectedOption;

  void nextQuestion() {
    if (currentQuestionIndex < widget.questions.length - 1) {
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
    final currentQuestion = widget.questions[currentQuestionIndex];

    return Padding(
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
    );
  }
}
