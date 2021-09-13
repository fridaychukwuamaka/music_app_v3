import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:music_app_v3/models/playlist_data.dart';
import 'package:music_app_v3/screens/detailed_search_result.dart';
import 'package:music_app_v3/services/playlist.dart';
import 'package:music_app_v3/widgets/album_item.dart';
import 'package:music_app_v3/widgets/music_list_item.dart';

final FlutterAudioQuery audioQuery = FlutterAudioQuery();

// final HiveDb hiveDb = HiveDb();

class SearchPage extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(FeatherIcons.xCircle),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return super.appBarTheme(context);
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.of(context).pop(true);
      },
    );
  }

  Future<List<SongInfo>> searchSongs({String query}) async {
    List<SongInfo> songs = await audioQuery.getSongs();
    List<SongInfo> searchedSongs = [];
    songs.forEach((e) {
      if (e.title.toLowerCase().contains(query.trim().toLowerCase())) {
        searchedSongs.add(e);
      }
    });
    return searchedSongs;
  }

  Future<List<AlbumInfo>> searchAlbums({String query}) async {
    List<AlbumInfo> albums = await audioQuery.getAlbums();
    List<AlbumInfo> searchedAlbums = [];
    albums.forEach((e) {
      if (e.title.toLowerCase().contains(query.trim().toLowerCase())) {
        searchedAlbums.add(e);
      }
    });
    return searchedAlbums;
  }

  Future<List<PlaylistData>> searchPlayList({String query}) async {
    List<PlaylistData> playLists = await Playlist().getPlaylist();
    print('playlist: $playLists');
    List<PlaylistData> searchedPlaylists = [];
    playLists.forEach((e) {
      if (e.name.toLowerCase().contains(query.trim().toLowerCase())) {
        searchedPlaylists.add(e);
      }
    });
    return searchedPlaylists;
  }

  Future<List<ArtistInfo>> searchArtist({String query}) async {
    List<ArtistInfo> albums = await audioQuery.getArtists();
    List<ArtistInfo> searchedArtisit = [];
    albums.forEach((e) {
      if (e.name.toLowerCase().contains(query.trim().toLowerCase())) {
        searchedArtisit.add(e);
      }
    });
    return searchedArtisit;
  }

  @override
  showResults(BuildContext context) {
    super.showResults(context);
  }

  @override
  Widget buildResults(BuildContext context) {
    int songLength;
    int albumLength;

    if (songLength != null && albumLength == null) {
      return Text('data');
    } else {
      return Container(
        height: double.infinity,
        child: ListView(
          padding: EdgeInsets.all(30),
          children: [
            FutureBuilder<List<SongInfo>>(
              initialData: [],
              future: searchSongs(query: query),
              builder: (context, snapshot) {
                final List<SongInfo> songs = snapshot.data;
                songLength = songs.length;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    songs.isNotEmpty
                        ? Text(
                            'Songs',
                            textScaleFactor: 0.9,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              //color: Colors.black
                            ),
                          )
                        : SizedBox.shrink(),
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: songs.length > 5 ? 5 : songs.length,
                      itemBuilder: (context, index) => MusicListItem(
                        title: songs[index].title,
                        artist: songs[index].artist,
                        song: songs[index],
                        textAreaLength: MediaQuery.of(context).size.width - 229,
                        thePlaying: true,
                        onClick: () {},
                        color: Color(0xFFE6E6E6),
                        iconColor: Color(0xFF5C5C5C),
                        subtitleTextColor: Colors.black,
                        titleTextColor: Colors.black,
                      ),
                    ),
                    songs.length > 5
                        ? Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (BuildContext context) =>
                                        DetailedSearchResult(
                                      title: 'Songs',
                                      type: 'songs',
                                      list: songs,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                '${songs.length - 5} more',
                                textScaleFactor: 0.9,
                                style: Theme.of(context)
                                    .textTheme
                                    .button
                                    .copyWith(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black),
                              ),
                            ),
                          )
                        : SizedBox.shrink(),
                  ],
                );
              },
            ),
            SizedBox(
              height: 20,
            ),
            FutureBuilder<List<AlbumInfo>>(
              initialData: [],
              future: searchAlbums(query: query),
              builder: (context, snapshot) {
                final List<AlbumInfo> albums = snapshot.data;
                albumLength = albums.length;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    albums.isNotEmpty
                        ? Text(
                            'Album',
                            textScaleFactor: 0.9,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              //color: Colors.black
                            ),
                          )
                        : SizedBox.shrink(),
                    SizedBox(
                      height: 10,
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        childAspectRatio: 0.75,
                        crossAxisCount: 2,
                        crossAxisSpacing: 25,
                        mainAxisSpacing: 25,
                      ),
                      itemCount: albums.length > 4 ? 4 : albums.length,
                      itemBuilder: (context, index) => AlbumItem(
                        playButton: true,
                        borderRadius: BorderRadius.circular(5),
                        typeOfAlbumItem: 'album',
                        icon: Icons.play_arrow,
                        title: albums[index].title,
                        albumArtwork: albums[index].albumArt,
                        item: albums[index],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    albums.length > 4
                        ? Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (BuildContext context) =>
                                        DetailedSearchResult(
                                      title: 'Albums',
                                      type: 'album',
                                      list: albums,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                '${albums.length - 4} more',
                                textScaleFactor: 0.9,
                                style: Theme.of(context)
                                    .textTheme
                                    .button
                                    .copyWith(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black),
                              ),
                            ),
                          )
                        : SizedBox.shrink(),
                  ],
                );
              },
            ),
            SizedBox(
              height: 20,
            ),
            FutureBuilder<List<ArtistInfo>>(
              initialData: [],
              future: searchArtist(query: query),
              builder: (context, snapshot) {
                final List<ArtistInfo> albums = snapshot.data;
                albumLength = albums.length;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    albums.isNotEmpty
                        ? Text(
                            'Artist',
                            textScaleFactor: 0.9,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              //color: Colors.black
                            ),
                          )
                        : SizedBox.shrink(),
                    SizedBox(
                      height: 10,
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        childAspectRatio: 0.75,
                        crossAxisCount: 2,
                        crossAxisSpacing: 25,
                        mainAxisSpacing: 25,
                      ),
                      itemCount: albums.length > 5 ? 5 : albums.length,
                      itemBuilder: (context, index) => AlbumItem(
                        playButton: true,
                        borderRadius: BorderRadius.circular(5),
                        typeOfAlbumItem: 'artist',
                        icon: Icons.play_arrow,
                        title: albums[index].name,
                        albumArtwork: '',
                        item: albums[index],
                      ),
                    ),
                    albums.length > 5
                        ? Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '${albums.length - 5} more',
                              textScaleFactor: 0.9,
                              style: Theme.of(context)
                                  .textTheme
                                  .button
                                  .copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black),
                            ),
                          )
                        : SizedBox.shrink(),
                  ],
                );
              },
            ),
            SizedBox(
              height: 20,
            ),
            FutureBuilder<List<PlaylistData>>(
              initialData: [],
              future: searchPlayList(query: query),
              builder: (context, snapshot) {
                final List<PlaylistData> albums = snapshot.data;
                albumLength = albums.length;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    albums.isNotEmpty
                        ? Text(
                            'Playlist',
                            textScaleFactor: 0.9,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              //color: Colors.black
                            ),
                          )
                        : SizedBox.shrink(),
                    SizedBox(
                      height: 10,
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        childAspectRatio: 0.75,
                        crossAxisCount: 2,
                        crossAxisSpacing: 25,
                        mainAxisSpacing: 25,
                      ),
                      itemCount: albums.length > 5 ? 5 : albums.length,
                      itemBuilder: (context, index) => AlbumItem(
                        playButton: true,
                        borderRadius: BorderRadius.circular(5),
                        typeOfAlbumItem: 'artist',
                        icon: Icons.play_arrow,
                        title: albums[index].name,
                        albumArtwork: '',
                        item: albums[index],
                      ),
                    ),
                    albums.length > 5
                        ? Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '${albums.length - 5} more',
                              textScaleFactor: 0.9,
                              style: Theme.of(context)
                                  .textTheme
                                  .button
                                  .copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black),
                            ),
                          )
                        : SizedBox.shrink(),
                  ],
                );
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  void showSuggestions(BuildContext context) {
    super.showSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return SizedBox.shrink();
  }
}
