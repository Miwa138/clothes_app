import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}



class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  Future<void>? _initializeControllerFuture;
  late CameraDescription firstCamera;
  bool isRecording = false;
  String recordTime = '';
  Duration videoDuration = Duration.zero;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    initCamera().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    firstCamera = cameras.first;
    _controller = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Video Surveillance')),
      body: _initializeControllerFuture != null
          ? FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return CameraPreview(_controller);
            } else {
              return Center(child: CircularProgressIndicator());
            }
          })
          : Center(child: CircularProgressIndicator()),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Text(
              isRecording ? 'Recording: $recordTime' : '',
              style: TextStyle(
                  color: Colors.red,
                  fontSize: 20
              ),
            ),
          ),
          FloatingActionButton(
            child: isRecording ? Icon(Icons.stop) : Icon(Icons.videocam),
            onPressed: () async {
              setState(() {
                isRecording = !isRecording;
              });

              final Directory extDir = await getApplicationDocumentsDirectory();
              final String dirPath = '${extDir.path}/Movies/flutter_test';
              await Directory(dirPath).create(recursive: true);

              if (isRecording) {
                timer?.cancel();

                // Start recording duration from zero
                videoDuration = Duration.zero;

                // Start timer for recording
                timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
                  setState(() {
                    videoDuration = videoDuration + Duration(seconds: 1);
                    recordTime = "${videoDuration.inMinutes.toString().padLeft(2, '0')}:${(videoDuration.inSeconds - (videoDuration.inMinutes * 60)).toString().padLeft(2, '0')}";
                  });
                });

                // Start timer for video chunks
                Timer.periodic(Duration(seconds: 10), (Timer t) async {
                  if (!isRecording) {
                    t.cancel();
                  }

                  final String path = '$dirPath/${DateTime.now().millisecondsSinceEpoch}.mp4';

                  XFile videoFile = await _controller.stopVideoRecording();
                  await videoFile.saveTo(path);
                  await _controller.startVideoRecording();

                  final bytes = await File(path).readAsBytes();
                  final url = 'http://host1373377.hostland.pro/api_clothes_store/camera/camera.php';
                  final request = http.MultipartRequest('POST', Uri.parse(url))
                    ..files.add(http.MultipartFile.fromBytes(
                      'file',
                      bytes,
                      filename: path,
                    ));
                  final response = await request.send();
                  if (response.statusCode == 200) {
                    final jsonResponse = await response.stream
                        .transform(utf8.decoder)
                        .transform(json.decoder)
                        .first;
                    print(':::::::::::::::::::::::');
                    print(jsonResponse);
                  } else {
                    print(':::::::::::::::::::::::');
                    print(response.stream);
                  }
                });

                await _controller.startVideoRecording();
              } else {
                timer?.cancel();
                timer = null;
              }
            },
          ),
        ],
      ),



    );
  }
}
