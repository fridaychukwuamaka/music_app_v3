import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:music_app_v3/screens/template.dart';
import 'package:music_app_v3/widgets/album_item.dart';
import '../../constant.dart';

class AlbumTab extends StatefulWidget {
  const AlbumTab({
    Key key,
  }) : super(key: key);

  @override
  _AlbumTabState createState() => _AlbumTabState();
}

class _AlbumTabState extends State<AlbumTab> {
  List<AlbumInfo> albums = [];

  void initState() {
    getAlbumList();
    super.initState();
  }

  ///This function get the albums on the device
  getAlbumList() async {
    var temp = await audioQuery.getAlbums();
    setState(() {
      albums = temp;
    });
    //print(temp.last);
  }

  ///this function plays the selected song
  playSong(int albumIndex) async {
    int index = 0;
    var songs = await getSongFromAlbum(albums[albumIndex].id);
    var temp = await kSongInfoToMediaItem(songs[index], 0);
    await AudioService.playMediaItem(temp);
    await AudioService.updateMediaItem(temp);
    var list = kSongInfoListToMediaItemList(songs, currentSongIndex: 0);
    list[index] = temp;
    await AudioService.updateQueue(list);
  }

  ///This function get list of songs from an album
  Future<List<SongInfo>> getSongFromAlbum(String albumId) async {
    List<SongInfo> songs = await audioQuery.getSongsFromAlbum(
        albumId: albumId, sortType: SongSortType.SMALLER_TRACK_NUMBER);
    return songs;
  }

  @override
  Widget build(BuildContext context) {
    if (albums.isNotEmpty) {
      return GridView.builder(
          itemCount: albums.length,
          padding: EdgeInsets.only(left: 30, right: 30, top: 25, bottom: 25),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 0.75,
              crossAxisCount: 2,
              crossAxisSpacing: 25,
              mainAxisSpacing: 25),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () async {
                List<SongInfo> songs = await getSongFromAlbum(albums[index].id);

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return TemplatePage(
                        albumId: albums[index].id,
                        typeOfTemplate: 'album',
                        songList: songs,
                        title: albums[index].title,
                        albumIndex: index,
                        artWork: albums[index].albumArt,
                      );
                    },
                  ),
                );
              },
              child: StreamBuilder<MediaItem>(
                  stream: AudioService.currentMediaItemStream,
                  builder: (context, snapshot) {
                    return AlbumItem(
                      playButton: true,
                      item: albums[index],
                      typeOfAlbumItem: 'album',
                      onPressed: () async {
                        playSong(index);
                      },
                      icon: snapshot.hasData && snapshot.data.extras['albumId'] == albums[index].id
                          ? Icons.pause
                          :Icons.play_arrow,
                      title: albums[index].title,
                      albumArtwork: albums[index].albumArt,
                      borderRadius: BorderRadius.circular(5),
                    );
                  }),
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
