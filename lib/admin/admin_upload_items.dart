// import 'dart:typed_data';
// import 'package:clothes_app/api_connection/api_connection.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:http_parser/http_parser.dart';
// import 'package:multiple_images_picker/multiple_images_picker.dart';
// import 'package:permission_handler/permission_handler.dart';
//
//
// class AdminUploadItemsScreen extends StatefulWidget {
//   const AdminUploadItemsScreen({super.key});
//
//
//   @override
//   State<AdminUploadItemsScreen> createState() => _AdminUploadItemsScreenState();
// }
//
// class _AdminUploadItemsScreenState extends State<AdminUploadItemsScreen> {
//   ValueNotifier<double> uploadProgressNotifier = ValueNotifier(0.0);
//   List<Asset> images = [];
// Dio dio = Dio();
//   Widget buildGridView() {
//     return GridView.count(
//       crossAxisCount: 3,
//       children: List.generate(images.length, (index) {
//         Asset asset = images[index];
//         return AssetThumb(asset: asset, width: 300, height: 300);
//       }),
//     );
//   }
//
//   Future<void> requestPermissions() async {
//     Map<Permission, PermissionStatus> statuses = await [
//       Permission.camera,
//       Permission.photos,
//     ].request();
//
//     if (statuses[Permission.camera]!.isDenied || statuses[Permission.photos]!.isDenied) {
//       showDialog(
//           context: context,
//           builder: (BuildContext context) => AlertDialog(
//             title: const Text("Ошибка разрешения"),
//             content: const Text(
//                 "Пожалуйста, предоставьте разрешения на доступ к камере и галерее"),
//             actions: <Widget>[
//               TextButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   child: const Text("ОК"))
//             ],
//           ));
//     }
//   }
//
//   Future<void> loadAssets() async {
//     await requestPermissions();
//
//     List<Asset> resultList = <Asset>[];
//
//     try {
//       resultList = await MultipleImagesPicker.pickImages(
//         maxImages: 300,
//         enableCamera: true,
//         selectedAssets: images,
//         cupertinoOptions: const CupertinoOptions(takePhotoIcon: "chat"),
//         materialOptions: const MaterialOptions(
//           actionBarColor: "#abcdef",
//           actionBarTitle: "Example App",
//           allViewTitle: "All Photos",
//           useDetailsView: false,
//           selectCircleStrokeColor: "#000000",
//         ),
//       );
//     } on Exception catch (e) {
//       print(e.toString());
//     }
//     if (!mounted) return;
//
//     setState(() {
//       images = resultList;
//     });
//   }
//   _saveImage() async {
//     if (images != null) {
//       List<Future<Response>> requests = [];
//       for (var i = 0; i < images.length; i++) {
//         ByteData byteData = await images[i].getByteData();
//         List<int> imageData = byteData.buffer.asUint8List();
//
//         MultipartFile multipartFile = MultipartFile.fromBytes(
//           imageData,
//           filename: images[i].name,
//           contentType: MediaType('image', 'jpg'),
//         );
//         FormData formData = FormData.fromMap({"image": multipartFile});
//
//         final request = dio.post(API.uploadNewItem, data: formData, onSendProgress: (sent, total) {
//           uploadProgressNotifier.value = ((sent / total) + i) / images.length;
//         });
//         requests.add(request);
//       }
//
//       await Future.wait(requests).then((responses) {
//         // TODO: Обработайте ответы сервера
//       });
//
//       // Завершение загрузки
//       uploadProgressNotifier.value = 1.0;
//       await Future.delayed(Duration(milliseconds: 200));
//     }
//   }
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//   }
//
//   Future<void> _showProgressDialog(BuildContext context) {
//     return showDialog<void>(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return WillPopScope(
//           onWillPop: () async => false,
//           child: Center(
//             child: ValueListenableBuilder<double>(
//               valueListenable: uploadProgressNotifier,
//               builder: (context, value, child) {
//                 return AlertDialog(
//                   content: Row(
//                     children: [
//                       CircularProgressIndicator(value: value),
//                       const SizedBox(width: 20),
//                       Text('${(value * 100).toStringAsFixed(0)}%'),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(title: const Text('Upload Images')),
//       body: ListView(
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 60),
//             child: ElevatedButton(
//               onPressed: loadAssets,
//               child: const Text('Pick Images from Gallery'),
//             ),
//           ),
//           Container(
//             height: MediaQuery.of(context).size.height *
//                 0.6, // Adjust the height value according to your preference
//             child: buildGridView(),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 60),
//             child: ElevatedButton(
//               onPressed: () async {
//                 _showProgressDialog(context);
//                 await _saveImage();
//                 Navigator.pop(context);
//               },
//               child: const Text('Отправить'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
