import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SlidingPanelExample(),
    );
  }
}

class SlidingPanelExample extends StatefulWidget {
  const SlidingPanelExample({super.key});

  @override
  _SlidingPanelExampleState createState() => _SlidingPanelExampleState();
}

class _SlidingPanelExampleState extends State<SlidingPanelExample> {
  bool _isPanelVisible = false;

  void _togglePanel() {
    setState(() {
      _isPanelVisible = !_isPanelVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sliding Panel Example'),
      ),
      body: Stack(
        children: <Widget>[
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            left: _isPanelVisible ? -250.0 : 0.0,
            right: _isPanelVisible ? 250.0 : 0.0,
            child: Container(
              color: Colors.white,
              child: Center(
                child: Text(
                  'Main Content',
                  style: TextStyle(fontSize: 24.0),
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            right: _isPanelVisible ? 0.0 : -250.0,
            top: 0.0,
            bottom: 0.0,
            child: Container(
              width: 250.0,
              color: Colors.blue,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                    ),
                    child: Text(
                      'Panel Menu',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.home, color: Colors.white),
                    title: Text('Home', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      _togglePanel();
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.settings, color: Colors.white),
                    title: Text('Settings', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      _togglePanel();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _togglePanel,
        child: Icon(Icons.menu),
      ),
    );
  }
}
