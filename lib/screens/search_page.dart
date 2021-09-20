import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:music_app_v3/models/playlist_data.dart';
import 'package:music_app_v3/screens/detailed_search_result.dart';
import 'package:music_app_v3/utils/utils.dart';
import 'package:music_app_v3/widgets/album_item.dart';
import 'package:music_app_v3/widgets/music_list_item.dart';


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

  @override
  showResults(BuildContext context) {
    super.showResults(context);
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: searchAppForSong(query),
      builder: (context, snapshot) {
        print(snapshot.connectionState);

        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          final List<SongInfo> songs = snapshot.data['songs'];
          final List<AlbumInfo> albums = snapshot.data['album'];
          final List<ArtistInfo> artist = snapshot.data['artist'];
          final List<PlaylistData> playlist = snapshot.data['playlist'];

          print(playlist);

          return ListView(
            padding: EdgeInsets.all(30),
            children: [
              //SEARCHED SONGS
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
              SizedBox(
                height: 10,
              ),
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
                          style: Theme.of(context).textTheme.button.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black),
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
              SizedBox(
                height: 20,
              ),
              //SEARCH ALBUMS
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
                          style: Theme.of(context).textTheme.button.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black),
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
              SizedBox(
                height: 20,
              ),
              artist.isNotEmpty
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
                itemCount: artist.length > 5 ? 5 : artist.length,
                itemBuilder: (context, index) => AlbumItem(
                  playButton: true,
                  borderRadius: BorderRadius.circular(5),
                  typeOfAlbumItem: 'artist',
                  icon: Icons.play_arrow,
                  title: artist[index].name,
                  albumArtwork: '',
                  item: artist[index],
                ),
              ),
              artist.length > 5
                  ? Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${artist.length - 5} more',
                        textScaleFactor: 0.9,
                        style: Theme.of(context).textTheme.button.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                      ),
                    )
                  : SizedBox.shrink(),
              SizedBox(
                height: 20,
              ),
              playlist.isNotEmpty
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
                itemCount: playlist.length > 5 ? 5 : playlist.length,
                itemBuilder: (context, index) => AlbumItem(
                  playButton: true,
                  borderRadius: BorderRadius.circular(5),
                  typeOfAlbumItem: 'artist',
                  icon: Icons.play_arrow,
                  title: playlist[index].name,
                  albumArtwork: '',
                  item: playlist[index],
                ),
              ),
              playlist.length > 5
                  ? Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${playlist.length - 5} more',
                        textScaleFactor: 0.9,
                        style: Theme.of(context).textTheme.button.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black),
                      ),
                    )
                  : SizedBox.shrink(),
            ],
          );
        } else if (snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasData) {
          return SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    FeatherIcons.search,
                    color: Colors.orange,
                    size: 30,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    "Couldn't find anthing",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  )
                ],
              ),
            ),
          );
        } else {
          return Text('data');
        }
        // return ListView();
      },
    );
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
