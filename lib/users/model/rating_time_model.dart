import 'package:flutter/material.dart';

class RatingTimeModel extends ChangeNotifier {
  int _ratingTime = 0;

  int get ratingTime => _ratingTime;

  void setRatingTime(int newValue) {
    _ratingTime = newValue;
    notifyListeners();
  }

  void increment() {
    _ratingTime++;
    notifyListeners();
  }

  void decrement() {
    _ratingTime--;
    notifyListeners();
  }
}