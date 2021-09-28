import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:music_app_v3/models/playlist_data.dart';
import 'package:music_app_v3/screens/playlist_template.dart';
import 'package:music_app_v3/services/music_service.dart';
import 'package:music_app_v3/services/playlist.dart';
import 'package:music_app_v3/widgets/album_item.dart';
import 'package:provider/provider.dart';
import '../../constant.dart';

Playlist playlistService = Playlist();

class PlaylistTab extends StatefulWidget {
  const PlaylistTab({Key key, @required this.playlist}) : super(key: key);

  @override
  _PlaylistTabState createState() => _PlaylistTabState();

  final List playlist;
}


class _PlaylistTabState extends State<PlaylistTab> {
  List playlist;

  void initState() {
    print('object');
    playlist = Provider.of<MusicService>(context, listen: false).allItem['playlist'];
    getPlaylist();
    super.initState();
  }

  getPlaylist() async {
    var val = await playlistService.getPlaylist();
    setState(() {
      playlist = val;
    });
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
    if (widget.playlist != null) {
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
                final List<SongInfo> songs =
                    await getSongFromPlaylist(playlist[index].id);

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return PlaylistTemplatePage(
                        playlist: playlist[index],
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
                title:playlist[index].name,
                albumArtwork: '',
                borderRadius: BorderRadius.circular(5),
              ),
            );
          });
    } else if (playlist != null && playlist.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'No playlist Found',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      );
    } else {
      return Center(
        child: CircularProgressIndicator(
          strokeWidth: 1.5,
        ),
      );
    }
  }
}
