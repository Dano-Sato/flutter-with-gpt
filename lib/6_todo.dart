import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter To-Do List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ToDoListScreen(),
    );
  }
}

class ToDoListScreen extends StatefulWidget {
  const ToDoListScreen({super.key});

  @override
  _ToDoListScreenState createState() => _ToDoListScreenState();
}

class _ToDoListScreenState extends State<ToDoListScreen> {
  final List<String> _toDoItems = [];
  final TextEditingController _controller = TextEditingController();

  void _addToDoItem(String task) {
    if (task.isNotEmpty) {
      setState(() {
        _toDoItems.add(task);
      });
      _controller.clear();
    }
  }

  void _removeToDoItem(int index) {
    setState(() {
      _toDoItems.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter To-Do List'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Enter a task',
                    ),
                    onSubmitted: _addToDoItem,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => _addToDoItem(_controller.text),
                ),
              ],
            ),
          ),
          Expanded(
            child: _toDoItems.isEmpty
                ? Center(child: Text('No tasks added'))
                : ReorderableListView(
                  buildDefaultDragHandles: false,
                  onReorder: (int oldIndex, int newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }
                      final item = _toDoItems.removeAt(oldIndex);
                      _toDoItems.insert(newIndex, item);
                    });
                  },
                  children: [
                    for (int index = 0; index < _toDoItems.length; index++)
                      ReorderableDragStartListener(
                        key: ValueKey(_toDoItems[index]), // 각 항목에 고유한 키를 부여
                        index: index,
                        child: Card(
                          child: ListTile(
                            title: Text(_toDoItems[index]),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _removeToDoItem(index),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

          ),
        ],
      ),
    );
  }
}
