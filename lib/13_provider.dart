import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


/// Provider 패키지를 사용한 상태 관리 예제
/// PageView를 사용하여 3개의 페이지를 전환하며 상태를 공유합니다.
/// 첫 번째 페이지에서 버튼을 누르면 Counter 클래스의 count 변수가 증가하고,
/// 두 번째 페이지에서는 Counter 클래스의 count 변수를 표시하고,
/// 세 번째 페이지에서는 Counter 클래스의 count 변수를 2배하여 표시합니다.
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => Counter(),
      child: MyApp(),
    ),
  );
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

// 상태 클래스 정의 (ChangeNotifier 사용)
class Counter with ChangeNotifier {
  int _count = 0;

  int get count => _count;

  void increment(BuildContext context) {
    _count++;
    notifyListeners();  // 상태가 변경되었음을 알림
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Counter: $_count'),
        duration: Duration(milliseconds: 500),
      ),
    );
  }
}

// HomePage에서 PageView를 사용
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
  }


  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage++;
      });
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Provider Example')),
      body: Stack(
        children: <Widget>[
          PageView(
            controller: _pageController,
            children: <Widget>[
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    context.read<Counter>().increment(context);
                  },
                  child: Text('Increment'),
                ),
              ),
              Center(
                child: Consumer<Counter>(
                  builder: (context, counter, child) {
                    return Text(
                      'Counter: ${counter.count}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    );
                  },
                ),
              ),
              Center(
                child: DoubleCounterWidget(),
              ),
            ],
          ),
          Positioned( // 이전 페이지로 이동하는 버튼
            left: 10,
            top: MediaQuery.of(context).size.height / 2 - 25,
            child: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: _previousPage,
              iconSize: 50,
            ),
          ),
          Positioned( // 다음 페이지로 이동하는 버튼
            right: 10,
            top: MediaQuery.of(context).size.height / 2 - 25,
            child: IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: _nextPage,
              iconSize: 50,
            ),
          ),
        ],
      ),
    );
  }
}

// DoubleCounterWidget 정의
// Counter 클래스의 count 변수를 2배하여 표시
class DoubleCounterWidget extends StatelessWidget {
  const DoubleCounterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Counter>(
      builder: (context, counter, child) {
        return Text(
          'Double Counter: ${counter.count * 2}',
          style: Theme.of(context).textTheme.headlineMedium,
        );
      },
    );
  }
}
