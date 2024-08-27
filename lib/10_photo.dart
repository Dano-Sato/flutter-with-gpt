import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';


/// 이미지 폴더를 선택하고 선택한 이미지를 그리드로 보여주는 앱.
/// 크롬으로 빌드하면 안됩니다.
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Image Viewer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ImageFolderPicker(),
    );
  }
}

class ImageFolderPicker extends StatefulWidget {
  const ImageFolderPicker({super.key});

  @override
  _ImageFolderPickerState createState() => _ImageFolderPickerState();
}

class _ImageFolderPickerState extends State<ImageFolderPicker> {
  List<File> _images = [];

  Future<void> _pickFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      final directory = Directory(selectedDirectory);
      final files = directory
          .listSync()
          .where((item) => item is File && _isImageFile(item.path))
          .map((item) => File(item.path))
          .toList();

      setState(() {
        _images = files;
      });
    }
  }

  bool _isImageFile(String path) {
    final extension = path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'heif', 'heic', 'tiff', 'tif'].contains(extension);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Viewer'),
        actions: [
          IconButton(
            icon: Icon(Icons.folder_open),
            onPressed: _pickFolder,
          ),
        ],
      ),
      body: _images.isEmpty
          ? Center(child: Text('No images selected.'))
          : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ImageViewerPage(images: _images, initialIndex: index),
                      ),
                    );
                  },
                  child: Image.file(
                    _images[index],
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
    );
  }
}

class ImageViewerPage extends StatelessWidget {
  final List<File> images;
  final int initialIndex;

  ImageViewerPage({super.key, required this.images, required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: PhotoViewGallery.builder(
        itemCount: images.length,
        pageController: PageController(initialPage: initialIndex),
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: FileImage(images[index]),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 3,
          );
        },
      ),
    );
  }
}
