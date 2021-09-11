import 'dart:convert';
import 'dart:math';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:music_app_v3/services/playlist.dart';

class MusicSlider extends StatelessWidget {
  final Function(double) onChanged;
  final Function(double) onChangeEnd;
  final Function onFavorite;
  final Function checkIfFavorite;
  final MediaItem currentMediaItem;
  final PlaybackState playbackState;
  final Duration position;
  final double sliderVal;
  final bool changing;
  final bool favorite;
  final bool playing;

  const MusicSlider({
    this.onChanged,
    this.onChangeEnd,
    @required this.sliderVal,
    @required this.changing,
    this.playing,
    this.onFavorite,
    this.favorite,
    this.checkIfFavorite,
    @required this.currentMediaItem,
    @required this.playbackState,
    this.position,
  });

  String toDateString(int val) {
    var currentPosition = DateTime.fromMillisecondsSinceEpoch(val);

    return DateFormat('mm:ss', 'en_US').format(currentPosition);
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      currentMediaItem.title,
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
                    /* SizedBox(
                                  height: 5,
                                ), */

                    Row(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            // showArtists(context, currentMediaItem, 'playing');
                          },
                          child: Container(
                            constraints: BoxConstraints(
                                maxWidth:
                                    (MediaQuery.of(context).size.width - 221) /
                                        2),
                            child: Text(
                              (currentMediaItem.artist != null
                                  ? currentMediaItem.artist
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
                                color: Colors.white, shape: BoxShape.circle),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // showAlbums(context, currentMediaItem, 'playing');
                          },
                          child: Container(
                            constraints: BoxConstraints(
                                maxWidth:
                                    (MediaQuery.of(context).size.width - 221) /
                                        2),
                            child: Text(
                              currentMediaItem.album != null
                                  ? currentMediaItem.album
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
                ),
              ),
              ValueListenableBuilder(
                valueListenable: Hive.box('playlist').listenable(),
                builder: (BuildContext context, Box value, Widget child) {
                  dynamic favorite = json.decode(value.get('playlist'));

                  //print(favorite);

                  favorite = favorite.singleWhere(
                    (element) =>
                        element['name'].toLowerCase() == 'liked'.toLowerCase(),
                  )['memberIds'];

                  String songId = currentMediaItem.extras['songId'];

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
              ),
            ],
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Slider.adaptive(
            value: !changing ? position.inMilliseconds.toDouble() : sliderVal,
            onChanged: onChanged,
            onChangeEnd: onChangeEnd,
            min: 0,
            max: max(
              position.inMilliseconds.toDouble(),
              currentMediaItem.duration.inMilliseconds.toDouble(),
            )),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                toDateString(playbackState.currentPosition.inMilliseconds),
                textScaleFactor: 0.85,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
              Text(
                toDateString(currentMediaItem?.duration?.inMilliseconds ?? 0),
                textScaleFactor: 0.85,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        Padding(
          padding:
              const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            //crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              IconButton(
                onPressed: () async {
                  await AudioService.skipToPrevious();
                  //Provider.of<MusicService>(context).previousSong();
                  // checkIfFavorite();
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
              RawMaterialButton(
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
              ),
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
