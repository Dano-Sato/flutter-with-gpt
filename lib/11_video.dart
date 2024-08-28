import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:flutter/services.dart'; // 키보드 이벤트를 처리하기 위해 추가
import 'package:shared_preferences/shared_preferences.dart'; // 북마크를 저장하기 위해 추가
import 'dart:convert'; // JSON Encoding/Decoding을 위해 추가


/// todo:
/// 1. 북마크매니저를 통해 북마크를 실제로 저장하고 뷰어 실행시 불러와야 합니다.

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



/// 북마크를 관리하는 클래스입니다.
class BookmarkManager {
  Map<String, List<Duration>> myBookmarks = {};

  Future<void> saveBookmarks() async {
    final prefs = await SharedPreferences.getInstance();

    // Map<Duration>을 List<int> (seconds로)로 변환 후, JSON으로 직렬화
    Map<String, List<int>> serializableBookmarks = myBookmarks.map((path, durations) {
      return MapEntry(path, durations.map((d) => d.inSeconds).toList());
    });

    String jsonString = jsonEncode(serializableBookmarks);
    await prefs.setString('bookmarks', jsonString);
  }

  Future<void> loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('bookmarks');

    if (jsonString != null) {
      // JSON을 파싱하여 Map<String, List<int>>로 변환 후, 다시 Duration으로 변환
      Map<String, List<dynamic>> decoded = jsonDecode(jsonString);
      myBookmarks = decoded.map((path, durations) {
        return MapEntry(path, durations.map((s) => Duration(seconds: s as int)).toList());
      });
    }
  }

  void addBookmark(String filePath, Duration bookmark) {
    if (myBookmarks.containsKey(filePath)) {
      myBookmarks[filePath]!.add(bookmark);
    } else {
      myBookmarks[filePath] = [bookmark];
    }
  }

  List<Duration>? getBookmarks(String filePath) {
    return myBookmarks[filePath];
  }
}

/// 해당 폴더의 비디오 파일 목록을 보여주는 Drawer 위젯입니다.
class VideoListDrawer extends StatelessWidget {
  final List<String> videoFiles;
  final Function(String) onVideoSelected;

  const VideoListDrawer({super.key, 
    required this.videoFiles,
    required this.onVideoSelected,
  });

  @override
  Widget build(BuildContext context) {
    // 원본 리스트를 복사하여 정렬
    List<String> sortedVideoFiles = List.from(videoFiles);
    sortedVideoFiles.sort((a, b) => a.split('\\').last.compareTo(b.split('\\').last));


    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        SizedBox(
          height: 70,
          child: DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Video Player Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
        ),
        ...sortedVideoFiles.map((file) => ListTile(
          leading: Icon(Icons.video_library),
          title: Text(file.split('\\').last), // 파일 이름만 표시
          onTap: () => onVideoSelected(file),
        )),
      ],
    );
  }
}

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({super.key});

  @override
  VideoPlayerPageState createState() => VideoPlayerPageState();
}

class VideoPlayerPageState extends State<VideoPlayerPage> {
  Player? _player;
  VideoController? _controller;
  String? _videoPath;
  List<String> _videoFiles = [];
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

  /// 비디오 파일 선택
  Future<void> _pickVideo() async {


    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.video, allowMultiple: false);
    if (result != null) {
      _videoPath = result.files.single.path;
      if (_videoPath != null) {

        /// 해당 폴더의 비디오 파일 목록을 가져옵니다.
        final dir = Directory(_videoPath!).parent;
        final List<String> videoFiles = dir
            .listSync()
            .where((file) =>
                file.path.endsWith('.mp4') ||
                file.path.endsWith('.mkv') ||
                file.path.endsWith('.avi'))
            .map((file) => file.path)
            .toList();

        setState(() {
          _videoFiles = videoFiles;
        });

        /// 비디오 파일을 열고 북마크 리스트를 초기화합니다.
        await _initializeVideo();
      }
    }
  }

  /// 비디오 파일을 열고 북마크 리스트를 초기화합니다.
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

  /// 북마크 추가
  void _addBookmark() {
    final currentPosition = _player!.state.position;
    setState(() {
      _bookmarks.add(currentPosition);
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(
          child: Text(
              'Bookmark added at ${currentPosition.toString().split('.').first}'),
        ),
        backgroundColor: Colors.transparent,
        elevation: 10.0,
      ),
    );
  }

  /// 현재 비디오 플레이어를 북마크 시간으로 이동시킵니다.
  void _seekToBookmark(Duration bookmark) {
    _player!.seek(bookmark);

    /// 스낵바를 통해 북마크 시간을 표시합니다.
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(
            child: Text('Seeked to ${bookmark.toString().split('.').first}')),
        backgroundColor: Colors.transparent,
        elevation: 10.0,
      ),
    );
  }

  /// 북마크 삭제
  void _removeBookmark(Duration bookmark) {
    setState(() {
      _bookmarks.remove(bookmark);
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(child: Text('Bookmark removed')),
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
      drawer: Drawer(
        child: VideoListDrawer(
          videoFiles: _videoFiles,
          onVideoSelected: (path) {
            Navigator.of(context).pop(); // Drawer를 닫음
            _videoPath = path;
            _initializeVideo(); // 선택한 비디오 재생
          },
        ),
      ),
      floatingActionButton: Stack(
        children: <Widget>[
          // 왼쪽 위에 Drawer 열기 버튼
          Positioned(
            top: 16,
            left: 16,
            child: Builder(
              builder: (context) => FloatingActionButton(
                backgroundColor: Colors.white.withOpacity(0.5),
                onPressed: () => Scaffold.of(context).openDrawer(),
                heroTag: "drawerBtn",
                child: Icon(Icons.menu),
              ),
            ),
          ),
          // 첫 번째 FloatingActionButton (비디오 선택)
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: Colors.white.withOpacity(0.5),
              onPressed: _pickVideo,
              heroTag: "btn1", // 각 버튼에 고유한 heroTag를 설정합니다. heroTag를 설정하지 않으면 애니메이션 오류가 발생할 수 있습니다.
              child: Icon(Icons.video_library),
            ),
          ),
          // 두 번째 FloatingActionButton (북마크 추가)
          Positioned(
            bottom: 80, // 첫 번째 버튼 위에 배치하기 위해 위치 조정
            right: 16,
            child: FloatingActionButton(
              backgroundColor: Colors.white.withOpacity(0.5),
              onPressed: _addBookmark,
              heroTag: "btn2", // 각 버튼에 고유한 heroTag를 설정합니다.
              child: Icon(Icons.bookmark),
            ),
          ),
        ],
      ),
      body: KeyboardListener(
        focusNode: _focusNode, // 키보드 입력 감지
        onKeyEvent: (KeyEvent event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.keyQ) {
              _addBookmark(); // 'Q' 키를 눌러 북마크 추가
            }
            /// 숫자 키를 눌러 해당 북마크로 이동
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
            Center( /// 비디오 플레이어 위젯. 화면을 꽉 채우도록 설정
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
                child: Column( /// 북마크 목록을 표시하는 Column 위젯
                  children: _bookmarks.map((bookmark) {
                    // 북마크 시간을 분:초 형식으로 변환
                    String formattedDuration =
                        "${bookmark.inMinutes.remainder(60).toString().padLeft(2, '0')}:${bookmark.inSeconds.remainder(60).toString().padLeft(2, '0')}";
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: GestureDetector(
                        onSecondaryTap: () => _removeBookmark(bookmark),
                        child: ElevatedButton(
                          onPressed: () => _seekToBookmark(bookmark),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black.withOpacity(0.2),
                          ),
                          child: Text(
                            formattedDuration,
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
