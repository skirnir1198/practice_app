import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:flick_video_player/flick_video_player.dart';

final ImagePicker picker = ImagePicker();
var url;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseStorage storage = FirebaseStorage.instance;
  Reference ref = storage.ref().child('movie1.MOV');
  url = await ref.getDownloadURL();
  runApp(
    MaterialApp(
      home: MoviePage(),
    ),
  );
}

class MoviePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          child: Text('動画を見る'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Movie(),
              ),
            );
          },
        ),
      ),
    );
  }
}

class Movie extends StatefulWidget {
  @override
  _SamplePlayerState createState() => _SamplePlayerState();
}

class _SamplePlayerState extends State<Movie> {
  late FlickManager flickManager;

  @override
  void initState() {
    super.initState();
    flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.network(url),
    );
  }

  @override
  void dispose() {
    flickManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          FlickVideoPlayer(flickManager: flickManager),
          GestureDetector(
            child: Icon(
              Icons.cancel,
              color: Colors.red,
              size: 40.0,
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

Future getMovie() async {
  var movie;
  final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
  if (pickedFile != null) {
    movie = File(pickedFile.path);
  }
  FirebaseStorage storage = FirebaseStorage.instance;
  storage.ref('movie1.MOV').putFile(movie);
}
