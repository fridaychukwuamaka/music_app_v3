import 'dart:io';
import 'dart:typed_data';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:music_app_v3/screens/playing.dart';
import 'package:music_app_v3/widgets/circular_music_button.dart';

class MusicBottomNavBar extends StatelessWidget {
  final String currentSong;
  final String currentArtist;
  final String currentAlbumArt;
  final Stream streams;
  final Function() onTap;
  final MediaItem currentMediaItem;

  const MusicBottomNavBar({
    @required this.currentSong,
    @required this.currentArtist,
    @required this.currentAlbumArt,
    @required this.currentMediaItem,
    this.streams,
    this.onTap,
  });

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (onTap != null) {
          await onTap();
        } else {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return PlayingPage();
              },
            ),
          );
        }
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
             File(currentAlbumArt).existsSync() && File(currentAlbumArt).readAsBytesSync().isNotEmpty  
                    ? Container(
                        height: 45,
                        width: 42.5,
                        decoration: BoxDecoration(
                          color: Color(0xFFE6E6E6),
                          borderRadius: BorderRadius.circular(3),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: FileImage(File(currentAlbumArt)),
                          ),
                        ),
                      ): Container(
                        height: 45,
                        width: 42.5,
                        decoration: BoxDecoration(
                            color: Color(0xFFE6E6E6),
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.23),
                                offset: Offset(0, 2),
                                blurRadius: 2,
                              ),
                            ]),
                        child: Icon(FeatherIcons.music,
                            size: 18, color: Color(0xFF5C5C5C)),
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
            StreamBuilder<PlaybackState>(
                stream: AudioService.playbackStateStream,
                builder: (context, snapshot) {
                  final PlaybackState playbackState = snapshot?.data;
                  return CircularMusicButton(
                    icon: playbackState?.playing ?? false
                        ? FeatherIcons.pause
                        : Icons.play_arrow,
                    borderWidth: 1.5,
                    iconSize: 19,
                    borderColor: Colors.white,
                    buttonSize: 40,
                    onPressed: () async {
                      if (!playbackState.playing) {
                        await AudioService.play();
                      } else if (playbackState.playing) {
                        await AudioService.pause();
                      }
                    },
                  );
                })
          ],
        ),
      ),
    );
  }
}
