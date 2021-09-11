import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:music_app_v3/models/playlist_data.dart';
import 'package:music_app_v3/services/playlist.dart';
import 'package:music_app_v3/widgets/playlist_modal.dart';
import '../constant.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';

class MusicPlaylistModal extends StatefulWidget {
  final List<String> songIds;
  final String fromPage;
  const MusicPlaylistModal({
    this.songIds,
    this.fromPage,
  });

  @override
  _MusicPlaylistModalState createState() => _MusicPlaylistModalState();
}

class _MusicPlaylistModalState extends State<MusicPlaylistModal> {
  @override
  void initState() {
    openPlaylistBox();
    super.initState();
  }

  openPlaylistBox() async {
    await Hive.openBox('playlist');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.05),
      body: Container(
        padding: EdgeInsets.only(top: 0, right: 20, left: 20),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            GestureDetector(
              onTap: () async {
                await showDialog(
                  context: context,
                  builder: (BuildContext context) => PlaylistModal(
                    songIds: widget.songIds,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.add,
                      size: 29,
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      'New playlist',
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              'ALL PLAYLIST',
              style: Theme.of(context).textTheme.bodyText1.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black38,
                  fontSize: 13),
            ),
            SizedBox(
              height: 30,
            ),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: Hive.box('playlist').listenable(),
                builder: (context, value, child) {
                  var playlist;
                  final temp = value.get('playlist');
                  if (temp != null) {
                    playlist = json.decode(temp);
                  }
                  //print(playlist);
                  return ListView.builder(
                    itemCount: playlist.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Center(
                        child: GestureDetector(
                          onTap: () async {
                            await Playlist().addSong(
                                playlist[index]['id'], widget.songIds.first);
                            Navigator.pop(context);
                          },
                          child: PlaylistModalTile(
                            image: null,
                            date: DateFormat.MMMd().format(DateTime.tryParse(
                                playlist[index]['creationDate'])),
                            name: playlist[index]['name'],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlaylistModalTile extends StatelessWidget {
  final String name;
  final String date;
  final String image;
  const PlaylistModalTile(
      {@required this.name, @required this.date, this.image});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          color: Colors.white,
          child: Row(
            children: <Widget>[
              Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, 2.8),
                        color: Colors.black26,
                        blurRadius: 6,
                      )
                    ],
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: image == null
                            ? AssetImage(kPlaceHolderImage)
                            : FileImage(File(image)))),
              ),
              SizedBox(
                width: 20,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      name,
                      textScaleFactor: 0.9,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    SizedBox(
                      height: 7,
                    ),
                    Text(
                      date,
                      textScaleFactor: 0.9,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        SizedBox(
          height: 25,
        )
      ],
    );
  }
}
