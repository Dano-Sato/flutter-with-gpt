import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CardSwipePage(),
    );
  }
}

class CardSwipePage extends StatefulWidget {
  const CardSwipePage({super.key});

  @override
  CardSwipePageState createState() => CardSwipePageState();
}

class CardSwipePageState extends State<CardSwipePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Card Swipe Example'),
      ),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: <Widget>[
              buildCardPage(
                context,
                "Page 1",
                Colors.red,
                Icons.favorite,
                "This is the first page",
              ),
              buildCardPage(
                context,
                "Page 2",
                Colors.green,
                Icons.star,
                "This is the second page",
              ),
              buildCardPage(
                context,
                "Page 3",
                Colors.blue,
                Icons.thumb_up,
                "This is the third page",
              ),
            ],
          ),
          Positioned(
            left: 16,
            top: MediaQuery.of(context).size.height / 2 - 24,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white), // 화살표 버튼의 색상을 흰색으로 설정
              onPressed: () {
                if (_currentPage > 0) {
                  _pageController.previousPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
            ),
          ),
          Positioned(
            right: 16,
            top: MediaQuery.of(context).size.height / 2 - 24,
            child: IconButton(
              icon: Icon(Icons.arrow_forward, color: Colors.white), // 화살표 버튼의 색상을 흰색으로 설정
              onPressed: () {
                if (_currentPage < 2) {
                  _pageController.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCardPage(
      BuildContext context, String title, Color color, IconData icon, String text) {
    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Container(
              color: color,
              child: Center(
                child: Opacity(
                  opacity: 0.8,
                  child: Icon(
                    icon,
                    size: 200,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Hero(
                  tag: title,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
