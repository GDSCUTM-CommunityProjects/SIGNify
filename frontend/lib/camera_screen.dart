import 'dart:typed_data';
import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:frontend/settings.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as IMG;
import 'package:native_screenshot/native_screenshot.dart';
import 'package:tflite/tflite.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _recording = false;
  bool _initialized = true;
  late CameraController _controller;
  late Timer timer;
  @override
  void initState() {
    _cameraSetUp();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Set up the front camera
  _cameraSetUp() async {
    final cameras = await availableCameras();
    _controller = CameraController(cameras[1], ResolutionPreset.max);
    await _controller.initialize();
    setState(() => _initialized = false);
  }

  // Start or stop recording
  _recordVideo() async {
    if (_recording) {
      timer.cancel();
      setState(() => _recording = false);
    } else {
      setState(() => _recording = true);
      timer = Timer.periodic(const Duration(milliseconds: 500), (timer) async {
        String? path = await NativeScreenshot.takeScreenshot();

        if (path == null || path.isEmpty)
        {
          print("Screenshot didnt work");
        }

        File imgFile = File(path!);
        // Cropping the image
        Uint8List bytes = imgFile.readAsBytesSync();
        IMG.Image? src = IMG.decodeImage(bytes);

        if (src != null)
        {
          IMG.Image destImage = IMG.copyCrop(src, 300, 990, 560, 560);
          var jpg = IMG.encodeJpg(destImage);
          // var res  = await imageToByteListFloat32(destImage, 560, 0.0, 255.0);
          var res = await Tflite.runModelOnBinary(binary: imageToByteListFloat32(destImage, 560, 0.0, 255.0), numResults: 29);
          print(res);
          // File croppedImage = await File(imgFile.path).writeAsBytes(jpg);
        }
      });
    }
  }

  Uint8List imageToByteListFloat32(
    IMG.Image img, int inputSize, double mean, double std) {
  var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
  var buffer = Float32List.view(convertedBytes.buffer);
  int pixelIndex = 0;
  for (var i = 0; i < inputSize; i++) {
    for (var j = 0; j < inputSize; j++) {
      var pixel = img.getPixel(j, i);
      buffer[pixelIndex++] = (IMG.getRed(pixel) - mean) / std;
      buffer[pixelIndex++] = (IMG.getGreen(pixel) - mean) / std;
      buffer[pixelIndex++] = (IMG.getBlue(pixel) - mean) / std;
    }
  }
  return convertedBytes.buffer.asUint8List();
}

  @override
  Widget build(BuildContext context) {
    if (_initialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return Scaffold(
          body: Stack(
            children: [
              CameraPreview(_controller),
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.red,
                      width: 5,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: SafeArea(
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MySettingsPage()),
                      );
                    },
                    icon: const Icon(
                      Icons.settings,
                      size: 30,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  height: 100,
                  color: Colors.black54,
                  padding: const EdgeInsets.all(25),
                  child: FloatingActionButton(
                    child: Icon(_recording ? Icons.stop : Icons.circle),
                    onPressed: () => _recordVideo(),
                  ),
                ),
              ),
          
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 200,
                height: 200,
                child: Text(""),
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.red,
                      width: 5,
                    )),
              ),
            )
          ],
          ),
        );
    }
  }
}
