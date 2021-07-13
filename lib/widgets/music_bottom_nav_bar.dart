import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:music_app_v3/screens/playing.dart';
import 'package:music_app_v3/widgets/circular_music_button.dart';

class MusicBottomNavBar extends StatelessWidget {
  final String currentSong;
  final String currentArtist;
  final String currentAlbumArt;
  final MediaItem currentMediaItem;
  final bool playing;

  const MusicBottomNavBar({
    @required this.currentSong,
    @required this.currentArtist,
    @required this.currentAlbumArt,
    @required this.currentMediaItem,
    @required this.playing,
  });

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return PlayingPage();
            },
          ),
        );
      },
      child: Container(
        height: 65,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).accentColor,
        ),
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                PhysicalModel(
                  elevation: 9,
                  shadowColor: Color.fromRGBO(0, 0, 0, 0.23),
                  borderRadius: BorderRadius.circular(3),
                  color: Color(0xFFE6E6E6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3.5),
                    child: currentAlbumArt != null
                        ? Image.file(
                            File(currentAlbumArt),
                            errorBuilder: (context, error, stackTrace) {
                              print(error);
                              return SizedBox(
                                height: 45,
                                width: 42.5,
                                child: Icon(
                                  FeatherIcons.music,
                                  size: 18,
                                  color: Color(0xFF5C5C5C),
                                ),
                              );
                            },
                            fit: BoxFit.fitHeight,
                            height: 40,
                            width: 40,
                            filterQuality: FilterQuality.none,
                            cacheHeight: 65,
                            cacheWidth: 65,
                            gaplessPlayback: true,
                          )
                        : SizedBox(
                            height: 40,
                            width: 40,
                            child: Icon(
                              FeatherIcons.music,
                              color: Color(0xFF5C5C5C),
                            ),
                          ),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 155,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          currentSong != null ? currentSong : '',
                          textScaleFactor: 0.85,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          currentArtist,
                          textScaleFactor: 0.85,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            CircularMusicButton(
              icon: playing == true ? FeatherIcons.pause : Icons.play_arrow,
              borderWidth: 1.5,
              iconSize: 19,
              borderColor: Colors.white,
              buttonSize: 40,
              onPressed: () async {
                print('_playing: $playing');
                if (playing == false) {
                  await AudioService.play();
                } else if (playing == true) {
                  await AudioService.pause();
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
