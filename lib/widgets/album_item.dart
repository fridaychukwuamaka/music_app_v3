import 'dart:typed_data';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:hive/hive.dart';
import 'package:music_app_v3/constant.dart';
import 'package:music_app_v3/models/playlist_data.dart';
import 'package:music_app_v3/utils/utils.dart';
import 'package:music_app_v3/widgets/music_playlist_modal.dart';

class AlbumItem extends StatefulWidget {
  const AlbumItem({
    this.width,
    @required this.playButton,
    this.title,
    this.albumArtwork,
    this.icon,
    this.onPressed,
    @required this.borderRadius,
    this.artist,
    @required this.typeOfAlbumItem,
    this.index,
    this.height,
    this.onShuffle,
    this.toAlbumItemList,
    this.item,
  });
  final double width;
  final double height;
  final bool playButton;
  final dynamic item;
  final String artist;
  final String typeOfAlbumItem;
  final BorderRadius borderRadius;
  final String title;
  final int index;
  final List toAlbumItemList;
  final String albumArtwork;
  final IconData icon;
  final Function() onPressed;
  final Function() onShuffle;
  @override
  _AlbumItemState createState() => _AlbumItemState();
}

class _AlbumItemState extends State<AlbumItem> {
  Future shuffleAndPlaySong() async {
    bool isShuffle = await Hive.box('shuffle').get('shuffle');
    // checks if the sheffle state is true if true it makes it false
    if (isShuffle == true) {
      await Hive.box('shuffle').put('shuffle', false);
    }
    var songs = await getSongFromItem();

    MediaItem temp = await kSongInfoToMediaItem(songs[0], 0);

    await AudioService.playMediaItem(temp);

    await AudioService.updateMediaItem(temp);

    List<MediaItem> list =
        await kSongInfoListToMediaItemList(songs, currentSongIndex: 0);
    list[0] = temp;

    List<MediaItem> shuffledSong = shuffle(list);

    await AudioService.updateQueue(shuffledSong);
  }

  Future getSongFromItem() async {
    switch (widget.typeOfAlbumItem) {
      case 'album':
        var album = widget.item as AlbumInfo;
        return await audioQuery.getSongsFromAlbum(albumId: album.id);
        break;
      case 'artist':
        var artist = widget.item as ArtistInfo;
        return await audioQuery.getSongsFromArtist(artistId: artist.id);
        break;

      case 'playlist':
        var playlist = widget.item as PlaylistData;
        return await audioQuery.getSongsById(ids: playlist.memberIds);
        break;
      default:
    }
  }

  playNext() async {
    List<SongInfo> songs = await getSongFromItem();
    List<MediaItem> mediaItemSongs = await kSongInfoListToMediaItemList(songs);
    var queue = AudioService.queue;

    int index = AudioService.queue.indexWhere(
      (element) {
        return element.id == AudioService.currentMediaItem.id;
      },
    );
    index++;
    queue.insertAll(index, mediaItemSongs);
    AudioService.updateQueue(queue);
  }

  addToQueue() async {
    List<SongInfo> songs = await getSongFromItem();
    List<MediaItem> mediaItemSongs = await kSongInfoListToMediaItemList(songs);
    AudioService.addQueueItems(mediaItemSongs);
  }

  String hasImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius,
        color: Color(0xFFE6E6E6),
        boxShadow: widget.albumArtwork != null
            ? [
                BoxShadow(
                  offset: Offset(0, 3),
                  blurRadius: 6,
                  color: Color.fromRGBO(0, 0, 0, 0.16),
                )
              ]
            : null,
      ),
      child: Stack(
        children: <Widget>[
          FutureBuilder<Uint8List>(
              future: FlutterAudioQuery().getArtwork(
                type: widget.typeOfAlbumItem == 'album'
                    ? ResourceType.ALBUM
                    : ResourceType.ARTIST,
                id: widget.item.id,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data.isNotEmpty) {
                  hasImage = '';
                } else {
                  hasImage = null;
                }
                return ClipRRect(
                  borderRadius: widget.borderRadius,
                  child: snapshot.hasData && snapshot.data.isNotEmpty
                      ? SizedBox.expand(
                          child: Image.memory(
                            snapshot.data,
                            errorBuilder: (context, error, stackTrace) =>
                                Center(
                              child: SizedBox(
                                height: 45,
                                width: 45,
                                child: Icon(
                                  widget.typeOfAlbumItem == 'album'
                                      ? FeatherIcons.disc
                                      : widget.typeOfAlbumItem == 'artist'
                                          ? FeatherIcons.user
                                          : Icons.playlist_play,
                                  color: Color(0xFF5C5C5C),
                                  size: 33,
                                ),
                              ),
                            ),
                            fit: BoxFit.fitHeight,
                            filterQuality: FilterQuality.none,
                            cacheHeight: 200,
                            cacheWidth: 200,
                            gaplessPlayback: true,
                          ),
                        )
                      : Center(
                          child: SizedBox(
                            height: 45,
                            width: 45,
                            child: Icon(
                              widget.typeOfAlbumItem == 'album'
                                  ? FeatherIcons.disc
                                  : widget.typeOfAlbumItem == 'artist'
                                      ? FeatherIcons.user
                                      : Icons.playlist_play,
                              size: 33,
                              color: Color(0xFF5C5C5C),
                            ),
                          ),
                        ),
                );
              }),
          Container(
            decoration: BoxDecoration(
              gradient: widget.albumArtwork != null
                  ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Color.fromRGBO(0, 0, 0, 0.2),
                        Color.fromRGBO(0, 0, 0, 0.52),
                      ],
                    )
                  : null,
              borderRadius: widget.borderRadius,
            ),
          ),
          Positioned(
            right: 10,
            bottom: 45,
            child: widget.playButton
                ? InkWell(
                    onTap: widget.onPressed,
                    child: Container(
                      padding: EdgeInsets.all(3.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.orange,
                      ),
                      child: Icon(
                        widget.icon,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          ),
          Positioned(
            left: -10,
            child: PopupMenuButton(
              icon: Icon(
                Icons.more_vert,
                size: 20,
                color: hasImage != null ? Colors.white : Colors.black,
              ),
              onSelected: (value) async {
                switch (value) {
                  case 0:
                    shuffleAndPlaySong();
                    break;
                  case 1:
                    playNext();
                    break;
                  case 2:
                    addToQueue();
                    break;
                  case 3:
                    var songs = await getSongFromItem() as List<SongInfo>;
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (BuildContext context) => MusicPlaylistModal(
                        songIds: songs.map((e) => e.id).toList(),
                      ),
                    );
                    break;
                  default:
                }
              },
              offset: Offset(50, 150),
              itemBuilder: (BuildContext context) {
                return <PopupMenuEntry>[
                  PopupMenuItem(
                    child: Text(
                      'Shuffle',
                      textScaleFactor: 0.9,
                    ),
                    value: 0,
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem(
                    child: Text(
                      'Play next',
                      style: TextStyle(fontSize: 14),
                    ),
                    value: 1,
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem(
                    child: Text(
                      'Add to queue',
                      textScaleFactor: 0.9,
                      style: TextStyle(fontSize: 14),
                    ),
                    value: 2,
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem(
                    child: Text(
                      'Add to playlist',
                      textScaleFactor: 0.9,
                      style: TextStyle(fontSize: 14),
                    ),
                    value: 3,
                  ),

                  widget.typeOfAlbumItem == 'playlist' &&
                          widget.title != 'Liked'
                      ? PopupMenuDivider()
                      : PopupMenuItem(
                          height: 0,
                          child: SizedBox.shrink(),
                        ),
                  widget.typeOfAlbumItem == 'playlist' &&
                          widget.title != 'Liked'
                      ? PopupMenuItem(
                          child: Text(
                            'Delete',
                            textScaleFactor: 0.9,
                            style: TextStyle(fontSize: 14),
                          ),
                          value: 4,
                        )
                      : PopupMenuItem(
                          height: 0,
                          child: SizedBox.shrink(),
                        ),
                  //PopupMenuDivider(),
                ];
              },
            ),
          ),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.only(
                    bottom: 15, left: 10, right: 10, top: 5),
                child: Text(
                  widget.title,
                  textScaleFactor: 0.9,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyText1.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: hasImage != null ? Colors.white : Colors.black,
                      ),
                ),
              ))
        ],
      ),
    );
  }
}
