import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:io';

// 저장된 카드 데이터 모델
class CardData {
  final String imagePath;
  final String text;
  final DateTime timestamp;

  CardData({
    required this.imagePath,
    required this.text,
    required this.timestamp,
  });
}

// 전역 카드 리스트 (실제로는 DB나 shared_preferences 사용 권장)
List<CardData> savedCards = [];

class MyCardsPage extends StatefulWidget {
  const MyCardsPage({super.key});

  @override
  State<MyCardsPage> createState() => _MyCardsPageState();
}

class _MyCardsPageState extends State<MyCardsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MYCARD'), backgroundColor: Colors.blue),
      body:
          savedCards.isEmpty
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo_library_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      '저장된 카드가 없습니다',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              )
              : GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.75,
                ),
                itemCount: savedCards.length,
                itemBuilder: (context, index) {
                  final card = savedCards[index];
                  return Card(
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child:
                              File(card.imagePath).existsSync()
                                  ? Image.file(
                                    File(card.imagePath),
                                    fit: BoxFit.cover,
                                  )
                                  : Container(
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.image_not_supported,
                                    ),
                                  ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                card.text.length > 30
                                    ? '${card.text.substring(0, 30)}...'
                                    : card.text,
                                style: const TextStyle(fontSize: 12),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${card.timestamp.year}-${card.timestamp.month}-${card.timestamp.day}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}

class SearchPage extends StatefulWidget {
  final String recognizedText;

  const SearchPage({super.key, required this.recognizedText});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController _searchController;
  List<CardData> _filteredCards = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.recognizedText);
    _filterCards(widget.recognizedText);
  }

  void _filterCards(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCards = savedCards;
      } else {
        _filteredCards =
            savedCards
                .where(
                  (card) =>
                      card.text.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SEARCH'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '카드 텍스트 검색...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: _filterCards,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '검색 결과: ${_filteredCards.length}개',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child:
                _filteredCards.isEmpty
                    ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 80, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            '검색 결과가 없습니다',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredCards.length,
                      itemBuilder: (context, index) {
                        final card = _filteredCards[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading:
                                File(card.imagePath).existsSync()
                                    ? Image.file(
                                      File(card.imagePath),
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    )
                                    : Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.image_not_supported,
                                      ),
                                    ),
                            title: Text(
                              card.text,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '${card.timestamp.year}-${card.timestamp.month}-${card.timestamp.day} ${card.timestamp.hour}:${card.timestamp.minute}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } catch (e) {
    debugPrint('카메라 초기화 에러: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CameraScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
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

  // TFLite 모델 로드
  void _loadModel() async {
    try {
      // assets 폴더 내 모델 파일 경로 지정
      interpreter = await Interpreter.fromAsset('assets/card_detector.tflite');
      debugPrint('✅ TFLite 모델 로드 완료');
    } catch (e) {
      debugPrint('❌ 모델 로드 에러: $e');
    }
  }

  // 카메라 초기화 및 예외 처리
  void _initializeCamera() async {
    if (cameras.isNotEmpty) {
      _controller = CameraController(
        cameras[0],
        ResolutionPreset.high,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      try {
        await _controller.initialize();
        setState(() {
          _isInitialized = true;
        });
      } catch (e) {
        debugPrint('카메라 초기화 중 에러: $e');
      }
    } else {
      debugPrint('사용 가능한 카메라가 없습니다.');
    }
  }

  // 사진 촬영 및 텍스트 인식, TFLite 모델 추론 수행
  void _captureAndRecognizeText() async {
    try {
      final XFile file = await _controller.takePicture();
      final inputImage = InputImage.fromFilePath(file.path);

      // ML Kit를 통한 텍스트 인식
      final recognizedTextResult = await textRecognizer.processImage(
        inputImage,
      );
      final text = recognizedTextResult.text;

      // 이미지 파일 로드 및 딥러닝 추론을 위한 전처리
      final bytes = await File(file.path).readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image != null) {
        // 모델 입력 크기에 맞게 이미지 리사이즈
        final resizedImage = img.copyResize(image, width: 224, height: 224);

        // 이미지를 Float32List로 변환 (정규화: 0~255 → 0~1)
        var inputBytes = resizedImage.getBytes();
        var input = List.generate(
          1,
          (index) => List.generate(
            224,
            (y) => List.generate(224, (x) {
              int pixelIndex = (y * 224 + x) * 3;
              return [
                inputBytes[pixelIndex] / 255.0, // R
                inputBytes[pixelIndex + 1] / 255.0, // G
                inputBytes[pixelIndex + 2] / 255.0, // B
              ];
            }),
          ),
        );

        // 출력 버퍼 생성 (카드 영역 좌표 [x1, y1, x2, y2])
        var output = List.filled(1, List.filled(4, 0.0));

        // TFLite 추론 실행
        interpreter.run(input, output);
        debugPrint('🟩 카드 영역 예측 결과: $output');

        // 카드 영역 크롭
        List<double> coords = output[0].cast<double>();
        int x1 = (coords[0] * image.width).toInt().clamp(0, image.width);
        int y1 = (coords[1] * image.height).toInt().clamp(0, image.height);
        int x2 = (coords[2] * image.width).toInt().clamp(0, image.width);
        int y2 = (coords[3] * image.height).toInt().clamp(0, image.height);

        // 크롭된 카드 이미지 저장
        String? savedImagePath;
        if (x2 > x1 && y2 > y1) {
          final croppedImage = img.copyCrop(image, x1, y1, x2 - x1, y2 - y1);

          // 파일로 저장
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final savePath = '${Directory.systemTemp.path}/card_$timestamp.jpg';
          await File(savePath).writeAsBytes(img.encodeJpg(croppedImage));
          savedImagePath = savePath;
          debugPrint('💾 카드 이미지 저장 완료: $savePath');
        }

        // 카드 데이터 리스트에 추가
        if (text.isNotEmpty && savedImagePath != null) {
          savedCards.add(
            CardData(
              imagePath: savedImagePath,
              text: text,
              timestamp: DateTime.now(),
            ),
          );
          debugPrint('📋 카드 리스트에 추가 완료 (총 ${savedCards.length}개)');
        }
      }

      if (text.isNotEmpty) {
        debugPrint('🔍 인식된 텍스트: $text');

        // BuildContext가 여전히 유효한지 확인
        if (!mounted) return;

        // 저장 완료 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ 카드가 저장되었습니다!'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );

        // BuildContext가 여전히 유효한지 확인
        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchPage(recognizedText: text),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ OCR/모델 에러: $e');
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
                  // 카메라 미리보기
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
                  // MYCARD 페이지로 이동하는 버튼
                  Positioned(
                    bottom: 32,
                    left: 32,
                    child: FloatingActionButton(
                      heroTag: "myCards",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyCardsPage(),
                          ),
                        );
                      },
                      tooltip: 'MYCARD',
                      child: const Icon(Icons.photo_library),
                    ),
                  ),
                  // SEARCH 페이지로 이동하는 버튼
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
                                (context) =>
                                    const SearchPage(recognizedText: ""),
                          ),
                        );
                      },
                      tooltip: 'SEARCH',
                      child: const Icon(Icons.search),
                    ),
                  ),
                  // 촬영 및 인식 실행 버튼
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
                          child: const Icon(
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
              : const Center(child: CircularProgressIndicator()),
    );
  }
}
