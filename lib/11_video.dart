import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:flutter/services.dart'; // 키보드 이벤트를 처리하기 위해 추가

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

  final FocusNode _focusNode = FocusNode(); // FocusNode를 사용하여 키보드 입력 감지

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _focusNode.requestFocus(); // 초기 포커스 설정
  }

  void _initializePlayer() {
    _player = Player();
    _controller = VideoController(_player!);
  }

  Future<void> _pickVideo() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.video);
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
        setState(() {
          _bookmarks.clear(); // 북마크 리스트 초기화
        });
      } catch (e) {
        debugPrint("Error opening video: $e");
      }
    }
  }

  void _addBookmark() {
    final currentPosition = _player!.state.position;
    setState(() {
      _bookmarks.add(currentPosition);
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Bookmark added at ${currentPosition.toString().split('.').first}'),
        backgroundColor: Colors.transparent,
        elevation: 10.0,
      ),
    );
  }

  void _seekToBookmark(Duration bookmark) {
    _player!.seek(bookmark);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Seeked to ${bookmark.toString().split('.').first}'),
        backgroundColor: Colors.transparent,
        elevation: 10.0,
      ),
    );
  }

  void _removeBookmark(Duration bookmark) {
    setState(() {
      _bookmarks.remove(bookmark);
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bookmark removed'),
        backgroundColor: Colors.transparent,
        elevation: 10.0,
      ),
    );
  }

  @override
  void dispose() {
    _player?.dispose();
    _focusNode.dispose(); // FocusNode 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _pickVideo,
        child: Icon(Icons.video_library),
      ),
      body: KeyboardListener(
        focusNode: _focusNode, // 키보드 입력 감지
        onKeyEvent: (KeyEvent event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.keyQ) {
              _addBookmark(); // 'Q' 키를 눌러 북마크 추가
            }
            if (event.logicalKey.keyId >= LogicalKeyboardKey.digit1.keyId &&
                event.logicalKey.keyId <= LogicalKeyboardKey.digit9.keyId) {
              int index =
                  event.logicalKey.keyId - LogicalKeyboardKey.digit1.keyId;
              if (index < _bookmarks.length) {
                try {
                  _seekToBookmark(_bookmarks[index]);
                } catch (e) {
                  debugPrint('Failed to seek to bookmark: $e');
                }
              } else {
                debugPrint('No bookmark available for this number');
              }
            }
          }
        },
        child: Stack(
          children: [
            Center(
              child: _controller != null
                  ? SizedBox(
                      width: MediaQuery.of(context).size.width, // 화면의 너비에 맞추기
                      height: MediaQuery.of(context).size.height, // 화면의 높이에 맞추기
                      child: Video(
                        controller: _controller!,
                        fit: BoxFit.contain, // 비디오를 화면에 꽉 차도록 설정 (비율 유지)
                      ),
                    )
                  : const Text('No video selected.'),
            ),
            if (_bookmarks.isNotEmpty)
              Positioned(
                top: 10,
                right: 10,
                child: Column(
                  children: _bookmarks.map((bookmark) {
                    int index = _bookmarks.indexOf(bookmark) + 1;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: GestureDetector(
                        onTap: () => _seekToBookmark(bookmark),
                        onSecondaryTap: () => _removeBookmark(bookmark),
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            'Bookmark $index',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
