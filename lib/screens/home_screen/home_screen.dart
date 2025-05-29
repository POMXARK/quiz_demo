import 'package:flutter/material.dart';

import '../admin_panel/admin_panel.dart';
import '../quiz_screen/quiz_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Главный экран'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Переход на админ-панель
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminPanel()),
                );
              },
              child: Text('Изменить викторину'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Переход на экран тестирования
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QuizScreen()),
                );
              },
              child: Text('Начать тестирование'),
            ),
          ],
        ),
      ),
    );
  }
}