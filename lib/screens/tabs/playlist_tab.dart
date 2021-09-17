import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:music_app_v3/models/playlist_data.dart';
import 'package:music_app_v3/screens/playlist_template.dart';
import 'package:music_app_v3/services/playlist.dart';
import 'package:music_app_v3/widgets/album_item.dart';
import '../../constant.dart';

Playlist playlistService = Playlist();

class PlaylistTab extends StatefulWidget {
  @override
  _PlaylistTabState createState() => _PlaylistTabState();
}

class _PlaylistTabState extends State<PlaylistTab> {
  List<PlaylistData> playlist = [];

  void initState() {
    getPlaylist();
    super.initState();
  }

  ///This function get the artist on the device
  getPlaylist() async {
    await createFavoritePlaylist();
    var temp = await playlistService.getPlaylist();
    setState(() {
      playlist = temp;
    });
    //print(temp);
  }

  Future createFavoritePlaylist() async {
    var favorite = PlaylistData(
      name: 'Liked',
      creationDate: DateTime.now().toString(),
      memberIds: [],
      id: uuid.v4(),
    );
    await playlistService.addPlaylist(favorite);
  }

  ///This function get list of songs from a playlist
  Future<List<SongInfo>> getSongFromPlaylist(String playlistId) async {
    PlaylistData temp = playlist.singleWhere((e) => e.id == playlistId);
    var memberIds = temp.memberIds;
    if (memberIds.isEmpty) return [];

    List<SongInfo> songs = await audioQuery.getSongsById(
      ids: memberIds,
      sortType: SongSortType.CURRENT_IDs_ORDER,
    );

    return songs;
  }

  ///this function plays the selected song
  playSong(String playlistId) async {
    int index = 0;
    var songs = await getSongFromPlaylist(playlistId);
    var temp = await kSongInfoToMediaItem(songs[index], 0);
    await AudioService.playMediaItem(temp);
    await AudioService.updateMediaItem(temp);
    var list = await kSongInfoListToMediaItemList(songs, currentSongIndex: 0);
    list[index] = temp;
    await AudioService.updateQueue(list);
  }

  @override
  Widget build(BuildContext context) {
    if (playlist.isNotEmpty) {
      return GridView.builder(
          itemCount: playlist.length,
          padding: EdgeInsets.only(left: 30, right: 30, top: 25, bottom: 25),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: 0.75,
            crossAxisCount: 2,
            crossAxisSpacing: 25,
            mainAxisSpacing: 25,
          ),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () async {
                List<SongInfo> songs =
                    await getSongFromPlaylist(playlist[index].id);

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return PlaylistTemplatePage(
                        playlistId: playlist[index].id,
                        memberIds: playlist[index].memberIds,
                        typeOfTemplate: 'artist',
                        songList: songs,
                        title: playlist[index].name,
                        playlistIndex: index,
                        artWork: null,
                      );
                    },
                  ),
                );
              },
              child: AlbumItem(
                playButton: true,
                item: playlist[index],
                typeOfAlbumItem: 'playlist',
                onPressed: () async {
                  playSong(playlist[index].id);
                },
                icon: Icons.play_arrow,
                title: playlist[index].name,
                albumArtwork: null,
                borderRadius: BorderRadius.circular(5),
              ),
            );
          });
    } else {
      return Center(
        child: CircularProgressIndicator(
          strokeWidth: 1.5,
        ),
      );
    }
  }
}
