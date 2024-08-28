import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:flutter/services.dart';  // 키보드 이벤트를 처리하기 위해 추가

/// 비디오 파일 뷰어. 키입력을 통해 북마크를 추가할 수 있는 앱.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Bookmark Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: VideoPlayerPage(),
    );
  }
}

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({super.key});

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  Player? _player;
  VideoController? _controller;
  String? _videoPath;
  final List<Duration> _bookmarks = [];

  final FocusNode _focusNode = FocusNode();  // FocusNode를 사용하여 키보드 입력 감지

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _focusNode.requestFocus();  // 초기 포커스 설정
  }

  void _initializePlayer() {
    _player = Player();
    _controller = VideoController(_player!);
  }

  Future<void> _pickVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null) {
      _videoPath = result.files.single.path;
      if (_videoPath != null) {
        await _initializeVideo();
      }
    }
  }

  Future<void> _initializeVideo() async {
    if (_videoPath != null) {
      try {
        await _player!.open(Media(_videoPath!));
        setState(() {});
      } catch (e) {
        print("Error opening video: $e");
      }
    }
  }

  void _addBookmark() {
    final currentPosition = _player!.state.position;
    setState(() {
      _bookmarks.add(currentPosition);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bookmark added at ${currentPosition.toString().split('.').first}')),
    );
  }

  void _seekToBookmark(Duration bookmark) {
    _player!.seek(bookmark);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Seeked to ${bookmark.toString().split('.').first}')),
    );
  }

  @override
  void dispose() {
    _player?.dispose();
    _focusNode.dispose();  // FocusNode 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Bookmark Example'),
        actions: [
          IconButton(
            icon: Icon(Icons.video_library),
            onPressed: _pickVideo,
          ),
        ],
      ),
      body: KeyboardListener(
        focusNode: _focusNode,  // 키보드 입력 감지
        onKeyEvent: (KeyEvent event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.keyB) {
              _addBookmark();  // 'B' 키를 눌러 북마크 추가
            }
          }
        },
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: _controller != null
                    ? AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Video(controller: _controller!),
                      )
                    : Text('No video selected.'),
              ),
            ),
            if (_bookmarks.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _bookmarks.length,
                  itemBuilder: (context, index) {
                    final bookmark = _bookmarks[index];
                    return GestureDetector(
                      onTap: () => _seekToBookmark(bookmark),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Chip(
                          label: Text('Bookmark ${index + 1}'),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
