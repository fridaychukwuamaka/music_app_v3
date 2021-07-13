import 'package:flutter/cupertino.dart';

class PlayingAlbum {
  const PlayingAlbum({
   @ required this.type,
   @ required this.id,
  });
  final String type;
  final String id;
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
    };
  }
}
