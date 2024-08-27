import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drag & Drop List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DragDropExample(),
    );
  }
}

class DragDropExample extends StatefulWidget {
  const DragDropExample({super.key});

  @override
  _DragDropExampleState createState() => _DragDropExampleState();
}

class Memo {
  String title;
  String content;
  DateTime lastEdited;
  int index;

  Memo({required this.title, required this.content, required this.lastEdited, required this.index});
}


class _DragDropExampleState extends State<DragDropExample> {
  List<Memo> list1 = [Memo(title: 'Item 1', content: 'Content 1', lastEdited: DateTime.now(), index: 0)];
  List<Memo> list2 = [Memo(title: 'Item 4', content: 'Content 4', lastEdited: DateTime.now(), index: 3)];
  List<Memo> list3 = [Memo(title: 'Item 7', content: 'Content 7', lastEdited: DateTime.now(), index: 6)];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Drag & Drop Bulletin Board'),
        centerTitle: true,
      ),
      body: Row(
        children: [
          Expanded(child: myList(list1, 'List 1')),
          Expanded(child: myList(list2, 'List 2')),
          Expanded(child: myList(list3, 'List 3')),
        ],
      ),
    );
  }

/// 드래그할 때 옮겨지는 상태의 위젯의 위치를 조정하는 함수
Offset myDragAnchorStrategy(
    Draggable<Object> d, BuildContext context, Offset point) {
  return Offset(d.feedbackOffset.dx+100, d.feedbackOffset.dy+25);
}

/// 드래그가 가능한 카드 위젯.
Widget myCard(Memo item, VoidCallback onDragCompleted) {
  return Draggable<Memo>(
    data: item,
    dragAnchorStrategy: myDragAnchorStrategy,
    feedback: Card( // 드래그할 때 옮겨지는 상태의 위젯
      child: Container(
        height: 50,
        width: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,  // 그림자 색상
              blurRadius: 8.0,  // 그림자의 흐림 정도
              offset: Offset(0, 4),  // 그림자의 위치
            ),
          ],
        ),
        child: Center(child: Text(item.title, style: TextStyle(color: Colors.black))),
      ),
    ),
    childWhenDragging: Container( // 드래그 중에는 이 위젯이 드래그 대상 대신 표시됨
      height: 50,
      width: 100,
      color: Colors.transparent,
    ),
    onDragCompleted: onDragCompleted,
    child: Card(
      child: ListTile(
        title: Text(item.title),
        subtitle: Text(item.content),
      ),
    ),
  );
}

Widget myList(List<Memo> list, String title) {
  return DragTarget<Memo>(
    onAcceptWithDetails: (data) {
      setState(() {
        list.add(data.data);
      });
    },
    builder: (context, candidateData, rejectedData) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                return myCard(
                  Memo(content: list[index].content, title: list[index].title, lastEdited: DateTime.now(), index: index),
                  () {
                    setState(() {
                      list.removeAt(index);
                    });
                  },
                );
              },
            ),
          ),
        ],
      );
    },
  );
}

}



