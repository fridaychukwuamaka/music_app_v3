import 'package:flutter/foundation.dart';

class PlaylistData {
  final String name;
  final String creationDate;
  final List<String> memberIds;
  final String id;

  const PlaylistData({
    @required this.name,
    @required this.creationDate,
    @required this.memberIds,
    @required this.id,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'creationDate': creationDate,
      'memberIds': memberIds
    };
  }

  PlaylistData fromJson() {
    return PlaylistData(
      id: id,
      name: name,
      creationDate: creationDate,
      memberIds: memberIds,
    );
  }
}
