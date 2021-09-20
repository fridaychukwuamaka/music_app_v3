import 'dart:async';
import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:uuid/uuid.dart';

final FlutterAudioQuery audioQuery = FlutterAudioQuery();

var uuid = Uuid();

const String kPlaceHolderImage = 'assets/images/mink-mingle-HRyjETL87Gg-unsplash.jpg';

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

  var img = await audioQuery.getArtwork(type: ResourceType.SONG, id: song.id);

  Uri artworkUri;

  if (img != null) {
    final tempDir = await getTemporaryDirectory();
    final File file = await new File('${tempDir.path}/${song.albumId}.jpg').create();
    file.writeAsBytesSync(img, mode: FileMode.writeOnlyAppend);
    artworkUri = file.uri;
  } else {
    artworkUri = null;
  }

  MediaItem mediaItem = MediaItem(
    id: id,
    album: song.album,
    title: song.title,
    artist: song.artist,
    artUri: artworkUri,
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
  List<SongInfo> songList, {
  int currentSongIndex,
}) async {
  List<MediaItem> queue = [];

  queue = await Stream.fromIterable(songList).asyncMap((e) async {
    final String id = uuid.v4();
    var img = await audioQuery.getArtwork(type: ResourceType.SONG, id: e.id);

    final tempDir = await getTemporaryDirectory();
    final file = await new File('${tempDir.path}/${e.id}.jpg').create();
    file.writeAsBytesSync(img, mode: FileMode.append);

    return MediaItem(
      id: id,
      album: e.album,
      title: e.title,
      artist: e.artist,
      artUri: file.uri,
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
