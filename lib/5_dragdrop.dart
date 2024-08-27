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

class _DragDropExampleState extends State<DragDropExample> {
  List<String> list1 = ['Item 1', 'Item 2', 'Item 3'];
  List<String> list2 = ['Item 4', 'Item 5', 'Item 6'];
  List<String> list3 = ['Item 7', 'Item 8', 'Item 9'];

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

Offset MydragAnchorStrategy(
    Draggable<Object> d, BuildContext context, Offset point) {
  return Offset(d.feedbackOffset.dx+100, d.feedbackOffset.dy+25);
}

Widget myCard(String item, VoidCallback onDragCompleted) {
  return Draggable<String>(
    data: item,
    dragAnchorStrategy: MydragAnchorStrategy,
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
        child: Center(child: Text(item, style: TextStyle(color: Colors.black))),
      ),
    ),
    childWhenDragging: Container( // 드래그 중에는 이 위젯이 드래그 대상 대신 표시됨
      height: 50,
      width: 100,
      color: Colors.white,
    ),
    onDragCompleted: onDragCompleted,
    child: Card(
      child: ListTile(
        title: Text(item),
      ),
    ),
  );
}

Widget myList(List<String> list, String title) {
  return DragTarget<String>(
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
                  list[index],
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