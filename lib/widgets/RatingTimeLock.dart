import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    getLastRatingTimeFromStorage();
  }
  void clearAllDataFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
  fetchOptionsData() async {
    setState(() {
      isLoading = true;
    });
    var url = 'http://host1373377.hostland.pro/api_clothes_store/options/get_rating_time.php';
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var items = json.decode(response.body);
      setState(() {
        options = items;
        isLoading = false;
        // print("::::::::::::::::::::::");
        // print(options);
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
    if (lastRatingTimes.isEmpty ||
        !lastRatingTimes.containsKey(widget.productId)) {
      lastRatingTimes[widget.productId] =
          DateTime.now().subtract(Duration(hours: ratingTime));
    }
  }

  void getLastRatingTimeFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String lastRatingTimeKey = 'lastRatingTime:${widget.productId}';
    String? storedTimeString = prefs.getString(lastRatingTimeKey);

    if (storedTimeString != null) {
      setState(() {
        lastRatingTimes[widget.productId] = DateTime.parse(storedTimeString).toLocal();
      });
    }
  }



  void setLastRatingTimeToStorage(DateTime lastRatingTime) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String lastRatingTimeKey = 'lastRatingTime:${widget.productId}';
    await prefs.setString(lastRatingTimeKey, lastRatingTime.toUtc().toString());
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
        Duration timeDifference =
        currentTime.difference(lastRatingTimes[widget.productId]!);

        // Изменили условие на проверку, что прошло более 3 часов
        if (timeDifference.inHours >= 3) {
          widget.onRatingUpdate(rating);
          setState(() {
            lastRatingTimes[widget.productId] = currentTime;
          });

          setLastRatingTimeToStorage(
              currentTime);
        } else {
          int remainingHours = ratingTime - timeDifference.inHours;
          int remainingMinutes = ratingTime * 60 - timeDifference.inMinutes;
          int remainingSeconds = ratingTime * 3600 - timeDifference.inSeconds;
          String timeText;

          if (remainingHours > 0) {
            timeText = '${remainingHours} ч. ${remainingMinutes % 60} мин.';
          } else if (remainingMinutes > 0) {
            timeText = '$remainingMinutes мин. ${remainingSeconds % 60} сек.';
          } else {
            timeText = '$remainingSeconds сек.';
          }

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Вы можете изменить рейтинг через $timeText.'),
            duration: Duration(seconds: 2),
          ));
        }
      },
      unratedColor: Colors.grey,
      itemSize: 20,
    );
  }
}
