import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:music_app_v3/screens/template.dart';
import 'package:music_app_v3/widgets/album_item.dart';

import '../../constant.dart';

class ArtistTab extends StatefulWidget {
  const ArtistTab({Key key, @required this.artist}) : super(key: key);

  @override
  _ArtistTabState createState() => _ArtistTabState();
  final List artist;
}

class _ArtistTabState extends State<ArtistTab> {
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
    var songs = await getSongFromArtist(widget.artist[artistIndex].id);
    var temp = await kSongInfoToMediaItem(songs[index], 0);
    await AudioService.playMediaItem(temp);
    await AudioService.updateMediaItem(temp);
    var list = await kSongInfoListToMediaItemList(songs, currentSongIndex: 0);
    list[index] = temp;
    await AudioService.updateQueue(list);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.artist.isNotEmpty) {
      return GridView.builder(
          itemCount: widget.artist.length,
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
                    await getSongFromArtist(widget.artist[index].id);

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return TemplatePage(
                        albumId: widget.artist[index].id,
                        typeOfTemplate: 'artist',
                        songList: songs,
                        title: widget.artist[index].name,
                        albumIndex: index,
                        artWork: getArtistArtPath(widget.artist[index].id),
                      );
                    },
                  ),
                );
              },
              child: AlbumItem(
                playButton: true,
                item: widget.artist[index],
                typeOfAlbumItem: 'artist',
                onPressed: () async {
                  playSong(index);
                },
                icon: Icons.play_arrow,
                title: widget.artist[index].name,
                albumArtwork: widget.artist[index].artistArtPath == null
                    ? getArtistArtPath(widget.artist[index].id)
                    : widget.artist[index].artistArtPath,
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
