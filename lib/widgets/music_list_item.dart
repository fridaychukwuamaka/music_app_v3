import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:music_app_v3/constant.dart';
import 'package:music_app_v3/widgets/music_playlist_modal.dart';

enum MusicItemMenu { playnext, addtoque, showalbum, delete }

class MusicListItem extends StatelessWidget {
  final String title;
  final String artist;
  final String albumArt;
  final double textAreaLength;
  final String page;
  final Color iconColor;
  final dynamic song;
  final List songList;
  final int songIndex;
  final moreIconVisible;
  final Color titleTextColor;
  final Color subtitleTextColor;
  final Color color;
  final Function() onClick;

  final bool thePlaying;

  const MusicListItem({
    @required this.title,
    @required this.artist,
    this.albumArt,
    this.song,
    this.page,
    this.songIndex,
    this.songList,
    @required this.textAreaLength,
    @required this.thePlaying,
    @required this.onClick,
    this.color,
    @required this.titleTextColor,
    @required this.subtitleTextColor,
    this.iconColor,
    this.moreIconVisible: true,
  });

  playNext() {
    int index = AudioService.queue.indexWhere(
      (element) {
        return element.extras['index'] ==
            AudioService.currentMediaItem.extras['index'];
      },
    );
    index++;
    var temp = kSongInfoToMediaItem(song, songIndex);
    AudioService.addQueueItemAt(temp, index);
  }

  addToQueue() {
    int index = AudioService.queue.length;
    index = index + 1;
    var temp = kSongInfoToMediaItem(song, index);
    AudioService.addQueueItem(temp);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      onLongPress: () {},
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                PhysicalModel(
                  elevation: 5,
                  shadowColor: Color.fromRGBO(0, 0, 0, 0.23),
                  borderRadius: BorderRadius.circular(3),
                  color: color == null ? Colors.black : color,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: albumArt != null && albumArt != ''
                        ? Image.file(
                            File(albumArt),
                            fit: BoxFit.fitHeight,
                            height: 45,
                            errorBuilder: (context, error, stackTrace) {
                              print(error);
                              return SizedBox(
                                height: 45,
                                width: 42.5,
                                child: Icon(
                                  FeatherIcons.music,
                                  size: 18,
                                  color: iconColor == null
                                      ? Colors.white
                                      : iconColor,
                                ),
                              );
                            },
                            width: 42.5,
                            filterQuality: FilterQuality.none,
                            cacheHeight: 85,
                            cacheWidth: 85,
                            gaplessPlayback: true,
                          )
                        : SizedBox(
                            height: 45,
                            width: 42.5,
                            child: Icon(
                              FeatherIcons.music,
                              size: 18,
                              color:
                                  iconColor == null ? Colors.white : iconColor,
                            ),
                          ),
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                Container(
                  width: textAreaLength,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 3,
                      ),
                      Text(
                        title != null ? title : 'Songs',
                        textScaleFactor: 0.9,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        softWrap: true,
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: titleTextColor == null
                                ? Colors.black
                                : titleTextColor),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        artist != null ? artist : 'Artist',
                        textScaleFactor: 0.9,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: subtitleTextColor == null
                                ? Colors.black
                                : subtitleTextColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                thePlaying
                    ? Container(
                        height: 7,
                        width: 7,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      )
                    : SizedBox.shrink(),
                PopupMenuButton(
                  icon: !moreIconVisible
                      ? SizedBox.shrink()
                      : Icon(
                          Icons.more_vert,
                          size: 20,
                          color: subtitleTextColor == null
                              ? Colors.black
                              : subtitleTextColor,
                        ),
                  onSelected: (value) async {
                    switch (value) {
                      case 0:
                        playNext();
                        break;
                      case 1:
                        addToQueue();
                        break;
                      case 5:
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (BuildContext context) => MusicPlaylistModal(
                            songIds: [song.id],
                          ),
                        );
                        break;
                      default:
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return <PopupMenuEntry>[
                      PopupMenuItem(
                        child: Text(
                          'Play next',
                          textScaleFactor: 0.9,
                        ),
                        value: 0,
                      ),
                      PopupMenuDivider(),
                      PopupMenuItem(
                        child: Text(
                          'Add to queue',
                          textScaleFactor: 0.9,
                        ),
                        value: 1,
                      ),
                      PopupMenuDivider(),
                      PopupMenuItem(
                        child: Text(
                          'Add to playlist',
                          textScaleFactor: 0.9,
                        ),
                        value: 5,
                      ),
                      PopupMenuDivider(),
                      page == 'now_playing'
                          ? PopupMenuItem(
                              child: Text(
                                'Remove from queue',
                                textScaleFactor: 0.9,
                              ),
                              value: 3,
                            )
                          : PopupMenuItem(
                              child: SizedBox.shrink(),
                              height: 0,
                            ),
                      page == 'now_playing'
                          ? PopupMenuDivider()
                          : PopupMenuItem(
                              child: SizedBox.shrink(),
                              height: 0,
                            ),
                      PopupMenuItem(
                        child: Text(
                          'Show Album',
                          textScaleFactor: 0.9,
                        ),
                        value: 2,
                      ),
                      page == 'playlist'
                          ? PopupMenuDivider()
                          : PopupMenuItem(
                              child: SizedBox.shrink(),
                              height: 0,
                            ),
                      page == 'playlist'
                          ? PopupMenuItem(
                              child: Text(
                                'Remove from playlist',
                                textScaleFactor: 0.9,
                              ),
                              value: 4,
                            )
                          : PopupMenuItem(height: 0, child: SizedBox.shrink()),
                      page != 'now_playing'
                          ? PopupMenuDivider()
                          : PopupMenuItem(
                              child: SizedBox.shrink(),
                              height: 0,
                            ),
                      page != 'now_playing'
                          ? PopupMenuItem(
                              child: Text(
                                'Delete',
                                textScaleFactor: 0.9,
                              ),
                              value: 6,
                            )
                          : PopupMenuItem(child: SizedBox.shrink()),
                    ];
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
