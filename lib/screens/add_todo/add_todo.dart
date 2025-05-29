import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../models/todo.dart';
import '../../client/hive_names.dart';

class AddTodo extends StatefulWidget {
  final formKey = GlobalKey<FormState>();

  AddTodo({super.key});

  @override
  _AddTodoState createState() => _AddTodoState();
}

class _AddTodoState extends State<AddTodo> {
  late String task;
  late String note;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    autofocus: true,
                    initialValue: '',
                    decoration: const InputDecoration(
                      labelText: 'Task',
                    ),
                    onChanged: (value) {
                      setState(() {
                        task = value;
                      });
                    },
                    validator: (val) {
                      if (val!.trim().isEmpty) {
                        return 'Task name should not be empty';
                      } else {
                        return null;
                      }
                    },
                  ),
                  TextFormField(
                    initialValue: '',
                    decoration: const InputDecoration(
                      labelText: 'Note',
                    ),
                    onChanged: (value) {
                      setState(() {
                        note = value ?? '';
                      });
                    },
                  ),
                  OutlinedButton(
                    onPressed: _validateAndSave,
                    child: Text('Add'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _validateAndSave() {
    final form = _formKey.currentState;
    if (form!.validate()) {
      _onFormSubmit();
    } else {
      if (kDebugMode) {
        print('form is invalid');
      }
    }
  }

  void _onFormSubmit() {
    Box<Todo> contactsBox = Hive.box<Todo>(HiveBoxes.todo);
    contactsBox.add(Todo(task: task, note: note, id: ''));
    Navigator.of(context).pop();
  }
}