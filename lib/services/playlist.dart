import 'package:music_app_v3/models/playlist_data.dart';
import 'package:music_app_v3/services/hiveDB.dart';

HiveDB hiveDb = HiveDB();

class Playlist {
  List<PlaylistData> _playlist = [];
  List<PlaylistData> get list => _playlist;

  Future<List<PlaylistData>> getPlaylist() async {
    dynamic val = await hiveDb.getPlaylist();
    return fromJson(val);
  }

  Future addPlaylist(PlaylistData playlist) async {
    _playlist = await getPlaylist();

    var playlistExist = _playlist.indexWhere(
        (element) => element.name.toLowerCase() == playlist.name.toLowerCase());

    if (playlistExist == -1) {
      _playlist.add(playlist);
      hiveDb.setPlaylist(_playlist);
    }
  }

  Future<List<PlaylistData>> removePlaylist(String playlistName) async {
    _playlist = await getPlaylist();
    _playlist.removeWhere((element) => element.name == playlistName);
    hiveDb.setPlaylist(_playlist);
    return _playlist;
  }

  List<Map<String, dynamic>> toJson() {
    return list
        .map(
          (e) => {
            'id': e.id,
            'name': e.name,
            'creationDate': e.creationDate,
            'memberIds': e.memberIds
          },
        )
        .toList();
  }

  Future<List<PlaylistData>> addSong(String playlistId, String songId) async {
    _playlist = await getPlaylist();
    var index = _playlist.indexWhere((e) => e.id == playlistId);
    var check = _playlist[index].memberIds.contains(songId);

    if (check) return _playlist;

    _playlist[index].memberIds.add(songId);
    hiveDb.setPlaylist(_playlist);
    return _playlist;
  }

  Future addSongToFavorite(String songId) async {
    _playlist = await getPlaylist();
    var index = _playlist.indexWhere(
      (e) => e.name.toLowerCase() == 'liked'.toLowerCase(),
    );

    var check = _playlist[index].memberIds.contains(songId);

    if (!check) {
      _playlist[index].memberIds.add(songId);
      hiveDb.setPlaylist(_playlist);
    }
  }

  Future removeSongFromFavorite(
      String playlistName, String songId) async {
    _playlist = await getPlaylist();
    var index = _playlist
        .indexWhere((e) => e.name.toLowerCase() == playlistName.toLowerCase());
    var check = _playlist[index].memberIds.contains(songId);

    if (check) {
      _playlist[index].memberIds.remove(songId);
      hiveDb.setPlaylist(_playlist);
    }
  }

  Future<List<PlaylistData>> addMultipleSongs(
      String playlistId, List<String> songIds) async {
    _playlist = await getPlaylist();
    var index = _playlist.indexWhere((e) => e.id == playlistId);
    /*  var check = _playlist[index].memberIds..contains(songIds);

    if (check) return _playlist; */

    _playlist[index].memberIds.addAll(songIds);
    hiveDb.setPlaylist(_playlist);
    return _playlist;
  }

  Future<List<PlaylistData>> removeSong(
      String playlistName, String songId) async {
    _playlist = await getPlaylist();
    var index = _playlist.indexWhere((e) => e.name == playlistName);
    var check = _playlist[index].memberIds.contains(songId);

    if (!check) return _playlist;

    _playlist[index].memberIds.remove(songId);
    hiveDb.setPlaylist(_playlist);
    return _playlist;
  }

  List<PlaylistData> fromJson(List playlist) {
    //print('list ${playlist[0]['memberIds'].runtimeType}');
    if (playlist.isEmpty) return [];
    return List.from(playlist.map(
      (e) => PlaylistData(
        id: e['id'] as String,
        name: e['name'] as String,
        creationDate: e['creationDate'] as String,
        memberIds: List.from(e['memberIds']),
      ),
    ));
  }
}
