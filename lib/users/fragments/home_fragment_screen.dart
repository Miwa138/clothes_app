import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:clothes_app/api_connection/api_connection.dart';
import 'package:clothes_app/users/fragments/detail_product_fragment_screen.dart';
import 'package:clothes_app/widgets/RatingTimeLock.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../../generated/locale_keys.g.dart';

Future<double> submitRating(int productId, double updatedRating) async {
  final response = await http.post(
    Uri.parse(API.updateRating),
    body: {
      'product_id': productId.toString(),
      'ratings': updatedRating.toString(),
    },
  );

  if (response.statusCode == 200) {
    return updatedRating;
  } else {
    throw Exception('Failed to submit rating');
  }
}

double starsFromRating(double rating) {
  if (rating < 1) return 1.0;
  if (rating > 5) return 5.0;
  return rating.roundToDouble();
}

class HomeFragmentScreen extends StatefulWidget {
  @override
  State<HomeFragmentScreen> createState() => _HomeFragmentScreenState();
}

bool isLoading = false;

class _HomeFragmentScreenState extends State<HomeFragmentScreen> {
  bool isLoading = false;
  int ratingTime = 0; // начальное значение
  List options = [];
  @override
  void initState() {
    super.initState();
    fetchOptionsData();
  }

  static Map<int, DateTime> lastRatingTimes = {};

  fetchOptionsData() async {
    setState(() {
      isLoading = true;
    });
    var url =
        'http://host1373377.hostland.pro/api_clothes_store/options/get_rating_time.php';
    var response = await http.get(Uri.parse(url)); // исправлено здесь
    if (response.statusCode == 200) {
      var items = json.decode(response.body);
      setState(() {
        options = items;
        isLoading = false;
        print("::::::::::::::::::::::");
        print(options);
        // Проверяем, что массив не пустой и содержит рейтинг_время, затем устанавливаем его
        if (items.isNotEmpty && items[0]['rating_time'] != null) {
          ratingTime = items[0]['rating_time'] is int
              ? items[0]['rating_time']
              : int.parse(items[0]['rating_time']);
        }
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print('Failed to load data');
    }
  }

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
                  int productId = int.parse(product['id'].toString());

                  if (!lastRatingTimes.containsKey(productId)) {
                    lastRatingTimes[productId] =
                        DateTime.now().subtract(const Duration(minutes: 2));
                  }

                  return ListTile(
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetailsScreen(product: product),
                              ),
                            );
                          },
                          child: CachedNetworkImage(
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
                            Text(
                              'Rub'.tr(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RatingTimeLock(
                              currentRating: product['ratings'] != null
                                  ? starsFromRating(double.parse(
                                      product['ratings'].toString()))
                                  : 1,
                              productId: productId,
                              onRatingUpdate: (rating) async {
                                // Этот код вызывается когда рейтинг был успешно обновлен через RatingTimeLock
                                double currentRating =
                                    double.parse(product['ratings'].toString());
                                double updatedRating;

                                if (rating < 3) {
                                  updatedRating =
                                      (currentRating - 0.1).toDouble();
                                } else {
                                  updatedRating =
                                      (currentRating + 0.1).toDouble();
                                }
                                updatedRating = double.parse(
                                    updatedRating.toStringAsFixed(1));
                                try {
                                  double newRating = await submitRating(
                                      productId, updatedRating);
                                  setState(() {
                                    product['ratings'] = newRating;
                                  });
                                } catch (error) {
                                  setState(() {});
                                  print("Error updating rating: $error");
                                }
                              },
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text(
                              double.parse(product['ratings'].toString())
                                  .toStringAsFixed(1),
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
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

    // Выводим тело ответа в консоль
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load products');
    }
  }
}
