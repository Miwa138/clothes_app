import 'dart:convert';
import 'dart:io';
import 'package:clothes_app/admin/admin_login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AdminUploadItemsScreen extends StatefulWidget {
  const AdminUploadItemsScreen({super.key});

  @override
  State<AdminUploadItemsScreen> createState() => _AdminUploadItemsScreenState();
}

class _AdminUploadItemsScreenState extends State<AdminUploadItemsScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? pickedImageXFile;

  var formKey = GlobalKey<FormState>();
  var nameController = TextEditingController();
  var ratingController = TextEditingController();
  var tagsController = TextEditingController();
  var priceController = TextEditingController();
  var sizesController = TextEditingController();
  var colorsController = TextEditingController();
  var descriptionController = TextEditingController();
  var imageLink = "";

  captureImageWithPhoneCamera() async {
    pickedImageXFile = await _picker.pickImage(source: ImageSource.camera);
    Get.back();
    setState(() => pickedImageXFile);
  }

  pickImageFromPhoneGallery() async {
    pickedImageXFile = await _picker.pickImage(source: ImageSource.gallery);
    Get.back();
    setState(() => pickedImageXFile);
  }

  uploadItemImage() async {
    var requsetImgurApi = http.MultipartRequest(
        "POST", Uri.parse("https://api.imgur.com/3/image"));

    String imageName = DateTime.now().millisecondsSinceEpoch.toString();
    requsetImgurApi.fields['title'] = imageName;
    requsetImgurApi.headers['Authorization'] = "Client-ID " + "6cf6e0b3ded38fd";

    var imageFile = await http.MultipartFile.fromPath(
      'image',
      pickedImageXFile!.path,
      filename: imageName,
    );
    requsetImgurApi.files.add(imageFile);
    var responseFromImgurApi = await requsetImgurApi.send();

    var responseDataImgurApi = await responseFromImgurApi.stream.toBytes();

    var resultFromimgurApi = String.fromCharCodes(responseDataImgurApi);

    print("Result :: ");
    print(resultFromimgurApi);

    Map<String, dynamic> jsonRes = json.decode(resultFromimgurApi);

    jsonRes["data"]["link"].toString();
  }

  showDialogBoxForImagePickingAndCapturing() {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            backgroundColor: Colors.black87,
            title: const Text(
              "Item Image",
              style: TextStyle(
                  color: Colors.deepPurple, fontWeight: FontWeight.bold),
            ),
            children: [
              SimpleDialogOption(
                onPressed: () {
                  captureImageWithPhoneCamera();
                },
                child: const Text(
                  "Capture with Phone Camera",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  pickImageFromPhoneGallery();
                },
                child: const Text(
                  "Pick Image From Phone Gallery",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Get.back();
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          );
        });
  }

  Widget defaultScreen() {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black54, Colors.deepPurple],
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_photo_alternate,
              color: Colors.black,
              size: 200,
            ),
            Container(
              width: 140,
              height: 35,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                ),
                onPressed: () {
                  showDialogBoxForImagePickingAndCapturing();
                },
                child: const Text("Add new Item"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget uploadItemFormScreen() {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black54, Colors.deepPurple],
            ),
          ),
        ),
        automaticallyImplyLeading: false,
        title: const Text("Upload Form"),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Get.to(const AdminLoginScreen());
          },
          icon: Icon(Icons.clear),
        ),
        actions: [
          TextButton(
              onPressed: () {
                Get.to(const AdminLoginScreen());
              },
              child: const Text(
                "Done",
                style: TextStyle(color: Colors.green),
              )),
        ],
      ),
      backgroundColor: Colors.black,
      body: ListView(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.3,
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: FileImage(
                  File(pickedImageXFile!.path),
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Form(
                    key: formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          style: const TextStyle(color: Colors.white),
                          controller: nameController,
                          validator: (val) =>
                          val == "" ? "Please write item name" : null,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.title,
                              color: Colors.white,
                            ),
                            fillColor: Colors.white,
                            hintText: "item name",
                            hintStyle: const TextStyle(color: Colors.white),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.white60,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          style: const TextStyle(color: Colors.white),
                          controller: ratingController,
                          validator: (val) =>
                          val == "" ? "Please write item name" : null,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.star_rate_rounded,
                              color: Colors.white,
                            ),
                            fillColor: Colors.white,
                            hintText: "item ratings",
                            hintStyle: const TextStyle(color: Colors.white),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.white60,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          style: const TextStyle(color: Colors.white),
                          controller: tagsController,
                          validator: (val) =>
                          val == "" ? "Please write item tags" : null,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.tag,
                              color: Colors.white,
                            ),
                            fillColor: Colors.white,
                            hintText: "item tags",
                            hintStyle: const TextStyle(color: Colors.white),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.white60,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          style: const TextStyle(color: Colors.white),
                          controller: ratingController,
                          validator: (val) =>
                          val == "" ? "Please give item rating" : null,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.rate_review,
                              color: Colors.white,
                            ),
                            fillColor: Colors.grey,
                            hintText: "item price",
                            hintStyle: const TextStyle(color: Colors.white),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.white60,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        TextFormField(
                          style: const TextStyle(color: Colors.white),
                          controller: sizesController,
                          validator: (val) =>
                          val == "" ? "Please write item size" : null,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.picture_in_picture,
                              color: Colors.white,
                            ),
                            fillColor: Colors.grey,
                            hintText: "item size",
                            hintStyle: const TextStyle(color: Colors.white),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.white60,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        TextFormField(
                          style: const TextStyle(color: Colors.white),
                          controller: colorsController,
                          validator: (val) =>
                          val == "" ? "Please write item colors" : null,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.color_lens,
                              color: Colors.white,
                            ),
                            fillColor: Colors.grey,
                            hintText: "item colors",
                            hintStyle: const TextStyle(color: Colors.white),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.white60,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        TextFormField(
                          style: const TextStyle(color: Colors.white),
                          controller: colorsController,
                          validator: (val) => val == ""
                              ? "Please write item description"
                              : null,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.description,
                              color: Colors.white,
                            ),
                            fillColor: Colors.grey,
                            hintText: "item description",
                            hintStyle: const TextStyle(color: Colors.white),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.white60,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        Container(
                          width: 140,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.black,
                            ),
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                uploadItemImage();
                              }
                            },
                            child: const Text("Upload Now"),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                      ],
                    )),
              ],
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.white,
      //   onPressed: () {
      //     Get.to(AdminLoginScreen());
      //   },
      //   child: Icon(Icons.backspace, color: Colors.black,),
      // ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pickedImageXFile == null ? defaultScreen() : uploadItemFormScreen();
  }
}
