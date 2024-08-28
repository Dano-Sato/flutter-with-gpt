import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

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

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    _player = Player();
    _controller = VideoController(_player!);
    _player!.setPlaylistMode(PlaylistMode.loop);
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

        setState(() {
          // 화면을 갱신하여 비디오 재생 준비 완료
        });
      } catch (e) {
        print("Error opening video: $e");
      }
    }
  }

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              onPressed: _pickVideo,
              child: Icon(Icons.video_library),
            )
          : null,
    );
  }
}
