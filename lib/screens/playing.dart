import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:music_app_v3/screens/now_playing_page.dart';
import 'package:music_app_v3/utils/utils.dart';
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

  MediaItem currentMediaItem;

  MediaItem music;
  MediaItem shuffleMusic;
  int _count = 0;

  bool shuffleMode = false;

  Future<List<SongInfo>> getSongFromPlaylist(PlaylistInfo playlist) async {
    List<SongInfo> song =
        await audioQuery.getSongsFromPlaylist(playlist: playlist);
    return song;
  }

  @override
  Widget build(BuildContext context) {
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
                    return FutureBuilder<Uint8List>(
                        future: FlutterAudioQuery().getArtwork(
                          type: ResourceType.SONG,
                          id: snapshot.data.extras['songId'],
                        ),
                        builder: (context, snapshot) {
                          return Positioned(
                            top: 0,
                            child: snapshot.hasData && snapshot.data.isNotEmpty
                                ? Image.memory(
                                    snapshot.data,
                                    height: MediaQuery.of(context).size.height,
                                    width: MediaQuery.of(context).size.width,
                                    fit: BoxFit.cover,
                                    filterQuality: FilterQuality.medium,
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
                        });
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
                                AudioService.seekTo(
                                    Duration(milliseconds: val.toInt()));

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
                              onFavorite: () async {},
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
                          ValueListenableBuilder(
                              valueListenable: Hive.box('shuffle').listenable(),
                              builder: (BuildContext context, Box value,
                                  Widget child) {
                                bool isShuffled;
                                if (value.isNotEmpty) {
                                  isShuffled = value.get('shuffle');
                                }
                                return IconButton(
                                  onPressed: () async {
                                    if (isShuffled == true) {
                                      value.put('shuffle', false);

                                      var val = await Hive.box('initialSongs')
                                          .get('initialSongs');

                                      dynamic originalSong = json.decode(val);

                                      originalSong = List<MediaItem>.from(
                                          originalSong
                                              .map((e) => MediaItem.fromJson(e))
                                              .toList());

                                      AudioService.updateQueue(originalSong);
                                    } else {
                                      value.put('shuffle', true);

                                      String originalSong =
                                          json.encode(AudioService.queue);

                                      await Hive.box('initialSongs')
                                          .put('initialSongs', originalSong);

                                      List<MediaItem> shuffledSong =
                                          shuffle(AudioService.queue);

                                      shuffledSong.removeWhere((element) =>
                                          element.id ==
                                          AudioService.currentMediaItem.id);

                                      shuffledSong.insert(
                                          0, AudioService.currentMediaItem);

                                      await AudioService.updateQueue(
                                          shuffledSong);
                                    }
                                  },
                                  icon: Icon(
                                    Icons.shuffle,
                                    color: isShuffled == true
                                        ? Colors.orange
                                        : Colors.white,
                                    size: 22,
                                  ),
                                );
                              }),

                          /// LOOP STATUS:
                          /// 0: OFF
                          /// 1: LOOPONE
                          /// 2: LOOPALL
                          ValueListenableBuilder(
                              valueListenable: Hive.box('loop').listenable(),
                              builder: (BuildContext context, Box value,
                                  Widget child) {
                                dynamic loop;
                                if (value.isNotEmpty) {
                                  loop = value.get('loop');
                                }

                                return IconButton(
                                  onPressed: () async {
                                    if (loop == '2') {
                                      await value.put('loop', '0');
                                      await AudioService.setRepeatMode(
                                          AudioServiceRepeatMode.none);
                                    } else if (loop == '1') {
                                      await value.put('loop', '2');
                                      await AudioService.setRepeatMode(
                                          AudioServiceRepeatMode.all);
                                    } else if (loop == '0' || loop == null) {
                                      await value.put('loop', '1');
                                      await AudioService.setRepeatMode(
                                          AudioServiceRepeatMode.one);
                                    }
                                  },
                                  icon: Icon(
                                    loop == '1'
                                        ? Icons.repeat_one
                                        : Icons.repeat,
                                    size: 22,
                                    color: loop != '0' && loop != null
                                        ? Colors.orange
                                        : Colors.white,
                                  ),
                                );
                              }),
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
