import 'dart:async';
import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:hive/hive.dart';
import 'package:music_app_v3/screens/now_playing_page.dart';
import '../constant.dart';
import '../widgets/music_slider.dart';
import 'package:rxdart/rxdart.dart';


class PlayingPage extends StatefulWidget {
  static String id = '/f';
  final String sentFrom;
  final Function updateList;
  final List<SongInfo> playlist;
  const PlayingPage({
    this.sentFrom,
    this.updateList,
    this.playlist,
  });
  @override
  _PlayingPageState createState() => _PlayingPageState();
}

class _PlayingPageState extends State<PlayingPage> with WidgetsBindingObserver {
   int currentIndex;
   SongInfo currentSongDetail;

  double sliderVal = 0.0;
  bool changing = false;
  double sliderMin = 0.0;
  bool favorite = false;
  bool singleLoop = false;
  bool loopAll = false;
   DateTime currentPosition;
  IconData loopIcon = Icons.repeat;
  int t = 0;
  bool shuffle = false;
   MediaItem currentMediaItem;

   MediaItem music;
   MediaItem shuffleMusic;
  int _count = 0;

  Future<List<SongInfo>> getSongFromPlaylist(PlaylistInfo playlist) async {
    List<SongInfo> song =
        await audioQuery.getSongsFromPlaylist(playlist: playlist);
    return song;
  }

   

  @override
  Widget build(BuildContext context) {
    print('_count: $_count');
    _count++;

    return Scaffold(
      //backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: <Widget>[
              StreamBuilder<MediaItem>(
                  stream: AudioService.currentMediaItemStream,
                  initialData: AudioService.currentMediaItem,
                  builder: (context, snapshot) {
                    return Positioned(
                      top: 0,
                      child: snapshot.data.artUri != null
                          ? Image.file(
                              File(
                                snapshot.data.artUri.path,
                              ),
                              height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width,
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.none,
                              gaplessPlayback: true,
                            )
                          : Container(
                              color: Colors.black,
                              height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width,
                              child: Center(
                                child: Icon(
                                  FeatherIcons.music,
                                  color: Colors.white,
                                ),
                              )),
                    );
                  }),
              Container(
                decoration: BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.61)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      FeatherIcons.arrowLeft,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (
                              context,
                              animation,
                              secondaryAnimation,
                            ) {
                              return NowPlayingPage();
                            },
                            transitionDuration: Duration(milliseconds: 500),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                          ));
                    },
                    icon: Icon(
                      FeatherIcons.list,
                      color: Colors.white,
                      size: 20,
                    ),
                  )
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Column(
                  children: <Widget>[
                    StreamBuilder<SliderState>(
                      initialData: SliderState(
                        AudioService.playbackState.position,
                        AudioService.currentMediaItem,
                        AudioService.playbackState,
                      ),
                      stream: Rx.combineLatest3<dynamic, dynamic, dynamic,
                          SliderState>(
                        AudioService.positionStream,
                        AudioService.currentMediaItemStream,
                        AudioService.playbackStateStream,
                        (
                          position,
                          mediaItem,
                          playState,
                        ) =>
                            SliderState(
                          position,
                          mediaItem,
                          playState,
                        ),
                      ),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        SliderState sliderState = snapshot.data;

                        final MediaItem currentMediaItem =
                            sliderState.mediaItem;

                        final PlaybackState playbackState =
                            sliderState.playbackState;
                        final Duration position = sliderState.position;

                        return Column(
                          children: [
                            MusicSlider(
                              onChanged: (val) {
                                changing = true;
                                if (sliderVal != val) {
                                  sliderVal = val;
                                }
                              },
                              onChangeEnd: (val) async {
                                print(val.toInt());
                                AudioService.seekTo(
                                    Duration(milliseconds: val.toInt()));
                                print(
                                    AudioService.playbackState.currentPosition);
                                /* await Provider.of<MusicService>(context)
                                .seek(val.toInt());
                                */

                                await Future.delayed(
                                  Duration(milliseconds: 1000),
                                  () {
                                    sliderVal = AudioService.playbackState
                                        .currentPosition.inMilliseconds
                                        .toDouble();

                                    changing = false;
                                  },
                                );
                              },
                              sliderVal: sliderVal,
                              changing: changing,
                              favorite: favorite,
                              onFavorite: () async {
                                /*    await Provider.of<MusicService>(context,
                                        listen: false)
                                    .addSongToPlaylist(
                                        '1', currentMediaItem.extras['songId']); */
                              },
                              checkIfFavorite: () {},
                              playing: playbackState.playing,
                              currentMediaItem: currentMediaItem,
                              position: position,
                              playbackState: playbackState,
                            ),
                          ],
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 0, left: 25, right: 25, bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          IconButton(
                            onPressed: () async {
                              /*  // print(AudioService.queue.last.title);
                                    if (shuffleMode == '1') {
                                      Provider.of<MusicService>(context,
                                              listen: false)
                                          .shuffleSong(
                                              AudioServiceShuffleMode.none);
                                    } else {
                                      Provider.of<MusicService>(context,
                                              listen: false)
                                          .shuffleSong(
                                              AudioServiceShuffleMode.all);
                                    } */
                            },
                            icon: Icon(
                              Icons.shuffle,
                              color:
                                  /*  shuffleMode != '0'
                                  ? Colors.orange
                                  : */
                                  Colors.white,
                              size: 22,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              /* print(loopMode);
                              switch (loopMode) {
                                     case '0':
                                      Provider.of<MusicService>(context,
                                              listen: false)
                                          .loopSong(AudioServiceRepeatMode.all);
                                      break;
                                    case '1':
                                      Provider.of<MusicService>(context,
                                              listen: false)
                                          .loopSong(AudioServiceRepeatMode.one);
                                      break;
                                    case '2':
                                      Provider.of<MusicService>(context,
                                              listen: false)
                                          .loopSong(
                                              AudioServiceRepeatMode.none);
                                      break;
                                    default:
                                    } */
                            },
                            icon: Icon(
                              /*  loopMode != '2' ? Icons.repeat :  */ Icons
                                  .repeat_one,
                              size: 22,
                              color /* : loopMode != '0'
                                  ? Colors.orange */
                                  : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SliderState {
  final Duration position;
  final MediaItem mediaItem;
  final PlaybackState playbackState;

  SliderState(this.position, this.mediaItem, this.playbackState);
}
