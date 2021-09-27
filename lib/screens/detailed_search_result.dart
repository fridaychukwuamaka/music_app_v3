import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:music_app_v3/screens/template.dart';
import 'package:music_app_v3/widgets/album_item.dart';
import 'package:music_app_v3/widgets/music_app_bar.dart';
import 'package:music_app_v3/widgets/music_list_item.dart';

import 'dart:async';
import 'package:audio_service/audio_service.dart';

import '../constant.dart';

final FlutterAudioQuery audioQuery = FlutterAudioQuery();

class DetailedSearchResult extends StatefulWidget {
  static String id = 'hgfd/';

  const DetailedSearchResult({this.title, this.type, this.list});
  final String title;
  final List list;
  final String type;

  @override
  _DetailedSearchResultState createState() => _DetailedSearchResultState();
}

class _DetailedSearchResultState extends State<DetailedSearchResult>
    with WidgetsBindingObserver {
  Future<List<SongInfo>> getSongFromAlbum(albumId) async {
    List<SongInfo> song = await audioQuery.getSongsFromAlbum(
      albumId: albumId,
      sortType: SongSortType.SMALLER_TRACK_NUMBER,
    );
    return song;
  }

  Future<List<SongInfo>> getSongFromArtist(artistId) async {
    List<SongInfo> song = await audioQuery.getSongsFromArtist(
      artistId: artistId,
      sortType: SongSortType.ALPHABETIC_ALBUM,
    );
    return song;
  }

  Future<List<SongInfo>> getSongFromPlaylist(List<String> memberIds) async {
    List<SongInfo> songs = await audioQuery.getSongsById(
      ids: memberIds,
      sortType: SongSortType.CURRENT_IDs_ORDER,
    );

    return songs;
  }

  bool playing;

  MediaItem currentMediaItem;
  StreamSubscription _currentMediaStream, _playStateStream;

  @override
  void initState() {
    connect();

    super.initState();
  }

  @override
  didChangeDependencies() {
    connect();
    super.didChangeDependencies();
  }

  connect() async {
    await AudioService.connect();
    if (_currentMediaStream == null) {
      _currentMediaStream = AudioService.currentMediaItemStream.listen(
        (d) {
          if (d != currentMediaItem) {
            setState(() {
              currentMediaItem = d;
            });
          }
        },
      );
    }
    if (_playStateStream == null) {
      _playStateStream = AudioService.playbackStateStream
          .where((event) => playing != event.playing)
          .listen((e) {
        setState(() {
          playing = e.playing;
        });
      });
    }
  }

  Future<void> playSong(List song, int index) async {
    MediaItem temp = await kSongInfoToMediaItem(song[index], index);
    await AudioService.playMediaItem(temp);
    await AudioService.updateMediaItem(temp);
    List<MediaItem> list =
        await kSongInfoListToMediaItemList(song, currentSongIndex: index);
    list[index] = temp;
    await AudioService.updateQueue(list);
  }

  IconData _albumIcon(Map playingAlbum, dynamic album, String type) {
    return playingAlbum['id'] == album.id &&
            playingAlbum['type'] == type &&
            playing == true
        ? Icons.pause
        : Icons.play_arrow;
  }

  disconnect() {
    if (_currentMediaStream != null) {
      _currentMediaStream.cancel();
      _currentMediaStream = null;
    }
    if (_playStateStream != null) {
      _playStateStream.cancel();
      _playStateStream = null;
    }

    //AudioService.disconnect();
  }

  @override
  void deactivate() {
    disconnect();
    super.deactivate();
  }

  @override
  dispose() {
    print('dispose11');
    disconnect();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            MusicAppBar(
              title: '',
              iconSize: 16,
              leadingIcon: FeatherIcons.arrowLeft,
              trailingIcon: FeatherIcons.moreVertical,
              padding: true,
              onleadingIconPressed: () {
                Navigator.pop(context);
              },
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 35),
              child: Text(
                widget.title,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              height: 0.5,
              color:
                  /*Provider.of<MusicService>(context).kKolor(
                      context: context,
                      darkTheme: Colors.white24,
                      lightTheme: Colors.black26),
                */
                  Colors.black26,
            ),
            widget.type == 'songs'
                ? Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.only(top: 20, left: 25, right: 25),
                      itemCount: widget.list.length,
                      itemBuilder: (BuildContext context, int index) {
                        return StreamBuilder<Object>(
                          stream: AudioService.currentMediaItemStream,
                          builder: (context, snapshot) {
                             MediaItem currentMediaItem = snapshot?.data;
                              final song =  widget.list[index];
                            return MusicListItem(
                              title: widget.list[index].title,
                              albumArt: getAlbumArtPath(widget.list[index].albumId),
                              artist: widget.list[index].artist,
                              song: widget.list[index],
                              songIndex: index,
                              textAreaLength:
                                  MediaQuery.of(context).size.width - 175,
                             thePlaying: kIfSongIsPlaying(
                                    currentMediaItem, song.filePath),
                              onClick: () async {
                                playSong(widget.list, index);
                              },
                              subtitleTextColor: Colors.black,
                              titleTextColor: Colors.black,
                            );
                          }
                        );
                      },
                    ),
                  )
                : Expanded(
                    child: GridView.builder(
                    padding: EdgeInsets.all(30),
                    itemCount: widget.list.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        childAspectRatio: 0.75,
                        crossAxisCount: 2,
                        crossAxisSpacing: 25,
                        mainAxisSpacing: 25),
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () async {
                          var result;

                          if (widget.type == 'album') {
                            result =
                                await getSongFromAlbum(widget.list[index].id);
                          } else if (widget.type == 'artist') {
                            result =
                                await getSongFromArtist(widget.list[index].id);
                          } else if (widget.type == 'playlist') {
                            result = await getSongFromPlaylist(
                                widget.list[index].memberIds);
                          }
                          // var result =
                          //     await getSongFromAlbum(widget.list[index].id);

                          // Provider.of<MusicService>(context)
                          //     .setCurrentSongList(result);

                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return TemplatePage(
                              songList: result,
                              title: widget.type == 'artist'
                                  ? widget.list[index].name
                                  : widget.type == 'album'
                                      ? widget.list[index].title
                                      : widget.list[index].name,
                              artWork: getAlbumArt(widget.list[index],
                                  template: true),
                              albumIndex: index,
                              typeOfTemplate: widget.type,
                              toTemplateList: widget.list,
                              albumId: widget.list[index].id,
                            );
                          }));
                        },
                        child: AlbumItem(
                          title: widget.type == 'artist'
                              ? widget.list[index].name
                              : widget.type == 'playlist'
                                  ? widget.list[index].name
                                  : widget.list[index].title,
                          toAlbumItemList: widget.list,
                          albumArtwork: getAlbumArt(widget.list[index]),
                          typeOfAlbumItem: widget.type,
                          item: widget.list[index],
                          index: index,
                          playButton: true,
                          icon: Icons.ac_unit,
                          onPressed: () async {},
                          borderRadius: BorderRadius.circular(5),
                        ),
                      );
                    },
                  ))
          ],
        ),
      ),
    );
  }

  getAlbumArt(item, {template}) {
    if (widget.type == 'album' && item.albumArt == null) {
      return getAlbumArtPath(item.id);
    } else if (widget.type == 'album' && item.albumArt != null) {
      return item.albumArt;
    } else if (widget.type == 'artist' && item.artistArtPath == null) {
      return getArtistArtPath(item.id);
    } else if (widget.type == 'album' && item.artistArtPath != null) {
      return item.artistArtPath;
    } else if (widget.type == 'playlist' && template != true) {
      return '';
    }
  }
}
