import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// 데스크톱 환경에서 실행해야 File I/O가 정상 기능합니다.
/// 크롬으로 실행하면 안됩니다. (Flutter Web은 Local File I/O를 지원하지 않습니다.)
/// To-Do를 json 파일로 자동 저장하고 불러오는 To-Do List 앱.
/// 문서 폴더에 저장됩니다. todo.json 파일을 찾아보세요.
void main() {
  runApp(MyApp());
}

Future<void> saveJsonToFile(String jsonString, String fileName) async {
  try {
    // 1. 데이터 저장 경로 가져오기
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File('$path/$fileName');

    // 2. 파일에 JSON 문자열 저장
    await file.writeAsString(jsonString);

    debugPrint('JSON data saved to $path/$fileName');
  } catch (e) {
    debugPrint('Failed to save JSON data: $e');
  }
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
  ToDoListScreenState createState() => ToDoListScreenState();
}

class ToDoListScreenState extends State<ToDoListScreen> {
  final List<String> _toDoItems = [];
  final TextEditingController _controller = TextEditingController();
  final String jsonFileName = 'todo.json';


Future<void> _loadJson() async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File('$path/$jsonFileName');
    if (await file.exists()) {
      final jsonString = await file.readAsString();
      debugPrint('Loaded JSON data: $jsonString');
      final List<dynamic> json = jsonDecode(jsonString);
      setState(() {
        _toDoItems.clear();
        _toDoItems.addAll(json.cast<String>());
      });
    }
  } catch (e) {
    debugPrint('Error loading JSON file: $e');
  }
}

  void _saveJson() {
    final jsonString = jsonEncode(_toDoItems);
    saveJsonToFile(jsonString, jsonFileName).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('To-Do list saved to file'),
        ),
      );
    }).catchError((error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to save To-Do list: $error'),
      ),
    );
  });
  }

  void _addToDoItem(String task) {
    if (task.isNotEmpty) {
      setState(() {
        _toDoItems.add(task);
        _saveJson();
      });
      _controller.clear();
    }
  }

  void _removeToDoItem(int index) {
    setState(() {
      _toDoItems.removeAt(index);
      _saveJson();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadJson();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(80.0), // AppBar의 높이 조정
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 239, 233, 214),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30.0), // 둥근 모서리 설정
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: Offset(0, 4), // 그림자 위치
                ),
              ],
            ),
            child: Center(
              child: AppBar(
                title: Text('Flutter To-Do List by ChatGPT'),
                backgroundColor: Colors.transparent, // 투명하게 설정하여 Container의 색을 사용
                elevation: 0, // 그림자 제거 (Container의 그림자를 사용)
                centerTitle: true,
              ),
            ),
          ),
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
                      _saveJson();
                    });
                  },
                  children: [
                    for (int index = 0; index < _toDoItems.length; index++)
                      ReorderableDragStartListener(
                        key: ValueKey(_toDoItems[index]), // 각 항목에 고유한 키를 부여
                        index: index,
                        child: Card(
                          child: ListTile(
                            title: Row(
                              children: [
                                Icon(Icons.circle,size:10.0),
                                SizedBox(width: 20.0),
                                Text(_toDoItems[index]),
                              ],
                            ),
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
