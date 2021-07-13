import 'package:flutter/material.dart';
import 'package:music_app_v3/constant.dart';
import 'package:music_app_v3/models/playlist_data.dart';
import 'package:music_app_v3/services/playlist.dart';

class PlaylistModal extends StatefulWidget {
  const PlaylistModal({
    Key key,
    this.songIds,
  }) : super(key: key);

  final List<String> songIds;

  @override
  _PlaylistModalState createState() => _PlaylistModalState();
}

class _PlaylistModalState extends State<PlaylistModal> {
  String textVal = '';

  createNewPlaylist(String textVal) async {
    if (textVal.trim() != '') {
      PlaylistData newPlaylist = PlaylistData(
        name: textVal.inCaps,
        creationDate: DateTime.now().toString(),
        memberIds: widget.songIds,
        id: uuid.v4(),
      );

      await Playlist().addPlaylist(newPlaylist);

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(0, 0, 0, 0.5),
      body: Center(
        child: Container(
          height: 200,
          padding: EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width * 0.7,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'NEW PLAYLIST',
                textScaleFactor: 0.85,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
              TextField(
                cursorColor: Colors.black,
                style: TextStyle(color: Colors.black, fontSize: 16),
                onChanged: (val) {
                  setState(() {
                    textVal = val;
                  });
                },
                onEditingComplete: () async {
                  createNewPlaylist(textVal);
                },
                decoration: InputDecoration(
                  hintText: 'Plalylist name',
                  hintStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1.5)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Cancel',
                      textScaleFactor: 0.85,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      createNewPlaylist(textVal);
                    },
                    child: Text(
                      'Create',
                      textScaleFactor: 0.85,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
