import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'api_connection/api_connection.dart';

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _name;
  late String _description;
  late double _price;
  List<File> _images = [];




  Future<void> _addProduct() async {
    var request = http.MultipartRequest('POST', Uri.parse(API.uploadNewItem));

    request.fields['name'] = _name;
    request.fields['description'] = _description;
    request.fields['price'] = _price.toString();

    for (var image in _images) {
      var stream = http.ByteStream(Stream.castFrom(image.openRead()));
      var length = await image.length();
      var multipartFile =
          http.MultipartFile('images[]', stream, length, filename: image.path);
      request.files.add(multipartFile);
    }

    var response = await request.send();
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product added successfully.'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding product.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Name',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter product name.';
                    } else {
                      return null;
                    }
                  },
                  onSaved: (value) => _name = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Description',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter product description.';
                    } else {
                      return null;
                    }
                  },
                  onSaved: (value) => _description = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Price',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter product price.';
                    } else {
                      return null;
                    }
                  },
                  onSaved: (value) => _price = double.parse(value!),
                ),
                SizedBox(height: 16.0),
                Text('Images', style: Theme.of(context).textTheme.subtitle1),
                SizedBox(height: 8.0),
                _images.isEmpty
                    ? GestureDetector(
                        onTap: () => _pickImages(),
                        child: Container(
                          height: 150.0,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: Icon(Icons.add_a_photo),
                        ),
                      )
                    : SizedBox(
                        height: 150.0,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _images.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Image.file(_images[index], width: 150.0),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () => _removeImage(index),
                                    child: Icon(Icons.close),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      _addProduct();
                    }
                  },
                  child: Text('Add Product'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImages() async {
    List<XFile>? pickedFiles = await ImagePicker().pickMultiImage();

    if (pickedFiles != null) {
      setState(() {
        _images.addAll(pickedFiles.map((file) => File(file.path)).toList());
      });
    }
  }


  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }
}
