import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AdminUploadItemsScreen extends StatefulWidget {
  const AdminUploadItemsScreen({super.key});

  @override
  State<AdminUploadItemsScreen> createState() =>
      _AdminUploadItemsScreenState();
}

class _AdminUploadItemsScreenState extends State<AdminUploadItemsScreen> {

  List<XFile>? _images;
  final ImagePicker _picker = ImagePicker();
  List<String> imageLinks = [];
  List<String> deleteHashes = [];

  var nameController = TextEditingController();
  var ratingController = TextEditingController();
  var tagsController = TextEditingController();
  var priceController = TextEditingController();
  var sizesController = TextEditingController();
  var colorsController = TextEditingController();
  var descriptionController = TextEditingController();
  var imageLink = "";

  // Загрузка нескольких фото
  Future<List<String>> uploadItemImages(List<XFile> imageFiles) async {
    List<String> uploadedImages = [];
    for (var imageFileX in imageFiles) {
      var requestImgurApi =
      http.MultipartRequest("POST", Uri.parse("https://api.imgur.com/3/image"));

      requestImgurApi.headers['Authorization'] =
          "Client-ID " + "6cf6e0b3ded38fd";

      String imageName = DateTime.now().millisecondsSinceEpoch.toString();
      requestImgurApi.fields['title'] = imageName;

      var imageFile = await http.MultipartFile.fromPath(
        'image',
        imageFileX.path,
        filename: imageName,
      );
      requestImgurApi.files.add(imageFile);

      var responseFromImgurApi = await requestImgurApi.send();

      var responseDataImgurApi =
      await responseFromImgurApi.stream.toBytes();
      var resultFromimgurApi = String.fromCharCodes(responseDataImgurApi);

      Map<String, dynamic> jsonRes = json.decode(resultFromimgurApi);
      imageLink = (jsonRes["data"]["link"]).toString();
      String deleteHash = (jsonRes["data"]["deletehash"]).toString();

      // добавляем ссылки и хеши в списки
      imageLinks.add(imageLink);
      deleteHashes.add(deleteHash);
      uploadedImages.add(imageLink);
      // выводим все загруженные ссылки на изображения
      print("All image links:");
      imageLinks.forEach((link) => print(link));
    }
    return uploadedImages;

  }

  // Выбор нескольких фото
  Future<void> pickImages() async {
    final ImagePicker _picker = ImagePicker();
    final List<XFile>? pickedImages = await _picker.pickMultiImage();
    if (pickedImages != null && pickedImages.isNotEmpty) {
      await uploadItemImages(pickedImages);
    } else {
      print("No images were selected.");
    }
  }

  Future<void> _getImageFromGallery() async {
    final images = await _picker.pickMultiImage();
    if (images != null) {
      setState(() {
        _images = images;
        _uploadImagesFuture = null;
      });
    }
  }

  Future<void> _showProgressDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Future<List<String>>? _uploadImagesFuture;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Images')),
      body: Column(
        children: [
          if (_uploadImagesFuture != null)
            FutureBuilder<List<String>>(
              future: _uploadImagesFuture,
              builder: (BuildContext context,
                  AsyncSnapshot<List<String>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  return Text('Изображения успешно загружены');
                } else {
                  return SizedBox();
                }
              },
            ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              children: List.generate(
                _images?.length ?? 0,
                    (index) {
                  return Card(
                    child: Image.file(
                      File(_images![index].path),
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => _getImageFromGallery(),
            child: Text('Pick Images from Gallery'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_images != null) {
                _showProgressDialog(context);
                await uploadItemImages(_images!);
                Navigator.of(context).pop();
              }
            },
            child: Text('Отправить'),
          ),
        ],
      ),
    );
  }
}
