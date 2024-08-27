import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Routina',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MemoListScreen(),
    );
  }
}

class MemoListScreen extends StatefulWidget {
  const MemoListScreen({super.key});

  @override
  _MemoListScreenState createState() => _MemoListScreenState();
}

class _MemoListScreenState extends State<MemoListScreen> {
  List<String> routines = [];
  List<String> done = [];
  List<String> ongoing = [];
  List<String> toDo = [];

  // 현재 선택된 리스트의 인덱스
  int _selectedListIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadMemos();
  }

  Future<void> _loadMemos() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      routines = prefs.getStringList('routines') ?? [];
      done = prefs.getStringList('done') ?? [];
      ongoing = prefs.getStringList('ongoing') ?? [];
      toDo = prefs.getStringList('toDo') ?? [];
    });
  }

  Future<void> _saveMemos() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('routines', routines);
    prefs.setStringList('done', done);
    prefs.setStringList('ongoing', ongoing);
    prefs.setStringList('toDo', toDo);
  }

  void _addMemo(String memo, List<String> targetList) {
    setState(() {
      targetList.add(memo);
      _saveMemos();
    });
  }

  void _deleteMemo(int index, List<String> targetList) {
    setState(() {
      targetList.removeAt(index);
      _saveMemos();
    });
  }

  void _editMemo(int index, String newMemo, List<String> targetList) {
    setState(() {
      targetList[index] = newMemo;
      _saveMemos();
    });
  }

  Future<void> _showAddMemoDialog(List<String> targetList) async {
    String newMemo = '';
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add a new memo'),
          content: TextField(
            onChanged: (value) {
              newMemo = value;
            },
            decoration: InputDecoration(hintText: "Enter memo here"),
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
                if (newMemo.isNotEmpty) {
                  _addMemo(newMemo, targetList);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditMemoDialog(int index, List<String> targetList) async {
    String editedMemo = targetList[index];
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit memo'),
          content: TextField(
            controller: TextEditingController(text: editedMemo),
            onChanged: (value) {
              editedMemo = value;
            },
            decoration: InputDecoration(hintText: "Enter memo here"),
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
                if (editedMemo.isNotEmpty) {
                  _editMemo(index, editedMemo, targetList);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _onListSelected(int index) {
    setState(() {
      _selectedListIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
  preferredSize: Size.fromHeight(80.0),  // AppBar의 높이를 늘림
  child: AppBar(
    centerTitle: true,
    title: Text(
      'Routina',
      style: TextStyle(
        fontSize: 30, 
        fontWeight: FontWeight.bold,
        fontFamily: 'Arial',  // 원하는 폰트로 변경
      ),
    ),
    flexibleSpace: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color.fromARGB(255, 245, 241, 207), const Color.fromARGB(255, 255, 254, 250)], // 그라데이션 색상
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
    ),
    elevation: 10,
    shadowColor: Colors.grey.withOpacity(0.5),
    actions: <Widget>[
      IconButton(
        icon: Icon(Icons.search),
        onPressed: () {
          // 검색 버튼 클릭시 수행할 작업
        },
      ),
      IconButton(
        icon: Icon(Icons.settings),
        onPressed: () {
          // 설정 버튼 클릭시 수행할 작업
        },
      ),
    ],
  ),
),
      body: Column(
        children: [ SizedBox(height: 50),
      Expanded(
        child: Row(
          children: [
            _buildMemoSection('Routines', routines, 0),
            SizedBox(width: 20),
            _buildMemoSection('Done', done, 1),
            SizedBox(width: 20),            
            _buildMemoSection('Ongoing', ongoing, 2),
            SizedBox(width: 20),
            _buildMemoSection('To Do', toDo, 3),
          ],
        ),
      ),
      ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMemoDialog(_getCurrentList()),
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildMemoSection(String title, List<String> memos, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onListSelected(index),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: _selectedListIndex == index ? Colors.blue.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(15), // 둥근 모서리 적용
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // 그림자 위치 조정
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _selectedListIndex == index ? Colors.blue : Colors.black,
                  ),
                ),
              ),
              Expanded(
                flex: _selectedListIndex == index ? 3 : 1,
                child: ListView.builder(
                  itemCount: memos.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      elevation: 4,
                      child: ListTile(
                        title: Text(memos[index]),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _showEditMemoDialog(index, memos),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deleteMemo(index, memos),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _getCurrentList() {
    switch (_selectedListIndex) {
      case 0:
        return routines;
      case 1:
        return done;
      case 2:
        return ongoing;
      case 3:
        return toDo;
      default:
        return [];
    }
  }
}
