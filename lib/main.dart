import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:quiz_demo/screens/add_todo/add_todo.dart';
import 'models/todo.dart';
import 'client/hive_names.dart';

void main() async {
  //   hive initialization
  await Hive.initFlutter();
  Hive.registerAdapter(TodoAdapter());
  await Hive.openBox<Todo>(HiveBoxes.todo);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() async {
    Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Todo Hive Example', key: UniqueKey()),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({required Key key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Todo>(HiveBoxes.todo).listenable(),
        builder: (context, Box<Todo> box, _) {
          if (box.values.isEmpty) {
            return Center(
              child: Text("Todo list is empty"),
            );
          }
          return ListView.builder(
            itemCount: box.values.length,
            itemBuilder: (context, index) {
              Todo? res = box.getAt(index);
              return Dismissible(
                background: Container(color: Colors.red),
                key: UniqueKey(),
                onDismissed: (direction) {
                  res.delete();
                },
                child: ListTile(
                    title: Text(res?.task ?? ''),
                    subtitle: Text(res?.note ?? ''),
                    leading: res!.complete
                        ? Icon(Icons.check_box)
                        : Icon(Icons.check_box_outline_blank),
                    onTap: () {
                      res.complete = !res.complete;
                      res.save();
                    }),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => AddTodo())),
        tooltip: 'Add todo',
        child: Icon(Icons.add),
      ),
    );
  }
}