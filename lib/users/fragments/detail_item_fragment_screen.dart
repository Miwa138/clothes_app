import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class HomeFragmentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Products with Images'),
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
                    title: Text(product['name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Price: ${product['price']}'),
                        Text('Images:'),
                        Column(
                          children: product['images']
                              .map<Widget>((imageUrl) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: CachedNetworkImage(
                              imageUrl:
                            'http://host1373377.hostland.pro/api_clothes_store/items/' +
                                imageUrl,
                              cacheManager: CacheManager(
                                Config('MyCustomCashKey',
                                    stalePeriod: Duration(days: 7),
                                    maxNrOfCacheObjects: 100),
                              ),
                            ),
                          ))
                              .toList(),
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
