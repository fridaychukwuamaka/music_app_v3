import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:hive/hive.dart';
import 'package:music_app_v3/screens/tabs/album_tab.dart';
import 'package:music_app_v3/screens/tabs/artist_tab.dart';
import 'package:music_app_v3/screens/tabs/playlist_tab.dart';
import 'package:music_app_v3/screens/tabs/song_tab.dart';
import 'package:music_app_v3/services/backgroud_task.dart';
import 'package:music_app_v3/utils/utils.dart';
import 'package:music_app_v3/widgets/music_app_bar.dart';
import 'package:music_app_v3/widgets/music_bottom_nav_bar.dart';
import 'search_page.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  TabController _tabController;
  bool setupLoop = false;

  StreamSubscription audioServiceRunning;

  openDbBoxes() async {
    await Hive.openBox('playlist');
  }

  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this, initialIndex: 0);
    onBackground();
    setRunningStream();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    audioServiceRunning.cancel();
    setRunningStream();
    super.didChangeDependencies();
  }

  setRunningStream() {
    audioServiceRunning = AudioService.runningStream.listen((event) {
      if (!event) {
        onBackground();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [],
        ),
      ),
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
                onTap: (val) {},
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
              child: TabBarView(
                controller: _tabController,
                children: [
                  SongTab(),
                  AlbumTab(),
                  ArtistTab(),
                  PlaylistTab(),
                ],
              ),
            )
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
