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
                  return Draggable<String>(
                    data: list[index],
                    feedback: Material(
                      child: Container(
                        width: 100,
                        color: Colors.blue,
                        child: Text(list[index], style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    childWhenDragging: Container(
                      height: 50,
                      width: 100,
                      color: Colors.grey.shade200,
                    ),
                    onDragCompleted: () {
                      setState(() {
                        list.removeAt(index);
                      });
                    },
                    child: ListTile(
                      title: Text(list[index]),
                    ),
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
