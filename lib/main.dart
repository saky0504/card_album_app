import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'package:image/image.dart' as img;
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
  final String recognizedText;

  SearchPage({required this.recognizedText});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SEARCH')),
      body: Center(child: Text('인식된 텍스트: $recognizedText')),
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
  late Interpreter interpreter;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadModel();
  }

  void _loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset('card_detector.tflite');
      print('✅ TFLite 모델 로드 완료');
    } catch (e) {
      print('❌ 모델 로드 에러: $e');
    }
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

      // 이미지 로드 및 변환 (딥러닝 추론용)
      final bytes = await File(file.path).readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image != null) {
        // 이미지 리사이즈 (모델 입력 크기에 맞게)
        final resizedImage = img.copyResize(image, width: 224, height: 224);

        // 이미지 → 텐서 변환
        TensorImage tensorImage = TensorImage.fromImage(resizedImage);
        var input = [tensorImage.buffer];
        var output = List.filled(4, 0.0).reshape([1, 4]); // 카드 영역 좌표 예시

        // 딥러닝 추론
        interpreter.run(input, output);
        print('🟩 카드 영역 예측 결과: $output');

        // TODO: output 기반으로 이미지 크롭 및 저장
      }

      if (text.isNotEmpty) {
        print('🔍 인식된 텍스트: $text');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchPage(recognizedText: text),
          ),
        );
      }
    } catch (e) {
      print('❌ OCR/모델 에러: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    textRecognizer.close();
    interpreter.close();
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
                          MaterialPageRoute(
                            builder:
                                (context) => SearchPage(recognizedText: ""),
                          ),
                        );
                      },
                      child: Icon(Icons.search),
                      tooltip: 'SEARCH',
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: _captureAndRecognizeText,
                        child: Container(
                          width: 108,
                          height: 108,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: Colors.black, width: 4),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.black,
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
              : Center(child: CircularProgressIndicator()),
    );
  }
}
