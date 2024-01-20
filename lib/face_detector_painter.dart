import 'dart:math';
import 'package:camera/camera.dart';
import 'package:facefilterar/main.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'coordinates_translator.dart';
import 'package:flutter/services.dart';

class FaceDetectorPainter extends CustomPainter {
  FaceDetectorPainter(
    this.faces,
    this.imageSize,
    this.rotation,
    this.cameraLensDirection,
  );

  final List<Face> faces;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint1 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.red;
    final Paint paint2 = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 1.0
      ..color = Colors.green;

    for (final Face face in faces) {
      final left = translateX(
        face.boundingBox.left,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final top = translateY(
        face.boundingBox.top,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final right = translateX(
        face.boundingBox.right,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final bottom = translateY(
        face.boundingBox.bottom,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      const yOffset = -100.0; // Adjust as needed

      final srcRect = Rect.fromPoints(
          Offset(0, 0),
          filterNum == 0
              ? Offset(
                  goggleImage.width.toDouble(), goggleImage.height.toDouble())
              : Offset(
                  helmetImage.width.toDouble(), helmetImage.height.toDouble()));
      final dstRect = filterNum == 0
          ? Rect.fromPoints(Offset(left, top), Offset(right, bottom))
          : Rect.fromPoints(
              Offset(left + 100, top + yOffset), Offset(right - 80, bottom));
      canvas.drawImageRect(
        filterNum == 0 ? goggleImage : helmetImage,
        srcRect,
        dstRect,
        paint1,
      );
      print("offset top is $top");
      print("offset bottom is $bottom");
      print("offset left is $left");
      print("offset right is $right");

      void paintContour(FaceContourType type) {
        final contour = face.contours[type];

        if (contour?.points != null) {
          for (final Point point in contour!.points) {
            canvas.drawCircle(
                Offset(
                  translateX(
                    point.x.toDouble(),
                    size,
                    imageSize,
                    rotation,
                    cameraLensDirection,
                  ),
                  translateY(
                    point.y.toDouble(),
                    size,
                    imageSize,
                    rotation,
                    cameraLensDirection,
                  ),
                ),
                1,
                paint1);
          }
        }
      }

      void paintLandmark(FaceLandmarkType type) {
        //green dots between landmarks
        final landmark = face.landmarks[type];
        if (landmark?.position != null) {
          canvas.drawCircle(
              Offset(
                translateX(
                  landmark!.position.x.toDouble(),
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                ),
                translateY(
                  landmark.position.y.toDouble(),
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                ),
              ),
              2,
              paint2);
        }
      }

      // for (final type in FaceContourType.values) {
      //   if (type == FaceContourType.rightEye) {
      //     // paintGoggle(type);
      //   }
      //   // paintContour(type);
      // }

      // for (final type in FaceLandmarkType.values) {
      //   // paintLandmark(type);
      // }
    }
  }

  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.faces != faces;
  }
}
