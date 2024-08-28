import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter ExpansionTile & Stepper Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ExpansionTile & Stepper Example'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context); // Drawer 닫기
                // 원하는 페이지로 이동하거나 기능을 실행하세요
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context); // Drawer 닫기
                // 설정 페이지로 이동하거나 기능을 실행하세요
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About'),
              onTap: () {
                Navigator.pop(context); // Drawer 닫기
                // 정보 페이지로 이동하거나 기능을 실행하세요
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ExpansionTile(
              title: Text('Expansion Tile 1'),
              leading: Icon(Icons.info),
              children: <Widget>[
                ListTile(title: Text('Item 1')),
                ListTile(title: Text('Item 2')),
                ListTile(title: Text('Item 3')),
              ],
            ),
            ExpansionTile(
              title: Text('Expansion Tile 2'),
              leading: Icon(Icons.settings),
              children: <Widget>[
                ListTile(title: Text('Item 4')),
                ListTile(title: Text('Item 5')),
                ListTile(title: Text('Item 6')),
              ],
            ),
            ExpansionTile(
              title: Text('Expansion Tile 3'),
              leading: Icon(Icons.lock),
              children: <Widget>[
                ListTile(title: Text('Item 7')),
                ListTile(title: Text('Item 8')),
                ListTile(title: Text('Item 9')),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stepper(
                currentStep: _currentStep,
                onStepTapped: (int step) {
                  setState(() {
                    _currentStep = step;
                  });
                },
                onStepContinue: () {
                  if (_currentStep < 2) {
                    setState(() {
                      _currentStep += 1;
                    });
                  }
                },
                onStepCancel: () {
                  if (_currentStep > 0) {
                    setState(() {
                      _currentStep -= 1;
                    });
                  }
                },
                steps: <Step>[
                  Step(
                    title: Text('Step 1'),
                    content: Text('This is the first step.'),
                    isActive: _currentStep >= 0,
                  ),
                  Step(
                    title: Text('Step 2'),
                    content: Text('This is the second step.'),
                    isActive: _currentStep >= 1,
                  ),
                  Step(
                    title: Text('Step 3'),
                    content: Text('This is the third step.'),
                    isActive: _currentStep >= 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
