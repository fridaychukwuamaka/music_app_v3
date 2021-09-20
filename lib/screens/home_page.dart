import 'dart:async';
import 'dart:convert';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:hive/hive.dart';
import 'package:music_app_v3/screens/search_page.dart';
import 'package:music_app_v3/screens/tabs/album_tab.dart';
import 'package:music_app_v3/screens/tabs/artist_tab.dart';
import 'package:music_app_v3/screens/tabs/playlist_tab.dart';
import 'package:music_app_v3/screens/tabs/song_tab.dart';
import 'package:music_app_v3/services/backgroud_task.dart';
import 'package:music_app_v3/utils/utils.dart';
import 'package:music_app_v3/widgets/music_app_bar.dart';
import 'package:music_app_v3/widgets/music_bottom_nav_bar.dart';

//TODO: 1. ALBUM ITEM FOR LIGHT IMAGES
//TODO: 2. FIX WHEN QUEUE STOP
//TODO: 3. HEADSET BUTTON WHEN APP IS ON
//TODO: 4. LOCKSCREEN ISSUE

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  TabController _tabController;
  PageController _pageController;
  bool setupLoop = false;
  int tabIndex;

  StreamSubscription audioServiceRunning;

  openDbBoxes() async {
    await Hive.openBox('playlist');
  }

  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this, initialIndex: 0);
    _pageController = PageController(initialPage: 0);
    onBackground();
    setRunningStream();
    super.initState();
  }

  Future<Map<String, dynamic>> getAllItems() async {
    Map<String, dynamic> result = {
      'songs': await flutterAudioQuery.getSongs(),
      'album': await flutterAudioQuery.getAlbums(),
      'artist': await flutterAudioQuery.getArtists(),
      'playlist': await playlistService.getPlaylist(),
    };

    return result;
  }

  Future<void> initNeccesarry() async {
    //await onBackground();

    var currentMediaItem;
    if (AudioService.currentMediaItem == null) {
      var val = json.decode(Hive.box('lastSong').get('lastSong'));
      if (val != null) {
        currentMediaItem = MediaItem.fromJson(val);
        await AudioService.updateMediaItem(currentMediaItem);
      }

      //INITIALIZE THE LAST STATE
      var position = Hive.box('lastPosition').get('lastPosition');

      if (position == null) {
        position = 0;
      }

      print('vole $position');

      await AudioService.customAction('SET-STATE', position);

      if (currentMediaItem != null) {
        await AudioService.customAction(
            'SET-FILE-PATH', currentMediaItem.extras['filePath']);
      }

      await AudioService.seekTo(Duration(milliseconds: position));

      var lastqueue = await Hive.box('lastQueue').get('lastQueue');

      if (lastqueue != null) {
        dynamic originalSong = json.decode(lastqueue);

        originalSong = List<MediaItem>.from(
            originalSong.map((e) => MediaItem.fromJson(e)).toList());

        await AudioService.updateQueue(originalSong);
      }
    }
  }

  @override
  void didChangeDependencies() {
    audioServiceRunning.cancel();
    setRunningStream();
    super.didChangeDependencies();
  }

  setRunningStream() {
    audioServiceRunning = AudioService.runningStream.listen((event) async {
      if (!event) {
        await onBackground();
      }
      if (event && AudioService.currentMediaItem == null) {
        await initNeccesarry();
      }
      if (event && setupLoop == false) {
        setLoopMode();
        setupLoop = true;
      }
    });
  }

  @override
  void dispose() {
    audioServiceRunning.cancel();
    AudioService.stop();
    super.dispose();
  }

  Map<String, dynamic> initialItemData = {
    'songs': [],
    'album': [],
    'artist': [],
    'playlist': []
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          reverse: true,
          children: [
            // Expanded(child: SizedBox(),),

            ListTile(
              leading: Icon(
                FeatherIcons.mail,
                size: 24,
                color: Colors.black,
              ),
              title: Text(
                'Feedback',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                FeatherIcons.info,
                size: 24,
                color: Colors.black,
              ),
              title: Text(
                'About',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                FeatherIcons.moon,
                size: 24,
                color: Colors.black,
              ),
              title: Text(
                'Dark mode',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                FeatherIcons.logOut,
                size: 24,
                color: Colors.black,
              ),
              onTap: () async {
                await SystemNavigator.pop(animated: true);
                dispose();
              },
              title: Text(
                'Quit',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                FeatherIcons.settings,
                size: 24,
                color: Colors.black,
              ),
              title: Text(
                'Settings',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                FeatherIcons.star,
                size: 24,
                color: Colors.black,
              ),
              title: Text('Rate us',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  )),
            ),
            SizedBox(
              height: 50,
            )
          ].reversed.toList(),
        ),
      ),
      /*     floatingActionButton: tabIndex == 3
          ? FloatingActionButton(
              onPressed: () {},
              child: Icon(
                FeatherIcons.plus,
                color: Colors.white,
              ),
            )
          : null,
          floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling, */
      body: SafeArea(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 8,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5.0, left: 15, right: 15),
              child: Builder(builder: (context) {
                return MusicAppBar(
                  title: 'My music',
                  iconSize: 16,
                  leadingIcon: FeatherIcons.menu,
                  trailingIcon: FeatherIcons.search,
                  padding: false,
                  onleadingIconPressed: () async {
                    Scaffold.of(context).openDrawer();
                  },
                  ontralingIconPressed: () async {
                    var t = await showSearch(
                      context: context,
                      delegate: SearchPage(),
                    );
                    if (t == true) {
                      // Provider.of<MusicService>(context).clearSearchArray();
                    }
                  },
                );
              }),
            ),
            SizedBox(
              height: 35,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: TabBar(
                onTap: (val) {
                  setState(() {
                    tabIndex = val;
                  });
                  _pageController.animateToPage(
                    val,
                    duration: kTabScrollDuration,
                    curve: Curves.ease,
                  );
                },
                controller: _tabController,
                tabs: [
                  Tab(
                    icon: Icon(
                      FeatherIcons.music,
                      size: 22,
                    ),
                    text: 'Songs',
                  ),
                  Tab(
                    icon: Icon(
                      FeatherIcons.disc,
                      size: 22,
                    ),
                    text: 'Album',
                  ),
                  Tab(
                    icon: Icon(
                      FeatherIcons.user,
                      size: 22,
                    ),
                    text: 'Artist',
                  ),
                  Tab(
                    icon: Icon(
                      Icons.playlist_play,
                      size: 25,
                    ),
                    text: 'Playlists',
                  ),
                ],
              ),
            ),
            Expanded(
                child: FutureBuilder<Map<String, dynamic>>(
                    initialData: initialItemData,
                    future: getAllItems(),
                    builder: (context, snapshot) {
                      return PageView(
                        controller: _pageController,
                        onPageChanged: (val) {
                          setState(() {
                            tabIndex = val;
                          });

                          _tabController.animateTo(val);
                        },
                        children: [
                          SongTab(
                            songs: snapshot?.data['songs'],
                          ),
                          AlbumTab(
                            albums: snapshot?.data['album'],
                          ),
                          ArtistTab(artist: snapshot?.data['artist']),
                          PlaylistTab(
                            playlist: snapshot?.data['playlist'],
                          ),
                        ],
                      );
                    })),
          ],
        ),
      ),
      bottomNavigationBar: StreamBuilder<MediaItem>(
          stream: AudioService.currentMediaItemStream,
          builder: (context, snapshot) {
            final MediaItem currentMediaItem = snapshot?.data;

            if (currentMediaItem != null) {
              return MusicBottomNavBar(
                currentAlbumArt: currentMediaItem?.artUri?.path ?? '',
                currentArtist: currentMediaItem?.artist ?? '',
                currentSong: currentMediaItem?.title ?? '',
                currentMediaItem: currentMediaItem,
              );
            } else {
              return SizedBox.shrink();
            }
          }),
    );
  }
}
