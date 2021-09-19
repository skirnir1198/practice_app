import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:image_picker/image_picker.dart';

var url;
var movie;
late File imageSpace;
FirebaseStorage storage = FirebaseStorage.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MaterialApp(
      home: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DemoHome(),
    );
  }
}

class ThumbnailRequest {
  final String video;

  const ThumbnailRequest({
    required this.video,
  });
}

class ThumbnailResult {
  final Image image;
  const ThumbnailResult({required this.image});
}

Future<ThumbnailResult> getThumbnail(ThumbnailRequest r) async {
  Uint8List bytes;

  ///CompleterはFutureでデータを運ぶ役割を担う
  final Completer<ThumbnailResult> completer = Completer();
  bytes = (await VideoThumbnail.thumbnailData(
    video: r.video,
  ))!;
  final _image = Image.memory(bytes);
  // imageSpace = File.fromRawPath(bytes);
  // await storage.ref('image1').putFile(imageSpace);
  // print(imageSpace);
  completer.complete(ThumbnailResult(
    image: _image,
  ));
  return completer.future;
}

class GenThumbnailImage extends StatefulWidget {
  final ThumbnailRequest thumbnailRequest;

  const GenThumbnailImage({required this.thumbnailRequest});
  @override
  _GenThumbnailImageState createState() => _GenThumbnailImageState();
}

class _GenThumbnailImageState extends State<GenThumbnailImage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ThumbnailResult>(
        future: getThumbnail(widget.thumbnailRequest),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            final _image = snapshot.data.image;
            File file = _image;
            print(file);
            return Column(
              children: [
                _image,
              ],
            );
          } else {
            return Container();
          }
        });
  }
}

class DemoHome extends StatefulWidget {
  @override
  _DemoHomeState createState() => _DemoHomeState();
}

class _DemoHomeState extends State<DemoHome> {
  final ImagePicker picker = ImagePicker();
  GenThumbnailImage? _futureImage;
  late String videoPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("thumbnail demo"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: (_futureImage != null)
                  ? GestureDetector(
                      child: Container(
                          width: 150, height: 150, child: _futureImage),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Movie(),
                          ),
                        );
                      },
                    )
                  : SizedBox(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // 動画アップロード
          final pickedFile =
              await picker.pickVideo(source: ImageSource.gallery);
          if (pickedFile != null) {
            movie = File(pickedFile.path);
          }
          setState(() {
            videoPath = pickedFile!.path;
            _futureImage = GenThumbnailImage(
              thumbnailRequest: ThumbnailRequest(
                video: videoPath,
              ),
            );
          });
          storage.ref('movie1').putFile(movie);
          // storage.ref('movie1').putFile(imageSpace);
        },
        child: Icon(Icons.camera_alt_outlined),
        heroTag: "video capture",
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
