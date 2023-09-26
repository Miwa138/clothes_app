import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ProductDetailsScreen extends StatelessWidget {
  final dynamic product;

  ProductDetailsScreen({required this.product});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width / 1;
    final _controller = PageController();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title:
        Text(product['name'].toString().replaceAll(' ', '_').tr()),
      ),
      body: Center(
        child: ListView(
          controller: ScrollController(keepScrollOffset: false),
          children: <Widget>[
            Container(
              height: 300,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _controller,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: CachedNetworkImage(
                          imageUrl:
                          'http://host1373377.hostland.pro/api_clothes_store/items/' +
                              product['images'][index],
                          cacheManager: CacheManager(
                            Config(
                              'MyCustomCacheKey',
                              stalePeriod: Duration(days: 7),
                              maxNrOfCacheObjects: 100,
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount:
                    product['images'].length,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios,color: Colors.white,),
                      onPressed:
                          () => _controller.previousPage(duration: Duration(milliseconds: 250), curve: Curves.ease),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(Icons.arrow_forward_ios, color: Colors.white,),
                      onPressed:
                          () => _controller.nextPage(duration: Duration(milliseconds: 250), curve: Curves.ease),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: product['images'].length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () => _controller.animateToPage(index, duration: Duration(milliseconds: 250), curve: Curves.ease),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: CachedNetworkImage(
                        imageUrl:
                        'http://host1373377.hostland.pro/api_clothes_store/items/' +
                            product['images'][index],
                        cacheManager: CacheManager(
                          Config(
                            'MyCustomCacheKey',
                            stalePeriod: Duration(days: 7),
                            maxNrOfCacheObjects: 100,
                          ),
                        ),
                        width: 75,
                      ),
                    ),
                  );
                },
              ),
            ),
           SizedBox(height: 20,),
           Column(
             children: [
             Text(
               product['name'].toString().replaceAll(' ', '_').tr(),
               style: TextStyle(fontSize: 24, color: Colors.white),
             ),
             SizedBox(height: 20,),
               Row
                 (
                   mainAxisAlignment: MainAxisAlignment.center,
                   children:[
                 Text(
                   '${'Price:'.tr()} ${product['price']} ',
                   style:
                   TextStyle(color: Colors.white, fontSize: 18),
                 ),
                 Text('Rub'.tr(), style: TextStyle(color: Colors.white, fontSize: 18,),),
               ]),
               Padding(
                 padding: const EdgeInsets.all(10),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.stretch,
                   children: [
                     Text(
                       product['description'].toString(),
                       style: TextStyle(fontSize: 24, color: Colors.white),
                       maxLines: 20,
                       overflow: TextOverflow.ellipsis,
                       textAlign: TextAlign.center, // добавлен этот параметр
                     ),
                   ],
                 ),
               ),

             ],)
          ],
        ),
      ),
    );
  }

}
