import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:clothes_app/users/fragments/detail_product_fragment_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../../generated/locale_keys.g.dart';

class HomeFragmentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width / 1;
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(LocaleKeys.Pizza.tr()),
          leading: IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              if (context.locale == const Locale('ru')) {
                context.setLocale(const Locale('en'));
              } else {
                context.setLocale(const Locale('ru'));
              }
            },
          ),
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
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProductDetailsScreen(product: product),
                        ),
                      );
                    },
                    child: ListTile(
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CachedNetworkImage(
                            imageUrl:
                            'http://host1373377.hostland.pro/api_clothes_store/items/' +
                                product['images'][0],
                            cacheManager: CacheManager(
                              Config('MyCustomCacheKey',
                                  stalePeriod: const Duration(days: 7),
                                  maxNrOfCacheObjects: 100),
                            ),
                            height: 200,
                            width: width,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Text(
                            product['name'].toString().replaceAll(' ', '_').tr(),
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${'Price:'.tr()} ${product['price']} ',
                                style:
                                TextStyle(color: Colors.white, fontSize: 18),
                              ),
                              Text('Rub'.tr(), style: TextStyle(color: Colors.white, fontSize: 18,),),
                            ],
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                        ],
                      ),
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
