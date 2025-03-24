import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class MyCardsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('MYCARD')),
      body: Center(child: Text('저장된 카드 리스트')),
    );
  }
}

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SEARCH')),
      body: Center(child: Text('카드 검색 기능')),
    );
  }
}

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: CameraScreen(), debugShowCheckedModeBanner: false);
  }
}

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  bool _isInitialized = false;
  final textRecognizer = TextRecognizer();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() async {
    _controller = CameraController(
      cameras[0],
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    await _controller.initialize();

    setState(() {
      _isInitialized = true;
    });
  }

  void _captureAndRecognizeText() async {
    try {
      final XFile file = await _controller.takePicture();
      final inputImage = InputImage.fromFilePath(file.path);

      final recognizedText = await textRecognizer.processImage(inputImage);
      final text = recognizedText.text;

      if (text.isNotEmpty) {
        print('🔍 인식된 텍스트: $text');

        if (text.contains('Pikachu')) {
          print('🎯 카드 인식됨: Pikachu!');
          // TODO: 결과 화면 이동
        }
      }
    } catch (e) {
      print('❌ OCR 에러: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _isInitialized
              ? Stack(
                children: [
                  SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _controller.value.previewSize!.height,
                        height: _controller.value.previewSize!.width,
                        child: CameraPreview(_controller),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 32,
                    left: 32,
                    child: FloatingActionButton(
                      heroTag: "myCards",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyCardsPage(),
                          ),
                        );
                      },
                      child: Icon(Icons.photo_library),
                      tooltip: 'MYCARD',
                    ),
                  ),
                  Positioned(
                    bottom: 32,
                    right: 32,
                    child: FloatingActionButton(
                      heroTag: "search",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SearchPage()),
                        );
                      },
                      child: Icon(Icons.search),
                      tooltip: 'SEARCH',
                    ),
                  ),
                ],
              )
              : Center(child: CircularProgressIndicator()),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        heroTag: "capture",
        onPressed: _captureAndRecognizeText,
        child: Icon(Icons.camera_alt),
        tooltip: '촬영 후 OCR',
      ),
    );
  }
}
