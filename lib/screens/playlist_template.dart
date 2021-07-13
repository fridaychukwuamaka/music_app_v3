import 'dart:convert';
import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'package:music_app_v3/constant.dart';
import 'package:music_app_v3/models/music_bar_state.dart';
import 'package:music_app_v3/models/playlist_data.dart';
import 'package:music_app_v3/services/playlist.dart';
import 'package:music_app_v3/widgets/music_app_bar.dart';
import 'package:music_app_v3/widgets/music_bottom_nav_bar.dart';
import 'package:music_app_v3/widgets/music_list_item.dart';
import 'package:rxdart/rxdart.dart';

class PlaylistTemplatePage extends StatefulWidget {
  final String typeOfTemplate;
  final String playlistId;
  final String artWork;
  final String title;
  final List<dynamic> toTemplateList;
  final List<String> memberIds;
  final int playlistIndex;
  final Function() onShuffle;
  final List<SongInfo> songList;

  PlaylistTemplatePage({
    @required this.playlistId,
    @required this.typeOfTemplate,
    @required this.songList,
    @required this.artWork,
    @required this.title,
    @required this.playlistIndex,
    this.onShuffle,
    this.toTemplateList,
    @required this.memberIds,
  });
  @override
  _PlaylistTemplatePageState createState() => _PlaylistTemplatePageState();
}

class _PlaylistTemplatePageState extends State<PlaylistTemplatePage>
    with WidgetsBindingObserver {
  List<SongInfo> songList = [];

  @override
  void initState() {
    songList = widget.songList;
    super.initState();
  }

  @override
  didChangeDependencies() async {
    super.didChangeDependencies();
  }

  IconData _albumIcon(
      Map playingAlbum, dynamic albumId, String type, bool playing) {
    print(playing);
    return playingAlbum['id'] == albumId &&
            playingAlbum['type'] == type &&
            playing == true
        ? Icons.pause
        : Icons.play_arrow;
  }

  Future getSongFromPlaylistId(String playlistId) async {
    Playlist playlistService = Playlist();
    var playlist = await playlistService.getPlaylist();
    PlaylistData temp = playlist.singleWhere((e) => e.id == playlistId);
    var memberIds = temp.memberIds;
    if (memberIds.isEmpty) return [];

    List<SongInfo> songs = await audioQuery.getSongsById(
      ids: memberIds,
      sortType: SongSortType.CURRENT_IDs_ORDER,
    );

    songList = songs;

    print('${listEquals(songs, songList)} not equal');

    if (listEquals<SongInfo>(songs, songList) == false) {
      setState(() {
        songList = songs;
      });
    }
  }

  playSong(List<SongInfo> song, int index) async {
    var temp = kSongInfoToMediaItem(song[index], index);
    await AudioService.playMediaItem(temp);
    await AudioService.updateMediaItem(temp);
    var list = kSongInfoListToMediaItemList(song, currentSongIndex: index);
    await AudioService.updateQueue(list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
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
                            image: widget.artWork != null
                                ? FileImage(
                                    File(widget.artWork),
                                  )
                                : AssetImage(kPlaceHolderImage),
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
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          1000),
                                                ),
                                                constraints: BoxConstraints(
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
                                            widget.typeOfTemplate ==
                                                        'playlist' &&
                                                    widget.title != 'Liked'
                                                ? SizedBox(
                                                    width: 40,
                                                  )
                                                : SizedBox.shrink(),
                                            widget.typeOfTemplate ==
                                                        'playlist' &&
                                                    widget.title != 'Liked'
                                                ? Tooltip(
                                                    message: 'Delete playlist',
                                                    child: RawMaterialButton(
                                                      onPressed: () async {
                                                        Navigator.pop(context);
                                                      },
                                                      fillColor: Colors.orange,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          1000)),
                                                      constraints:
                                                          BoxConstraints(
                                                              maxHeight: 65,
                                                              maxWidth: 65),
                                                      child: Center(
                                                        child: Icon(
                                                          Icons.delete,
                                                          color: Colors.white,
                                                          semanticLabel:
                                                              'Delete playlist',
                                                          textDirection:
                                                              TextDirection.ltr,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : SizedBox.shrink(),
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
                                widget.title,
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
                              songList.length > 1
                                  ? '${songList.length} Songs'
                                  : '${songList.length} Song',
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
                bottom: 0,
                child: Container(
                  height: MediaQuery.of(context).size.height - 369,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: <Widget>[
                      ValueListenableBuilder(
                          valueListenable: Hive.box('playlist').listenable(),
                          builder: (context, value, child) {
                            var playlist;
                            final temp = value.get('playlist');
                            if (temp != null) {
                              playlist = json.decode(temp);
                            }
                            print('playlist');

                            getSongFromPlaylistId(
                                playlist[widget.playlistIndex]['id']);

                            return Container(
                              height: MediaQuery.of(context).size.height - 369,
                              width: MediaQuery.of(context).size.width,
                              child: StreamBuilder<MediaItem>(
                                stream: AudioService.currentMediaItemStream,
                                builder: (context, snapshot) {
                                  return ListView.builder(
                                    padding: EdgeInsets.only(
                                        top: 40,
                                        left: 20,
                                        right: 20,
                                        bottom: 20),
                                    itemCount: songList.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return MusicListItem(
                                        onClick: () {
                                          playSong(songList, index);
                                        },
                                        subtitleTextColor: Colors.black,
                                        titleTextColor: Colors.black,
                                        title: songList[index].title,
                                        artist: songList[index].artist,
                                        color: Color(0xFFE6E6E6),
                                        iconColor: Color(0xFF5C5C5C),
                                        albumArt: songList[index]
                                                        .albumArtwork !=
                                                    null &&
                                                songList[index].albumArtwork !=
                                                    null
                                            ? songList[index].albumArtwork
                                            : null,
                                        song: songList[index],
                                        songIndex: index,
                                        page: widget.typeOfTemplate,
                                        textAreaLength:
                                            MediaQuery.of(context).size.width -
                                                175,
                                        thePlaying: snapshot.data?.id ==
                                            songList[index].filePath,
                                      );
                                    },
                                  );
                                },
                              ),
                            );
                          }),
                    ],
                  ),
                ),
              ),
              Positioned(
                  top: 255,
                  left: (MediaQuery.of(context).size.width * 0.5) - 40,
                  right: (MediaQuery.of(context).size.width * 0.5) - 40,
                  child: GestureDetector(
                    onTap: () async {
                      playSong(songList, 0);
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
                                      color: Color.fromRGBO(255, 165, 0, 0.4),
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
          ),
        ),
      ),
      bottomNavigationBar: StreamBuilder<MusicBarState>(
        stream: Rx.combineLatest2<PlaybackState, MediaItem, MusicBarState>(
          AudioService.playbackStateStream,
          AudioService.currentMediaItemStream,
          (playbackState, currentMediaItem) => MusicBarState(
            playbackState,
            currentMediaItem,
          ),
        ),
        builder: (context, snapshot) {
          MusicBarState musicBarState = snapshot.data;
          final MediaItem currentMediaItem = musicBarState?.mediaItem;
          final PlaybackState playbackState = musicBarState?.playbackState;

          return MusicBottomNavBar(
            currentAlbumArt: currentMediaItem?.artUri?.path ?? '',
            currentArtist: currentMediaItem?.artist ?? '',
            currentSong: currentMediaItem?.title ?? '',
            currentMediaItem: currentMediaItem,
            playing: playbackState?.playing ?? false,
          );
        },
      )
      /*  : SizedBox.shrink() */,
    );
  }
}
