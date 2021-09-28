import 'dart:async';
import 'dart:io';
import 'package:audio_service/audio_service.dart';

import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:uuid/uuid.dart';

final FlutterAudioQuery audioQuery = FlutterAudioQuery();

var uuid = Uuid();

const String kPlaceHolderImage =
    'assets/images/mink-mingle-HRyjETL87Gg-unsplash.jpg';

String getAlbumArtPath(String albumId) {
  final tempDir = Directory.systemTemp;
  return '${tempDir.path}/album-$albumId.png';
}

String getArtistArtPath(String albumId) {
  final tempDir = Directory.systemTemp;
  return '${tempDir.path}/artist-$albumId.png';
}

bool kIfSongIsPlaying(MediaItem currentMediaItem, String songPath) {
  if (currentMediaItem?.extras?.containsKey('filePath') == true) {
    if (currentMediaItem.extras['filePath'] == songPath) {
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}

extension CapExtension on String {
  String get inCaps =>
      this.length > 0 ? '${this[0].toUpperCase()}${this.substring(1)}' : '';
  String get allInCaps => this.toUpperCase();
  String get capitalizeFirstofEach => this
      .replaceAll(RegExp(' +'), ' ')
      .split(" ")
      .map((str) => str.inCaps)
      .join(" ");
}

Future<MediaItem> kSongInfoToMediaItem(song, int index) async {
  final String id = uuid.v4();

  print(song.albumArtwork);

  MediaItem mediaItem = MediaItem(
    id: id,
    album: song.album,
    title: song.title,
    artist: song.artist,
    artUri: song.albumArtwork == null
        ? Uri.file(getAlbumArtPath(song.albumId))
        : Uri.file(song.albumArtwork),
    duration: Duration(milliseconds: int.parse(song.duration)),
    extras: {
      'albumId': song.albumId,
      'artistId': song.artistId,
      'songId': song.id,
      'filePath': song.filePath,
      'index': id,
    },
  );

  return mediaItem;
}

Future<List<MediaItem>> kSongInfoListToMediaItemList(
  List songList, {
  int currentSongIndex,
}) async {
  List<MediaItem> queue = songList.map((e) {
    final String id = uuid.v4();
    return MediaItem(
      id: id,
      album: e.album,
      title: e.title,
      artist: e.artist,
      artUri: e.albumArtwork == null
          ? Uri.file(getAlbumArtPath(e.albumId))
          : Uri.file(e.albumArtwork),
      duration: Duration(milliseconds: int.parse(e.duration)),
      extras: {
        'albumId': e.albumId,
        'songId': e.id,
        'artistId': e.artistId,
        'filePath': e.filePath,
        'index': id,
      },
    );
  }).toList();

  return queue;
}
