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
      title: 'Memo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MemoListScreen(),
    );
  }
}

class Memo {
  String title;    // 메모의 제목을 저장하는 변수
  String content;  // 메모의 내용을 저장하는 변수
  DateTime lastEdited;  // 마지막으로 편집된 시간을 저장하는 변수

  Memo({
    required this.title,
    required this.content,
    required this.lastEdited,
  });
}

class MemoListScreen extends StatefulWidget {
  const MemoListScreen({super.key});

  @override
  _MemoListScreenState createState() => _MemoListScreenState();
}

class _MemoListScreenState extends State<MemoListScreen> {
  List<Memo> memos = [];                // 메모 목록을 저장하는 리스트
  int? selectedMemoIndex;               // 현재 선택된 메모의 인덱스를 저장하는 변수
  TextEditingController? titleController;    // 제목을 제어하는 TextEditingController
  TextEditingController? contentController;  // 내용을 제어하는 TextEditingController

  // 새 메모를 추가하는 함수
  void _addMemo() {
    setState(() {
      memos.add(Memo(
        title: '', 
        content: '',
        lastEdited: DateTime.now(),  // 새 메모의 마지막 편집 시간을 현재 시간으로 설정
      ));  
      selectedMemoIndex = memos.length - 1;  // 새 메모를 선택된 메모로 설정
      _updateControllers();  // TextEditingController 업데이트
    });
  }

  // TextEditingController를 현재 선택된 메모의 값으로 업데이트하는 함수
  void _updateControllers() {
    if (selectedMemoIndex != null) {
      titleController = TextEditingController(text: memos[selectedMemoIndex!].title);
      contentController = TextEditingController(text: memos[selectedMemoIndex!].content);
    }
  }

  // 메모의 제목을 업데이트하는 함수
  void _updateMemoTitle(String title) {
    if (selectedMemoIndex != null) {
      setState(() {
        memos[selectedMemoIndex!].title = title;  // 선택된 메모의 제목을 업데이트
        memos[selectedMemoIndex!].lastEdited = DateTime.now();  // 마지막 편집 시간 업데이트
      });
    }
  }

  // 메모의 내용을 업데이트하는 함수
  void _updateMemoContent(String content) {
    if (selectedMemoIndex != null) {
      setState(() {
        memos[selectedMemoIndex!].content = content;  // 선택된 메모의 내용을 업데이트
        memos[selectedMemoIndex!].lastEdited = DateTime.now();  // 마지막 편집 시간 업데이트
      });
    }
  }

  // 메모를 삭제하는 함수
  void _deleteMemo(int index) {
    setState(() {
      memos.removeAt(index);  // 메모를 목록에서 삭제
      selectedMemoIndex = null;  // 선택된 메모를 초기화
      titleController = null;  // 제목 컨트롤러 초기화
      contentController = null;  // 내용 컨트롤러 초기화
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Memo App'),  // 앱의 제목을 표시
      ),
      body: Row(
        children: [
          // 메모 리스트를 표시하는 왼쪽 영역
          Expanded(
            flex: 2,  // 왼쪽 영역의 비율을 설정
            child: Column(
              children: [
                // 메모 리스트를 표시하는 ListView.builder
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,  // 리스트가 필요한 만큼만 공간을 차지하도록 설정
                    itemCount: memos.length,  // 메모의 개수를 설정
                    itemBuilder: (context, index) {
                      return Card(
                        margin: EdgeInsets.all(8.0),  // 카드의 외부 여백 설정
                        elevation: 4,  // 카드의 그림자 깊이 설정
                        child: ListTile(
                          title: Text(memos[index].title.isNotEmpty ? memos[index].title : 'New Memo',
                          style: TextStyle(
                            fontWeight: memos[index].title.isNotEmpty ? FontWeight.bold : FontWeight.normal, // 제목의 글씨체를 굵게 설정
                            color: memos[index].title.isNotEmpty ? Colors.black : Colors.grey,  // 힌트 텍스트의 색상 설정
                          )
                          ),  // 메모의 제목을 표시
                          subtitle: Text(memos[index].content),  // 메모의 내용을 표시
                          onTap: () {
                            setState(() {
                              selectedMemoIndex = index;  // 선택된 메모의 인덱스 설정
                              _updateControllers();  // TextEditingController 업데이트
                            });
                          },
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,  // Row가 필요한 만큼의 최소 크기를 가집니다.
                            children: [
                              Text(
                                DateFormat('yy, MMM d, HH:mm').format(memos[index].lastEdited),  // 마지막 편집 시간을 표시
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              SizedBox(width: 8.0),  // 텍스트와 아이콘 사이의 간격
                              IconButton(
                                icon: Icon(Icons.delete),  // 삭제 버튼 아이콘
                                onPressed: () => _deleteMemo(index),  // 삭제 함수 호출
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // 메모를 추가하는 버튼
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    onPressed: _addMemo,  // 메모 추가 함수 호출
                    icon: Icon(Icons.add),  // 아이콘 설정
                    label: Text("Add Memo"),  // 버튼의 텍스트 설정
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),  // 버튼 내부 여백 설정
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),  // 버튼의 모서리를 둥글게 설정
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          VerticalDivider(),  // 왼쪽과 오른쪽 영역을 구분하는 구분선
          // 메모 내용을 편집하는 오른쪽 영역
          Expanded(
            flex: 3,  // 오른쪽 영역의 비율을 설정
            child: selectedMemoIndex != null
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 메모의 제목을 입력하는 TextField
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Title',  // 라벨 텍스트 설정
                            border: OutlineInputBorder(),  // 테두리 스타일 설정
                          ),
                          controller: titleController,  // 제목 컨트롤러 설정
                          onChanged: _updateMemoTitle,  // 제목이 변경될 때 호출되는 함수
                        ),
                        SizedBox(height: 16),  // 제목과 내용 사이의 간격
                        // 메모의 내용을 입력하는 TextField
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Content',  // 라벨 텍스트 설정
                              border: OutlineInputBorder(),  // 테두리 스타일 설정
                            ),
                            controller: contentController,  // 내용 컨트롤러 설정
                            onChanged: _updateMemoContent,  // 내용이 변경될 때 호출되는 함수
                            maxLines: null,  // 줄 수 제한 없음
                            expands: true,  // TextField가 가능한 모든 공간을 차지하도록 설정
                            textAlignVertical: TextAlignVertical.top,  // 텍스트를 상단에 정렬
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(child: Text('Select a memo to edit')),  // 메모가 선택되지 않았을 때 표시되는 메시지
          ),
        ],
      ),
    );
  }
}
