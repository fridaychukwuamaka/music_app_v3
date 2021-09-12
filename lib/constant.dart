import 'dart:io';
import 'dart:typed_data';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:uuid/uuid.dart';

final FlutterAudioQuery audioQuery = FlutterAudioQuery();

var uuid = Uuid();

const String kPlaceHolderImage = 'assets/images/baby.jpg';

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

Future<MediaItem> kSongInfoToMediaItem(SongInfo song, int index) async {
  final String id = uuid.v4();
  MediaItem mediaItem = MediaItem(
    id: id,
    album: song.album,
    title: song.title,
    artist: song.artist,
    artUri: Uri.parse(song.albumArtwork != null
        ? File(song.albumArtwork).uri.toString()
        : ''),
    duration: Duration(milliseconds: int.parse(song.duration)),
    extras: {
      'albumId': song.albumId,
      'songId': song.id,
      'filePath': song.filePath,
      'index': id,
    },
  );

  return mediaItem;
}

List<MediaItem> kSongInfoListToMediaItemList(
  List<SongInfo> songList, {
  int currentSongIndex,
}) {
  List<MediaItem> queue = [];

  queue = List.from(
    songList.map(
      (e) {
        final String id = uuid.v4();
        return MediaItem(
          id: id,
          album: e.album,
          title: e.title,
          artist: e.artist,
          artUri: Uri.parse(e.albumArtwork != null
              ? File(e.albumArtwork).uri.toString()
              : ''),
          duration: Duration(milliseconds: int.parse(e.duration)),
          extras: {
            'albumId': e.albumId,
            'songId': e.id,
            'filePath': e.filePath,
            'index': id,
            // 'songArt': songArt
          },
        );
      },
    ),
  );

  return queue;
}
