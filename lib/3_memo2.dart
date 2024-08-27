import 'package:flutter/material.dart';
import 'package:intl/intl.dart';  // 날짜 포맷을 위한 intl 패키지

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bulletin Board',
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
  DateTime lastEdited;

  Memo({required this.title, required this.content, required this.lastEdited});
}

class MemoListScreen extends StatefulWidget {
  const MemoListScreen({super.key});

  @override
  _MemoListScreenState createState() => _MemoListScreenState();
}

class _MemoListScreenState extends State<MemoListScreen> {
  List<Memo> done = [];
  List<Memo> ongoing = [];
  List<Memo> toDo = [];

  int? selectedMemoIndex;
  List<Memo>? selectedColumnMemos;

  /// 텍스트 에디터를 위한 2개의 컨트롤러
  TextEditingController? titleController;
  TextEditingController? contentController;

  /// 메모 리스트에 새로운 메모를 추가하는 메서드.
  /// 메모를 추가한 뒤 해당 메모를 선택하도록 설정.
  void _addMemo(List<Memo> memoList) {
    
    setState(() {
      memoList.add(Memo(
        title: '', 
        content: '',
        lastEdited: DateTime.now(),
      ));
      _selectMemo(memoList.length - 1, memoList);
    });
  }

  /// 메모리스트를 선택하면, 텍스트 에디터를 업데이트하는 메서드.
  void _updateControllers(List<Memo> memoList) {
    if (selectedMemoIndex != null) {
      titleController = TextEditingController(text: memoList[selectedMemoIndex!].title);
      contentController = TextEditingController(text: memoList[selectedMemoIndex!].content);
    }
  }

  /// 메모를 삭제하는 메서드. 텍스트 에디터도 초기화된다.
  void _deleteMemo(int index, List<Memo> memoList) {
    setState(() {
      memoList.removeAt(index);
      selectedMemoIndex = null;
      selectedColumnMemos = null;
      titleController = null;
      contentController = null;
    });
  }

  /// 메모를 선택하면, 선택된 메모의 인덱스와 메모 리스트를 업데이트한다.
  void _selectMemo(int index, List<Memo> memoList) {
    setState(() {
      selectedMemoIndex = index;
      selectedColumnMemos = memoList;
      _updateControllers(memoList);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bulletin Board'),
      ),
      body: Row(
        children: [
          _buildMemoColumn('Done', done),
          _buildMemoColumn('Ongoing', ongoing),
          _buildMemoColumn('To do', toDo),
          VerticalDivider(),
          _buildEditorPane(),
        ],
      ),
    );
  }

  // MemoColumn을 빌드하는 메서드로 코드 간소화
  Widget _buildMemoColumn(String title, List<Memo> memos) {
    return MemoColumn(
      title: title,
      memos: memos,
      onDelete: (index) => _deleteMemo(index, memos),
      onSelect: (index) => _selectMemo(index, memos),
      onAdd: () => _addMemo(memos),
    );
  }

  /// 위젯의 오른쪽에 텍스트 에디터를 빌드하는 메서드
  Widget _buildEditorPane() {
    return selectedMemoIndex != null && selectedColumnMemos != null
        ? Expanded(
            flex: 1,  // 메모가 선택된 경우 에디터의 비율
            child: Padding(
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
                    onChanged: (text) {
                      setState(() {
                        selectedColumnMemos![selectedMemoIndex!].title = text;
                        selectedColumnMemos![selectedMemoIndex!].lastEdited = DateTime.now();
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Content',
                        border: OutlineInputBorder(),
                      ),
                      controller: contentController,
                      onChanged: (text) {
                        setState(() {
                          selectedColumnMemos![selectedMemoIndex!].content = text;
                          selectedColumnMemos![selectedMemoIndex!].lastEdited = DateTime.now();
                        });
                      },
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                    ),
                  ),
                ],
              ),
            ),
          )
        : SizedBox.shrink(); // 메모가 선택되지 않은 경우, 에디터를 숨김
  }
}


/// MemoCard 커스텀 위젯
class MemoCard extends StatelessWidget {
  final Memo memo;
  final Function() onDelete;
  final Function() onSelect;

  MemoCard({
    super.key,
    required this.memo,
    required this.onDelete,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),  // 카드의 외부 여백 설정
      elevation: 4,
      child: ListTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              memo.title.isNotEmpty ? memo.title : 'New Memo',
              style: TextStyle(
                fontWeight: memo.title.isNotEmpty ? FontWeight.bold : FontWeight.normal,
                color: memo.title.isNotEmpty ? Colors.black : Colors.grey,
              ),
            ),
            SizedBox(height: 4.0),  // title과 subtitle 사이의 간격
            Text(memo.content),
            SizedBox(height: 8.0),  // subtitle과 날짜/삭제 버튼 사이의 간격
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('yy, MMM d, HH:mm').format(memo.lastEdited),
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: onDelete,
                  iconSize: 20.0,  // 아이콘 크기를 작게 설정
                ),
              ],
            ),
          ],
        ),
        onTap: onSelect,
      ),
    );
  }
}

/// MemoColumn 커스텀 위젯
class MemoColumn extends StatelessWidget {
  final String title;
  final List<Memo> memos;
  final Function(int) onDelete;
  final Function(int) onSelect;
  final VoidCallback onAdd;

  MemoColumn({
    super.key,
    required this.title,
    required this.memos,
    required this.onDelete,
    required this.onSelect,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8.0),  // 외부 여백
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 250, 253),  // 배경색
          borderRadius: BorderRadius.circular(16.0),  // 둥근 모서리 설정
          boxShadow: [
            BoxShadow(
              color: Colors.black26,  // 그림자 색상
              blurRadius: 8.0,  // 그림자의 흐림 정도
              offset: Offset(0, 4),  // 그림자의 위치
            ),
          ],
        ),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true, 
                itemCount: memos.length,
                itemBuilder: (context, index) {
                  return MemoCard(
                    memo: memos[index],
                    onDelete: () => onDelete(index),
                    onSelect: () => onSelect(index),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: onAdd,
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
    );
  }
}