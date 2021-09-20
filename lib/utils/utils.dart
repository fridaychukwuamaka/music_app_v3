import 'dart:math';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:hive/hive.dart';
import 'package:music_app_v3/models/playlist_data.dart';
import 'package:music_app_v3/services/playlist.dart';

final FlutterAudioQuery flutterAudioQuery = FlutterAudioQuery();

List shuffle(List items) {
  var random = new Random();

  // Go through all elements.
  for (var i = items.length - 1; i > 0; i--) {
    // Pick a random number according to the list length
    var n = random.nextInt(i + 1);

    var temp = items[i];
    items[i] = items[n];
    items[n] = temp;
  }

  return items;
}

Future<void> setLoopMode() async {
  var loopMode = await Hive.box('loop').get('loop');
  print(loopMode);
  if (loopMode == '0' || loopMode == null) {
    await AudioService.setRepeatMode(AudioServiceRepeatMode.none);
  } else if (loopMode == '1') {
    await AudioService.setRepeatMode(AudioServiceRepeatMode.one);
  } else {
    await AudioService.setRepeatMode(AudioServiceRepeatMode.all);
  }
}

Future<List<SongInfo>> searchSongs({String query}) async {
  List<SongInfo> songs = await flutterAudioQuery.getSongs();
  List<SongInfo> searchedSongs = [];

  searchedSongs = songs
      .where((e) => e.title.toLowerCase().contains(query.trim().toLowerCase()))
      .toList();
  return searchedSongs;
}

Future<List<AlbumInfo>> searchAlbums({String query}) async {
  List<AlbumInfo> albums = await flutterAudioQuery.getAlbums();
  List<AlbumInfo> searchedAlbums = [];

  searchedAlbums = albums
      .where((e) => e.title.toLowerCase().contains(query.trim().toLowerCase()))
      .toList();

  return searchedAlbums;
}

Future<List<PlaylistData>> searchPlayList({String query}) async {
  List<PlaylistData> playLists = await Playlist().getPlaylist();
  List<PlaylistData> searchedPlaylists = [];
  playLists
      .where((e) => e.name.toLowerCase().contains(query.trim().toLowerCase()));
  return searchedPlaylists;
}

Future<List<ArtistInfo>> searchArtist({String query}) async {
  List<ArtistInfo> albums = await flutterAudioQuery.getArtists();
  List<ArtistInfo> searchedArtisit = [];
  searchedArtisit = albums
      .where((e) => e.name.toLowerCase().contains(query.trim().toLowerCase()))
      .toList();
  return searchedArtisit;
}

Future<Map<String, dynamic>> searchAppForSong(query) async {
  var song = await searchSongs(query: query);
  var album = await searchAlbums(query: query);
  var artist = await searchArtist(query: query);
  var playlist = await searchPlayList(query: query);
  Map<String, dynamic> result = {
    'songs': song,
    'album': album,
    'artist': artist,
    'playlist': playlist,
  };

  if (song.isEmpty && album.isEmpty && playlist.isEmpty && artist.isEmpty) {
    return null;
  }
  return result;
}
