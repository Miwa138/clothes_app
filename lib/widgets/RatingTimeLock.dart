import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingTimeLock extends StatefulWidget {
  final double currentRating;
  final int productId;
  final Function(double) onRatingUpdate;

  RatingTimeLock({
    required this.currentRating,
    required this.productId,
    required this.onRatingUpdate,
  });

  @override
  _RatingTimeLockState createState() => _RatingTimeLockState();
}

class _RatingTimeLockState extends State<RatingTimeLock> {
  static Map<int, DateTime> lastRatingTimes = Map<int, DateTime>();
  bool isLoading = false;
  int ratingTime = 0;
  List options = [];
  @override
  void initState() {
    super.initState();
    fetchOptionsData();
  }
  fetchOptionsData() async {
    setState(() {
      isLoading = true;
    });
    var url =
        'http://host1373377.hostland.pro/api_clothes_store/options/get_rating_time.php';
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var items = json.decode(response.body);
      setState(() {
        options = items;
        isLoading = false;
        print("::::::::::::::::::::::");
        print(options);
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

    // Задать время последней оценки для продуктов после того, как данные установлены
    if (lastRatingTimes.isEmpty || !lastRatingTimes.containsKey(widget.productId)) {
      lastRatingTimes[widget.productId] = DateTime.now().subtract(Duration(hours: ratingTime));
    }
  }

  @override
  Widget build(BuildContext context) {
    return RatingBar.builder(
      initialRating: widget.currentRating,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      itemBuilder: (context, c) => Icon(
        Icons.star,
        color: Colors.amber,
      ),
      onRatingUpdate: (rating) {
        DateTime currentTime = DateTime.now();
        if (currentTime.difference(lastRatingTimes[widget.productId]!).inHours >= ratingTime) {
          widget.onRatingUpdate(rating);
          setState(() {
            lastRatingTimes[widget.productId] = currentTime;
          });
        } else {
          setState(() {});
          int remainingHours =
              ratingTime - currentTime.difference(lastRatingTimes[widget.productId]!).inHours;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Вы можете изменить рейтинг через $remainingHours час.'),
            duration: Duration(seconds: 2),
          ));
        }
      },

      unratedColor: Colors.grey,
      itemSize: 20,
    );
  }
}
