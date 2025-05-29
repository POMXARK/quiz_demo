import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/answer.dart';
import '../../models/question.dart';
import 'admin_panel_view_model.dart';

class AdminPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminPanelViewModel()..loadQuestions(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Admin Panel'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Consumer<AdminPanelViewModel>(
            builder: (context, viewModel, child) {
              return Column(
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.add),
                    label: Text('Add Question'),
                    onPressed: () => _showAddEditDialog(context, viewModel),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: Icon(Icons.file_upload),
                    label: Text('Export Questions'),
                    onPressed: () async {
                      await viewModel.exportQuestions();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Questions exported successfully')),
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: Icon(Icons.file_download),
                    label: Text('Import Questions'),
                    onPressed: () async {
                      // Показываем диалог для выбора опции очистки
                      bool? clearExisting = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Import Questions'),
                            content: Text('Do you want to clear existing questions?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: Text('No'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: Text('Yes'),
                              ),
                            ],
                          );
                        },
                      );
                      if (clearExisting != null) {
                        await viewModel.importQuestions(clearExisting: clearExisting);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Questions imported successfully')),
                        );
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: viewModel.questions.isEmpty
                        ? Center(child: Text('No questions added yet'))
                        : ListView.builder(
                      itemCount: viewModel.questions.length,
                      itemBuilder: (context, index) {
                        final question = viewModel.questions[index];
                        return ListTile(
                          title: Text(question.questionText),
                          subtitle: Text(
                            question.answers.map((a) => a.answerText).join(', '),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => _editQuestion(context, viewModel, question, index),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => _confirmDeleteQuestion(context, viewModel, index),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _confirmDeleteQuestion(BuildContext context, AdminPanelViewModel viewModel, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this question?'),
        actions: [
          TextButton(
            onPressed: () {
              viewModel.deleteQuestion(index);
              Navigator.of(context).pop();
            },
            child: Text('Yes'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('No'),
          ),
        ],
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, AdminPanelViewModel viewModel, {Question? questionToEdit, int? editIndex}) {
    final TextEditingController questionController = TextEditingController();
    final TextEditingController answerController = TextEditingController();
    final List<Answer> answers = [];

    if (questionToEdit != null) {
      questionController.text = questionToEdit.questionText;
      answers.addAll(questionToEdit.answers);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            void addAnswer() {
              final text = answerController.text.trim();
              if (text.isNotEmpty) {
                setStateDialog(() {
                  answers.add(Answer(answerText: text));
                  answerController.clear();
                });
              }
            }

            void removeAnswer(int index) {
              setStateDialog(() {
                answers.removeAt(index);
              });
            }

            void toggleCorrect(int index, bool? value) {
              setStateDialog(() {
                answers[index].isCorrect = value ?? false;
              });
            }

            return AlertDialog(
              title: Text(questionToEdit == null ? 'Add Question' : 'Edit Question'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: questionController,
                      decoration: InputDecoration(labelText: 'Question'),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: answerController,
                            decoration: InputDecoration(labelText: 'Answer'),
                            onSubmitted: (_) => addAnswer(),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: addAnswer,
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    if (answers.isEmpty)
                      Text('No answers added yet', style: TextStyle(color: Colors.grey))
                    else
                      Column(
                        children: answers.asMap().entries.map((entry) {
                          final index = entry.key;
                          final answer = entry.value;
                          return ListTile(
                            leading: Checkbox(
                              value: answer.isCorrect,
                              onChanged: (val) => toggleCorrect(index, val),
                            ),
                            title: Text(answer.answerText),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => removeAnswer(index),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final questionText = questionController.text.trim();
                    if (questionText.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Question cannot be empty')),
                      );
                      return;
                    }
                    if (answers.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Add at least one answer')),
                      );
                      return;
                    }
                    // Проверка, что есть хотя бы один правильный ответ
                    if (!answers.any((a) => a.isCorrect)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Mark at least one answer as correct')),
                      );
                      return;
                    }

                    viewModel.addOrUpdateQuestion(questionToEdit, questionText, answers, editIndex);
                    Navigator.of(context).pop();
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _editQuestion(BuildContext context, AdminPanelViewModel viewModel, Question question, int index) {
    _showAddEditDialog(context, viewModel, questionToEdit: question, editIndex: index);
  }
}
