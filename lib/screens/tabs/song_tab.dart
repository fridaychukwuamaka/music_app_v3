import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:music_app_v3/constant.dart';
import 'package:music_app_v3/widgets/music_list_item.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';

// create a FlutterAudioQuery instance.

class SongTab extends StatefulWidget {
  const SongTab({
    Key key,
    @required this.songs,
  }) : super(key: key);

  final List songs;

  @override
  _SongTabState createState() => _SongTabState();
}

class _SongTabState extends State<SongTab> {
  ///this function plays the selected song
  Future<void> playSong(List<SongInfo> song, int index) async {
    MediaItem temp = await kSongInfoToMediaItem(song[index], index);
    await AudioService.playMediaItem(temp);
    await AudioService.updateMediaItem(temp);
    List<MediaItem> list =
        await kSongInfoListToMediaItemList(song, currentSongIndex: index);
    list[index] = temp;
    await AudioService.updateQueue(list);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.songs.isNotEmpty) {
      return ListView.builder(
        itemCount: widget.songs.length,
        padding: EdgeInsets.only(left: 30, right: 15, top: 10, bottom: 10),
        itemBuilder: (BuildContext context, int index) {
          return StreamBuilder<MediaItem>(
              stream: AudioService.currentMediaItemStream,
              builder: (context, snapshot) {
                MediaItem currentMediaItem = snapshot?.data;
                //print(snapshot.data);
                return MusicListItem(
                  textAreaLength: MediaQuery.of(context).size.width - 229,
                  color: Color(0xFFE6E6E6),
                  iconColor: Color(0xFF5C5C5C),
                  thePlaying: kIfSongIsPlaying(
                      currentMediaItem, widget.songs[index].filePath),
                  title: widget.songs[index].title,
                  albumArt: widget.songs[index].albumArtwork,
                  artist: widget.songs[index].artist,
                  song: widget.songs[index],
                  songIndex: index,
                  songList: widget.songs,
                  onClick: () async {
                    await playSong(widget.songs, index);
                  },
                  subtitleTextColor: Colors.black,
                  titleTextColor: Colors.black,
                );
              });
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
