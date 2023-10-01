import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(VideoApp());

class VideoApp extends StatefulWidget {
  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  List<VideoPlayerController>? _controllers;
  Future<void>? _initializeVideoPlayerFutures;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  _fetchData() async {
    var response = await http.get(Uri.parse('http://host1373377.hostland.pro/api_clothes_store/camera/upload_video.php')); // Ваш API Endpoint
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        var videoMap = jsonDecode(response.body) as Map<String, dynamic>;

        // Используем `values` для получения значений карты в виде итерируемого списка
        _controllers = videoMap.values.map((videoUrl) =>
        VideoPlayerController.network(videoUrl)
          ..initialize().then((_) {
            print(response.body);
            setState(() {});
          }))
            .toList();
      } catch(e) {
        print('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video App',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Video App'),
        ),
        body: _controllers != null
            ? ListView.builder(
          itemCount: _controllers!.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                if (_controllers![index].value.isInitialized)
                  AspectRatio(
                    aspectRatio: _controllers![index].value.aspectRatio,
                    child: VideoPlayer(_controllers![index]),
                  ),
                TextButton(
                  child: Icon(
                    _controllers![index].value.isPlaying ? Icons.pause : Icons.play_arrow,
                  ),
                  onPressed: () {
                    setState(() {
                      _controllers![index].value.isPlaying
                          ? _controllers![index].pause()
                          : _controllers![index].play();
                    });
                  },
                ),
              ],
            );
          },
        )
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (var controller in _controllers!) {
      controller.dispose();
    }
  }
}
