import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:music_app_v3/constant.dart';
import 'package:music_app_v3/models/playlist_data.dart';
import 'package:music_app_v3/screens/playing.dart';
import 'package:music_app_v3/services/playlist.dart';
import 'package:music_app_v3/widgets/music_app_bar.dart';
import 'package:music_app_v3/widgets/music_bottom_nav_bar.dart';
import 'package:music_app_v3/widgets/music_list_item.dart';

class PlaylistTemplatePage extends StatefulWidget {
  final PlaylistData playlist;

  PlaylistTemplatePage({
    @required this.playlist,
  });
  @override
  _PlaylistTemplatePageState createState() => _PlaylistTemplatePageState();
}

class _PlaylistTemplatePageState extends State<PlaylistTemplatePage>
    with WidgetsBindingObserver {
  Playlist playlistService = Playlist();

  @override
  void initState() {
    super.initState();
  }

  ///This function get the playlist on the device
  Future<List<PlaylistData>> getPlaylist() async {
    var temp = await playlistService.getPlaylist();
    return temp;
  }

  ///This function get list of songs from a playlist
  Future<List<SongInfo>> getSongFromPlaylist(String playlistId) async {
    var playlist = await getPlaylist();
    PlaylistData temp = playlist.singleWhere((e) => e.id == playlistId);
    var memberIds = temp.memberIds;
    if (memberIds.isEmpty) return [];

    List<SongInfo> songs = await audioQuery.getSongsById(
      ids: memberIds,
      sortType: SongSortType.CURRENT_IDs_ORDER,
    );

    return songs;
  }

  IconData _albumIcon(
      Map playingAlbum, dynamic albumId, String type, bool playing) {
    //print(playing);
    return playingAlbum['id'] == albumId &&
            playingAlbum['type'] == type &&
            playing == true
        ? Icons.pause
        : Icons.play_arrow;
  }

  playSong(List<SongInfo> song, int index) async {
    var temp = await kSongInfoToMediaItem(song[index], index);
    await AudioService.playMediaItem(temp);
    await AudioService.updateMediaItem(temp);
    var list =
        await kSongInfoListToMediaItemList(song, currentSongIndex: index);
    list[index] = temp;
    await AudioService.updateQueue(list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: FutureBuilder<List<SongInfo>>(
              initialData: [],
              future: getSongFromPlaylist(widget.playlist.id),
              builder: (context, snapshot) {
                final List<SongInfo> songs = snapshot?.data;

                final int songLength = songs.length;

                return Stack(
                  children: <Widget>[
                    Positioned(
                      top: 0,
                      child: Container(
                        height: 280,
                        width: MediaQuery.of(context).size.width,
                        child: Stack(
                          children: <Widget>[
                            Positioned(
                                child: Container(
                              height: 280,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                      'assets/images/mink-mingle-HRyjETL87Gg-unsplash.jpg'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )),
                            Positioned(
                              child: MusicAppBar(
                                title: '',
                                iconSize: 16,
                                leadingIcon: FeatherIcons.arrowLeft,
                                trailingIcon: FeatherIcons.moreVertical,
                                padding: true,
                                onleadingIconPressed: () {
                                  Navigator.of(context).pop();
                                },
                                ontralingIconPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Scaffold(
                                            backgroundColor:
                                                Color.fromRGBO(0, 0, 0, 0.5),
                                            body: Center(
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Tooltip(
                                                    message: 'Shuffle',
                                                    child: RawMaterialButton(
                                                      onPressed: () {},
                                                      fillColor: Colors.orange,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(1000),
                                                      ),
                                                      constraints:
                                                          BoxConstraints(
                                                        maxHeight: 65,
                                                        maxWidth: 65,
                                                      ),
                                                      child: Center(
                                                        child: Icon(
                                                          FeatherIcons.shuffle,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      });
                                },
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 185,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: <Color>[
                                      Color.fromRGBO(0, 0, 0, 0),
                                      Color.fromRGBO(0, 0, 0, 1),
                                    ])),
                              ),
                            ),
                            Positioned(
                              bottom: 50,
                              left: 0,
                              right: 0,
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(
                                      widget.playlist.name,
                                      textScaleFactor: 0.9,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    songLength > 1
                                        ? '$songLength Songs'
                                        : '$songLength Song',
                                    textScaleFactor: 0.9,
                                    style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 280,
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: StreamBuilder<MediaItem>(
                          stream: AudioService.currentMediaItemStream,
                          builder: (context, snapshot) {
                            return SizedBox(
                              height: double.infinity,
                              width: double.infinity,
                              child: ListView.builder(
                                padding: EdgeInsets.only(
                                    top: 25, left: 20, right: 20, bottom: 10),
                                itemCount: songs?.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return MusicListItem(
                                    onClick: () {
                                      playSong(songs, index);
                                    },
                                    subtitleTextColor: Colors.black,
                                    titleTextColor: Colors.black,
                                    title: songs[index].title,
                                    artist: songs[index].artist,
                                    color: Color(0xFFE6E6E6),
                                    iconColor: Color(0xFF5C5C5C),
                                    albumArt: songs[index].albumArtwork == null
                                        ? getAlbumArtPath(songs[index].albumId)
                                        : songs[index].albumArtwork,
                                    song: songs[index],
                                    songIndex: index,
                                    page: 'playlist',
                                    textAreaLength:
                                        MediaQuery.of(context).size.width - 175,
                                    thePlaying: kIfSongIsPlaying(
                                        snapshot.data, songs[index].filePath),
                                  );
                                },
                              ),
                            );
                          }),
                    ),
                    Positioned(
                        top: 255,
                        left: (MediaQuery.of(context).size.width * 0.5) - 40,
                        right: (MediaQuery.of(context).size.width * 0.5) - 40,
                        child: GestureDetector(
                          onTap: () async {
                            playSong(songs, 0);
                          },
                          child: StreamBuilder<PlaybackState>(
                              initialData: AudioService.playbackState,
                              stream: AudioService.playbackStateStream,
                              builder: (context, snapshot) {
                                return Container(
                                  height: 45,
                                  width: 90,
                                  decoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.circular(100),
                                      boxShadow: [
                                        BoxShadow(
                                            offset: Offset(0, 3),
                                            color: Color.fromRGBO(
                                                255, 165, 0, 0.4),
                                            blurRadius: 4)
                                      ]),
                                  child: Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                );
                              }),
                        )),
                  ],
                );
              }),
        ),
      ),
      bottomNavigationBar: StreamBuilder<MediaItem>(
        stream: AudioService.currentMediaItemStream,
        builder: (context, snapshot) {
          final MediaItem currentMediaItem = snapshot?.data;

          if (currentMediaItem != null) {
            return MusicBottomNavBar(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return PlayingPage();
                    },
                  ),
                );

                setState(() {});
              },
              currentAlbumArt: currentMediaItem?.artUri?.path ?? '',
              currentArtist: currentMediaItem?.artist ?? '',
              currentSong: currentMediaItem?.title ?? '',
              currentMediaItem: currentMediaItem,
            );
          } else {
            return SizedBox.shrink();
          }
        },
      )
      /*  : SizedBox.shrink() */,
    );
  }
}
