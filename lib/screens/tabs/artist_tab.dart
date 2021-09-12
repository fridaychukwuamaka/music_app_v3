import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:music_app_v3/screens/template.dart';
import 'package:music_app_v3/widgets/album_item.dart';

import '../../constant.dart';

class ArtistTab extends StatefulWidget {
  @override
  _ArtistTabState createState() => _ArtistTabState();
}

class _ArtistTabState extends State<ArtistTab> {
  List<ArtistInfo> artist = [];

  void initState() {
    getArtistList();
    super.initState();
  }

  ///This function get the artist on the device
  getArtistList() async {
    var temp = await audioQuery.getArtists();
    setState(() {
      artist = temp;
    });
    //print(temp.last);
  }

  ///This function get list of songs from an album
  Future<List<SongInfo>> getSongFromArtist(String artistId) async {
    List<SongInfo> songs = await audioQuery.getSongsFromArtist(
      artistId: artistId,
    );
    return songs;
  }

  ///this function plays the selected song
  playSong(int artistIndex) async {
    int index = 0;
    var songs = await getSongFromArtist(artist[artistIndex].id);
    var temp = await kSongInfoToMediaItem(songs[index], 0);
    await AudioService.playMediaItem(temp);
    await AudioService.updateMediaItem(temp);
    var list = kSongInfoListToMediaItemList(songs, currentSongIndex: 0);
    list[index] = temp;
    await AudioService.updateQueue(list);
  }

  @override
  Widget build(BuildContext context) {
    if (artist.isNotEmpty) {
      return GridView.builder(
          itemCount: artist.length,
          padding: EdgeInsets.only(left: 30, right: 30, top: 25, bottom: 25),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 0.75,
              crossAxisCount: 2,
              crossAxisSpacing: 25,
              mainAxisSpacing: 25),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () async {
                List<SongInfo> songs =
                    await getSongFromArtist(artist[index].id);

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return TemplatePage(
                        albumId: artist[index].id,
                        typeOfTemplate: 'artist',
                        songList: songs,
                        title: artist[index].name,
                        albumIndex: index,
                        artWork: artist[index].artistArtPath,
                      );
                    },
                  ),
                );
              },
              child: AlbumItem(
                playButton: true,
                item: artist[index],
                typeOfAlbumItem: 'artist',
                onPressed: () async {
                  playSong(index);
                },
                icon: Icons.play_arrow,
                title: artist[index].name,
                albumArtwork: artist[index].artistArtPath,
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
