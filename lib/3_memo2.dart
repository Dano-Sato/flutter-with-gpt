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
  int? selectedMemoIndex;
  TextEditingController? titleController;
  TextEditingController? contentController;

  void _addMemo() {
    setState(() {
      memos.add(Memo(title: 'New Memo', content: ''));
      selectedMemoIndex = memos.length - 1;
      _updateControllers();
    });
  }

  void _updateControllers() {
    if (selectedMemoIndex != null) {
      titleController = TextEditingController(text: memos[selectedMemoIndex!].title);
      contentController = TextEditingController(text: memos[selectedMemoIndex!].content);
    }
  }

  void _updateMemoTitle(String title) {
    if (selectedMemoIndex != null) {
      setState(() {
        memos[selectedMemoIndex!].title = title;
      });
    }
  }

  void _updateMemoContent(String content) {
    if (selectedMemoIndex != null) {
      setState(() {
        memos[selectedMemoIndex!].content = content;
      });
    }
  }

  void _deleteMemo(int index) {
    setState(() {
      memos.removeAt(index);
      selectedMemoIndex = null;
      titleController = null;
      contentController = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Memo App'),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
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
                          onTap: () {
                            setState(() {
                              selectedMemoIndex = index;
                              _updateControllers();
                            });
                          },
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteMemo(index),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    onPressed: _addMemo,
                    icon: Icon(Icons.add),
                    label: Text("Add Memo"),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          VerticalDivider(), // 구분선 추가
          Expanded(
            flex: 3,
            child: selectedMemoIndex != null
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Title',
                            border: OutlineInputBorder(),
                          ),
                          controller: titleController,
                          onChanged: _updateMemoTitle,
                        ),
                        SizedBox(height: 16),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Content',
                              border: OutlineInputBorder(),
                            ),
                            controller: contentController,
                            onChanged: _updateMemoContent,
                            maxLines: null,
                            expands: true,
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(child: Text('Select a memo to edit')),
          ),
        ],
      ),
    );
  }
}
