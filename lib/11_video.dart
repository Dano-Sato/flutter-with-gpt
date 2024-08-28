import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // Flutter 엔진 초기화
  MediaKit.ensureInitialized();         // media_kit 패키지 초기화

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Media Kit Example',
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

  Future<void> _pickVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null) {
      _videoPath = result.files.single.path;
      if (_videoPath != null) {
        _initializeVideo();
      }
    }
  }

  Future<void> _initializeVideo() async {
    if (_videoPath != null) {
      // 기존의 플레이어가 있다면 해제합니다.
      _player?.dispose();

      // 새로운 Player와 VideoController 생성
      _player = Player();
      _controller = VideoController(_player!);

      // 비디오 파일 열기
      await _player!.open(Media(_videoPath!));

      // UI 업데이트
      setState(() {});
    }
  }

  @override
  void dispose() {
    _player?.dispose(); // Player를 해제합니다.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Media Kit Example'),
        actions: [
          IconButton(
            icon: Icon(Icons.video_library),
            onPressed: _pickVideo,
          ),
        ],
      ),
      body: Center(
        child: _controller != null
            ? AspectRatio(
                aspectRatio: 16 / 9,
                child: Video(controller: _controller!),
              )
            : Text('No video selected.'),
      ),
      floatingActionButton: _player != null
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _player!.state.playing ? _player!.pause() : _player!.play();
                });
              },
              child: Icon(_player!.state.playing ? Icons.pause : Icons.play_arrow),
            )
          : null,
    );
  }
}
