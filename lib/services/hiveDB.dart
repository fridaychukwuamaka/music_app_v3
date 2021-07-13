import 'dart:convert';
import 'package:hive/hive.dart';

class HiveDB {
  

   Future setPlaylist(dynamic val) async {
    var _ = json.encode(val);
    var box = await Hive.openBox('playlist');
    await box.put('playlist', _);
  }

  Future getPlaylist() async {
    var box = await Hive.openBox('playlist');

    if (box.isEmpty && box == null) return null;

    var val = box.get('playlist');
    if (val == null) return [];
    return json.decode(val);
  }
}