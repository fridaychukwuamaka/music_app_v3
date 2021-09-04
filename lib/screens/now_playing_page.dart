import 'dart:io';
import 'dart:math';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:hive/hive.dart';
import 'package:music_app_v3/widgets/music_list_item.dart';

class NowPlayingPage extends StatefulWidget {
  @override
  _NowPlayingPageState createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage>
    with WidgetsBindingObserver {
  ScrollController _nowPlayingController = ScrollController();

  connect() async {
    if (!AudioService.connected) {
      await AudioService.connect();
    }
  }

  disconnect() {
    if (AudioService.connected) {
      AudioService.disconnect();
    }
  }

  @override
  Widget build(BuildContext context) {
    print('loooo');
    return Scaffold(
      body: SafeArea(
          child: NowplayingMini(
              /* currentAlbumArt: mediaItem?.artUri != null
                    ? mediaItem?.artUri?.split('file://')[1]
                    : null,
                mediaItem: mediaItem,
                currentMediaItem: mediaItem,
                position: position,
                queue: queue,
                songList: queue, */
              controller: _nowPlayingController)),
    );
  }
}

String currentAlbumArt = AudioService?.currentMediaItem?.artUri?.path ?? '';
MediaItem mediaItem = AudioService.currentMediaItem;

class NowplayingMini extends StatelessWidget {
  const NowplayingMini({this.controller});
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    print('hgfdsd');
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            child: currentAlbumArt != null
                ? Image.file(
                    File(
                      currentAlbumArt,
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
                    child: Icon(
                      FeatherIcons.music,
                      color: Colors.white,
                    )),
          ),
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
                  size: 18,
                ),
              ),
            ],
          ),
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              children: <Widget>[
                StreamBuilder<MediaItem>(
                    initialData: AudioService.currentMediaItem,
                    stream: AudioService.currentMediaItemStream,
                    builder: (context, snapshot) {
                      mediaItem = snapshot.data;
                      currentAlbumArt = snapshot?.data?.artUri?.path ?? "";
                      return Padding(
                        padding: const EdgeInsets.only(
                            top: 18, left: 25.0, right: 25.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              width: MediaQuery.of(context).size.width - 150,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      print('djfkhf::${controller.offset}');
                                    },
                                    child: Text(
                                      mediaItem.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textScaleFactor: 0.85,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 40,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Pacifico',
                                      ),
                                    ),
                                  ),
                                  /* SizedBox(
                                height: 5,
                              ), */
                                  Row(
                                    children: <Widget>[
                                      GestureDetector(
                                        onTap: () {
                                          /*  showArtists(
                                            context, currentMediaItem, 'playing'); */
                                        },
                                        child: Container(
                                          constraints: BoxConstraints(
                                              maxWidth: (MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      171) /
                                                  2),
                                          child: Text(
                                            mediaItem.artist ?? '',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textScaleFactor: 0.85,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            EdgeInsets.symmetric(horizontal: 7),
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
                                          /* showAlbums(
                                            context, currentMediaItem, 'playing'); */
                                        },
                                        child: Container(
                                          constraints: BoxConstraints(
                                              maxWidth: (MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      171) /
                                                  2),
                                          child: Text(
                                            mediaItem.album,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textScaleFactor: 0.85,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                SizedBox(
                  height: 3,
                ),
                StreamBuilder<Duration>(
                    initialData: AudioService.playbackState.position,
                    stream: AudioService.positionStream,
                    builder: (context, snapshot) {
                      final Duration position = snapshot.data;
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(25, 25, 25, 10),
                        child: SliderTheme(
                          child: Slider.adaptive(
                            value: position.inMilliseconds.toDouble(),
                            onChanged: (val) {},
                            onChangeEnd: (val) async {},
                            min: 0,
                            max: max(
                              position.inMilliseconds.toDouble(),
                              mediaItem?.duration?.inMilliseconds?.toDouble() ??
                                  0,
                            ),
                          ),
                          data: SliderThemeData().copyWith(
                            thumbShape:
                                RoundSliderThumbShape(enabledThumbRadius: 0),
                            trackHeight: 1.5,
                            trackShape: RectangularSliderTrackShape(),
                            overlayShape:
                                RoundSliderOverlayShape(overlayRadius: 0),
                            activeTrackColor: Colors.orange,
                            thumbColor: Colors.orange,
                            overlayColor: Color.fromRGBO(255, 165, 0, 0.16),
                            inactiveTrackColor:
                                Color.fromRGBO(255, 165, 0, 0.46),
                          ),
                        ),
                      );
                    }),
                StreamBuilder<List<MediaItem>>(
                    initialData: AudioService.queue ?? [],
                    stream: AudioService.queueStream,
                    builder: (context, snapshot) {
                      final List<MediaItem> queue = snapshot.data;
                      print('kill');
                      return Flexible(
                          child: ListView.builder(
                        padding: EdgeInsets.all(25).copyWith(top: 15),
                        itemCount: queue.length,
                        // itemExtent: 5,

                        itemBuilder: (context, index) {
                          // print('ffgf: ${ ScrollController()}');
                          return Dismissible(
                            key: Key('${index.toString()}${queue[index].id}'),
                            onDismissed: (direction) async {
                              /*   queue.removeAt(index);
                                  await onRemoveAt(index); */
                            },
                            child: MusicListItem(
                              onClick: () async {
                                await AudioService.skipToQueueItem(
                                    queue[index].extras['index']);

                                currentAlbumArt = queue[index].artUri.path;
                              },
                              title: queue[index].title,
                              artist: queue[index].artist,
                              albumArt: queue[index]?.artUri?.path ?? '',
                              song: queue[index],
                              page: 'now_playing',
                              moreIconVisible: false,
                              titleTextColor: Colors.white,
                              subtitleTextColor: Colors.white,
                              color: Color.fromRGBO(0, 0, 0, 0),
                              songIndex: index,
                              thePlaying: /*  _currentIndex == index */ false,
                              textAreaLength:
                                  MediaQuery.of(context).size.width - 175,
                            ),
                          );
                        },
                      ));
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NowPlayingState {
  final Duration position;
  final MediaItem mediaItem;
  final List<MediaItem> queue;

  NowPlayingState(this.position, this.mediaItem, this.queue);
}
