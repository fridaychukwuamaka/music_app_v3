import 'dart:async';
import 'dart:convert';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:music_app_v3/services/playlist.dart';

class MusicSlider extends StatefulWidget {
  const MusicSlider();

  @override
  _MusicSliderState createState() => _MusicSliderState();
}

class _MusicSliderState extends State<MusicSlider> {
  StreamSubscription positionStream;
  bool changing = false;
  double slideVal = 0;
  Duration songDuration = Duration.zero;

  String toDateString(int val) {
    var currentPosition = DateTime.fromMillisecondsSinceEpoch(val);

    return DateFormat('mm:ss', 'en_US').format(currentPosition);
  }

  @override
  void initState() {
    connectPosition();

    super.initState();
  }

  connectPosition() {
    positionStream = AudioService.positionStream.listen((event) {
      setState(() {
        songDuration = AudioService?.currentMediaItem?.duration;
      });
      if (!changing) {
        setState(() {
          slideVal = event?.inMilliseconds?.toDouble();
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    positionStream.cancel();
    connectPosition();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    if (positionStream != null) {
      positionStream.cancel();
      positionStream = null;
    }
    super.dispose();
  }

  @override
  void deactivate() {
    dispose();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 25.0, left: 25.0, right: 25.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: MediaQuery.of(context).size.width - 200,
                child: StreamBuilder<MediaItem>(
                    stream: AudioService.currentMediaItemStream,
                    builder: (context, snapshot) {
                      final MediaItem currentMediaItem = snapshot?.data;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            currentMediaItem?.title ?? '',
                            textScaleFactor: 0.85,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 33,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Pacifico',
                            ),
                          ),
                          Row(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  // showArtists(context, currentMediaItem, 'playing');
                                },
                                child: Container(
                                  constraints: BoxConstraints(
                                      maxWidth:
                                          (MediaQuery.of(context).size.width -
                                                  221) /
                                              2),
                                  child: Text(
                                    (currentMediaItem?.artist != null
                                        ? currentMediaItem?.artist
                                        : ''),
                                    maxLines: 1,
                                    textScaleFactor: 0.85,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 7),
                                child: Container(
                                  height: 7,
                                  width: 7,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // showAlbums(context, currentMediaItem, 'playing');
                                },
                                child: Container(
                                  constraints: BoxConstraints(
                                      maxWidth:
                                          (MediaQuery.of(context).size.width -
                                                  221) /
                                              2),
                                  child: Text(
                                    currentMediaItem?.album != null
                                        ? currentMediaItem?.album
                                        : '',
                                    textScaleFactor: 0.85,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }),
              ),
              StreamBuilder<MediaItem>(
                  stream: AudioService.currentMediaItemStream,
                  builder: (context, snapshot) {
                    return ValueListenableBuilder(
                      valueListenable: Hive.box('playlist').listenable(),
                      builder: (BuildContext context, Box value, Widget child) {
                        dynamic favorite = json.decode(value.get('playlist'));

                        //print(favorite);

                        favorite = favorite.singleWhere(
                          (element) =>
                              element['name'].toLowerCase() ==
                              'liked'.toLowerCase(),
                        )['memberIds'];

                        String songId = snapshot?.data?.extras['songId'];

                        return IconButton(
                          onPressed: () async {
                            final Playlist playlistService = Playlist();

                            var isFav = favorite.contains(songId);
                            if (isFav) {
                              await playlistService.removeSongFromFavorite(
                                'liked',
                                songId,
                              );
                            } else {
                              await playlistService.addSongToFavorite(songId);
                            }
                          },
                          icon: Icon(
                            favorite.contains(songId)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 25,
                            color: Colors.orange,
                          ),
                        );
                      },
                    );
                  }),
            ],
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Slider.adaptive(
          value: slideVal,
          onChanged: (val) async {
            setState(() {
              changing = true;
              slideVal = val;
            });
          },
          onChangeEnd: (val) async {
            AudioService.seekTo(Duration(milliseconds: val.toInt()));
            setState(() {
              changing = false;
            });

            /* await Future.delayed(
                    Duration(milliseconds: 1000),
                    () {
                      sliderVal = AudioService
                          .playbackState.currentPosition.inMilliseconds
                          .toDouble();

                      changing = false;
                    },
                  ); */
          },
          min: 0,
          max: slideVal > songDuration?.inMilliseconds?.toDouble()
              ? slideVal
              : songDuration?.inMilliseconds?.toDouble(),
        ),
        StreamBuilder<Duration>(
            stream: AudioService.positionStream,
            builder: (context, snapshot) {
              final Duration position = snapshot?.data;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      toDateString(position?.inMilliseconds ?? 0),
                      textScaleFactor: 0.85,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      toDateString(AudioService
                              ?.currentMediaItem?.duration?.inMilliseconds ??
                          0),
                      textScaleFactor: 0.85,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            }),
        Padding(
          padding:
              const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                onPressed: () async {
                  await AudioService.skipToPrevious();
                },
                icon: Icon(
                  FeatherIcons.skipBack,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(
                width: 40,
              ),
              StreamBuilder<PlaybackState>(
                  stream: AudioService.playbackStateStream,
                  builder: (context, snapshot) {
                    bool playing = snapshot?.data?.playing ?? false;
                    return RawMaterialButton(
                      onPressed: () async {
                        if (playing == true) {
                          await AudioService.pause();
                        } else {
                          await AudioService.play();
                        }
                      },
                      constraints: BoxConstraints.tightForFinite(),
                      padding: EdgeInsets.all(15),
                      shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: Colors.orange,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(100000)),
                      child: Icon(
                        playing == true ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 27,
                      ),
                    );
                  }),
              SizedBox(
                width: 40,
              ),
              IconButton(
                onPressed: () async {
                  await AudioService.skipToNext();
                  // checkIfFavorite();
                },
                icon: Icon(
                  FeatherIcons.skipForward,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
