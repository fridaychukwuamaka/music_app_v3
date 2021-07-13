import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:uuid/uuid.dart';
final FlutterAudioQuery audioQuery = FlutterAudioQuery();

var uuid = Uuid();

const String kPlaceHolderImage = 'assets/images/baby.jpg';

extension CapExtension on String {
  String get inCaps => this.length > 0 ?'${this[0].toUpperCase()}${this.substring(1)}':'';
  String get allInCaps => this.toUpperCase();
  String get capitalizeFirstofEach => this.replaceAll(RegExp(' +'), ' ').split(" ").map((str) => str.inCaps).join(" ");
}

MediaItem kSongInfoToMediaItem(SongInfo song, int index) {
  MediaItem mediaItem = MediaItem(
    id: song.filePath,
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
      'index': index.toString(),
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
      (e) => MediaItem(
        id: e.filePath,
        album: e.album,
        title: e.title,
        artist: e.artist,
        artUri: Uri.parse(
            e.albumArtwork  != null ? File(e.albumArtwork).uri.toString() : ''),
        duration: Duration(milliseconds: int.parse(e.duration)),
        extras: {
          'albumId': e.albumId,
          'songId': e.id,
          'index': songList.indexOf(e) == currentSongIndex
              ? songList.indexOf(e).toString()
              : uuid.v4()
        },
      ),
    ),
  );
  print(queue[0].extras);

  return queue;
}
