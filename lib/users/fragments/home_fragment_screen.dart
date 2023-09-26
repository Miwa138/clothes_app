import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:file/local.dart';
class HomeFragmentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width / 1;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        // добавьте эту строку, чтобы сделать фон черным
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text('Pizza'),
        ),
        body: FutureBuilder(
          future: fetchProducts(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  var product = snapshot.data[index];
                  print(product);
                  return ListTile(
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CachedNetworkImage(
                          imageUrl:
                              'http://host1373377.hostland.pro/api_clothes_store/items/' +
                                  product['images'][0],
                          cacheManager: CacheManager(
                            Config('MyCustomCacheKey',
                                stalePeriod: Duration(days: 7),
                                maxNrOfCacheObjects: 100),
                          ),
                          height: 200,
                          width: width,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          product['name'],
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        // Измените цвет текста на белый, чтобы улучшить его видимость
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          'Price: ${product['price']}',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        // Измените цвет текста на белый, чтобы улучшить его видимость
                        SizedBox(
                          height: 40,
                        ),
                      ],
                    ),
                  );
                },
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  Future<List<dynamic>> fetchProducts() async {
    final response = await http.get(Uri.parse(
        'http://host1373377.hostland.pro/api_clothes_store/items/loaded.php'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load products');
    }
  }
}
