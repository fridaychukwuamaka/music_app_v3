import 'package:flutter/material.dart';

class MusicService with ChangeNotifier {
  bool _notification = false;

  bool get notification => _notification;

  upNotification(bool val) {
    _notification = val;
    notifyListeners();
  }
}
