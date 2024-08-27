import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MemoListScreen(),
    );
  }
}

class Memo {
  String title;
  String content;

  Memo({required this.title, required this.content});
}

class MemoListScreen extends StatefulWidget {
  const MemoListScreen({super.key});

  @override
  _MemoListScreenState createState() => _MemoListScreenState();
}

class _MemoListScreenState extends State<MemoListScreen> {
  List<Memo> memos = [];

  void _addMemo(String title, String content) {
    setState(() {
      memos.add(Memo(title: title, content: content));
    });
  }

  void _editMemo(int index, String newTitle, String newContent) {
    setState(() {
      memos[index].title = newTitle;
      memos[index].content = newContent;
    });
  }

  void _deleteMemo(int index) {
    setState(() {
      memos.removeAt(index);
    });
  }

  Future<void> _showAddMemoDialog() async {
    String title = '';
    String content = '';
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add a new memo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                onChanged: (value) {
                  title = value;
                },
                decoration: InputDecoration(hintText: "Enter title here"),
              ),
              TextField(
                onChanged: (value) {
                  content = value;
                },
                decoration: InputDecoration(hintText: "Enter content here"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                if (title.isNotEmpty && content.isNotEmpty) {
                  _addMemo(title, content);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditMemoDialog(int index) async {
    String editedTitle = memos[index].title;
    String editedContent = memos[index].content;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit memo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: TextEditingController(text: editedTitle),
                onChanged: (value) {
                  editedTitle = value;
                },
                decoration: InputDecoration(hintText: "Enter title here"),
              ),
              TextField(
                controller: TextEditingController(text: editedContent),
                onChanged: (value) {
                  editedContent = value;
                },
                decoration: InputDecoration(hintText: "Enter content here"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                if (editedTitle.isNotEmpty && editedContent.isNotEmpty) {
                  _editMemo(index, editedTitle, editedContent);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
 return Scaffold(
    appBar: AppBar(
      title: Text('Memo App'),
    ),
    body: Column(
      children: [
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: memos.length,
            itemBuilder: (context, index) {
              return Card(
                margin: EdgeInsets.all(8.0),
                elevation: 4,
                child: ListTile(
                  title: Text(memos[index].title),
                  subtitle: Text(memos[index].content),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _showEditMemoDialog(index),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteMemo(index),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FloatingActionButton(
            onPressed: _showAddMemoDialog,
            child: Icon(Icons.add),
          ),
        ),
      ],
    ),
  );}
}
