import 'package:flutter/material.dart';

class MusicService with ChangeNotifier {
  bool _notification = false;
  Map<String, dynamic> _allItem ={
    'songs': null,
    'album': null,
    'artist': null,
    'playlist': null
  };

  Map<String, dynamic> get allItem => _allItem;

  bool get notification => _notification;

  upNotification(bool val) {
    _notification = val;
    notifyListeners();
  }

  updateItems(Map<String, dynamic> val) {
    _allItem = val;
    notifyListeners();
  }
}
