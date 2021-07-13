import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:music_app_v3/constant.dart';
import 'package:music_app_v3/widgets/music_list_item.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';

// create a FlutterAudioQuery instance.


class SongTab extends StatefulWidget {
  const SongTab({
    Key key,
  }) : super(key: key);

  @override
  _SongTabState createState() => _SongTabState();
}

class _SongTabState extends State<SongTab> {
  List<SongInfo> songs = [];
  @override
  void initState() {
    getSongList();
    super.initState();
  }

  ///This function get the songs on the device
  getSongList() async {
    var temp = await audioQuery.getSongs();
    setState(() {
      songs = temp;
    });
    print(songs.last);
  }

  ///this function plays the selected song
  playSong(List<SongInfo> song, int index) async {
    var temp = kSongInfoToMediaItem(song[index], index);
    await AudioService.playMediaItem(temp);
    await AudioService.updateMediaItem(temp);
    var list = kSongInfoListToMediaItemList(song, currentSongIndex: index);
    await AudioService.updateQueue(list);
  }

  @override
  Widget build(BuildContext context) {
    if (songs.isNotEmpty) {
      return ListView.builder(
        itemCount: songs.length,
        padding: EdgeInsets.only(left: 30, right: 15, top: 25, bottom: 10),
        itemBuilder: (BuildContext context, int index) {
          return MusicListItem(
            textAreaLength: MediaQuery.of(context).size.width - 229,
            color: Color(0xFFE6E6E6),
            iconColor: Color(0xFF5C5C5C),
            thePlaying:true,
            title: songs[index].title,
            albumArt: songs[index].albumArtwork,
            artist: songs[index].artist,
            song: songs[index],
            
            songIndex: index,
            songList: songs,
            onClick: () {
              playSong(songs, index);
            },
            subtitleTextColor: Colors.black,
            titleTextColor: Colors.black,
          );
        },
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
