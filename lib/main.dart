import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'detector_view.dart';
import 'face_detector_painter.dart';
import 'package:screen_recorder/screen_recorder.dart';

late ui.Image goggleImage;
late ui.Image helmetImage;
int filterNum = 0;
final FaceDetector faceDetector = FaceDetector(
  options: FaceDetectorOptions(
    enableContours: true,
    enableLandmarks: true,
  ),
);
ScreenRecorderController screenController = ScreenRecorderController(
  pixelRatio: 0.5,
  skipFramesBetweenCaptures: 2,
);
// late RecordWidgetController recordWidgetController;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  goggleImage = await loadImage('goggles.png');
  helmetImage = await loadImage('helmet.png');
  // final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
  // final String videoDirectory = path.join(appDocumentsDir.path, 'videos');
  // print("ag path init: " + videoDirectory);
  // recordWidgetController = RecordWidgetController(
  //     directory_folder_render: Directory(videoDirectory));
  runApp(const MyApp());
}

Future<ui.Image> loadImage(String imageName) async {
  final data = await rootBundle.load('assets/$imageName');
  return decodeImageFromList(data.buffer.asUint8List());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const FaceDetectorView(),
    );
  }
}

class FaceDetectorView extends StatefulWidget {
  const FaceDetectorView({super.key});

  @override
  State<FaceDetectorView> createState() => _FaceDetectorViewState();
}

class _FaceDetectorViewState extends State<FaceDetectorView> {
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  var _cameraLensDirection = CameraLensDirection.front;

  @override
  void dispose() {
    _canProcess = false;
    faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DetectorView(
      title: 'Face Detector',
      customPaint: _customPaint,
      onImage: _processImage,
      initialCameraLensDirection: _cameraLensDirection,
      onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
    );
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    final faces = await faceDetector.processImage(inputImage);
    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
      final painter = FaceDetectorPainter(
        faces,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
      );
      _customPaint = CustomPaint(foregroundPainter: painter);
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
