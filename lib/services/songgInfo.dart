import 'package:flutter/foundation.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';

/// SongInfo class holds all information about a specific song audio file.
class MySongInfo {
  const MySongInfo({
    @required this.albumId,
    @required this.artistId,
    @required this.artist,
    @required this.album,
    @required this.title,
    @required this.displayName,
    @required this.composer,
    @required this.year,
    @required this.track,
    @required this.duration,
    @required this.bookmark,
    @required this.filePath,
    this.uri,
    @required this.fileSize,
    @required this.albumArtwork,
    this.isMusic,
    this.id,
    this.isPodcast,
    this.isRingtone,
    this.isAlarm,
    this.isNotification,
  });

  /// Returns the album id which @required this song appears.
  final String albumId;

  /// Returns the artist id who create @required this audio file.
  final String artistId;

  /// Returns the artist name who create @required this audio file.
  final String artist;

  /// Returns the album title which @required this song appears.
  final String album;

  // Returns the genre name which @required this song belongs.
  //String  genre => _data['genre_name'];

  /// Returns the song title.
  final String title;
  final String id;

  /// Returns the song display name. Display name string
  /// is a combination of [Track number] + [Song title] [File extension]
  /// Something like 1 My pretty song.mp3
  final String displayName;

  /// Returns the composer name of @required this song.
  final String composer;

  /// Returns the year of @required this song was created.
  final String year;

  /// Returns the album track number if @required this song has one.
  final String track;

  /// Returns a String with a number in milliseconds (ms) that is the duration of @required this audio file.
  final String duration;

  /// Returns in ms, playback position when @required this song was stopped.
  /// from the last time.
  final String bookmark;

  /// Returns a String with a file path to audio data file
  final String filePath;

  final String uri;

  /// Returns a String with the size, in bytes, of @required this audio file.
  final String fileSize;

  ///Returns album artwork path which current song appears.
  final String albumArtwork;

  final bool isMusic;

  final bool isPodcast;

  final bool isRingtone;

  final bool isAlarm;

  final bool isNotification;

  static MySongInfo fromSongInfo(SongInfo song, {String albumArtwork}) {
    print('sfkdfkdm${song.albumArtwork}');
    return MySongInfo(
      albumId: song.albumId,
      artistId: song.artistId,
      artist: song.artist,
      album: song.album,
      title: song.title,
      displayName: song.displayName,
      composer: song.composer,
      year: song.year,
      track: song.track,
      duration: song.duration,
      bookmark: song.bookmark,
      filePath: song.filePath,
      id: song.id,
      fileSize: song.fileSize,
      albumArtwork: song.albumArtwork ?? albumArtwork,
    );
  }
}
