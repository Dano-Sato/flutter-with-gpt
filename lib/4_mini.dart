import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // 탭의 개수
      child: Scaffold(
        appBar: AppBar(
          title: Text('TabBar Example'),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Home'),
              Tab(icon: Icon(Icons.search), text: 'Search'),
              Tab(icon: Icon(Icons.notifications), text: 'Notifications'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Center(child: MyWidget()),
            Center(child: MyListView()),
            Center(child: Text('Notifications Tab Content')),
          ],
        ),
      ),
    );
  }
}


class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              // SnackBar를 표시합니다.
              final snackBar = SnackBar(
                content: Text('Hello from a SnackBar!'),
                duration: Duration(seconds: 3), // 스낵바의 표시 시간
              );

              scaffoldMessenger.showSnackBar(snackBar);

              // 2초 후에 스낵바를 자동으로 숨깁니다.
              Future.delayed(Duration(seconds: 2), () {
                scaffoldMessenger.hideCurrentSnackBar();
              });            
            },
        child: Text('Show SnackBar'),
      ),
    );
  }
}


class MyListView extends StatelessWidget {
  const MyListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 50, // 리스트의 총 아이템 개수
      itemBuilder: (context, index) {
        return ListTile(
          leading: Icon(Icons.star),
          title: Text('Item $index'),
        );
      },
    );
  }
}