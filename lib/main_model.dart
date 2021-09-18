import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:video_player/video_player.dart';

class MainModel extends ChangeNotifier {
  var url;
  FirebaseStorage storage = FirebaseStorage.instance;
  VideoPlayerController controller =
      VideoPlayerController.asset('assets/video.MOV');

  void setUp() async {
    Reference ref = storage.ref().child('movie');
    url = await ref.getDownloadURL();
    controller = VideoPlayerController.asset('assets/video.MOV');
    notifyListeners();
  }

  void movieRestart() {
    controller.seekTo(Duration.zero).then((_) => controller.play());
    notifyListeners();
  }

  void movieStart() {
    controller.play();
    notifyListeners();
  }

  void notify() {
    notifyListeners();
  }
}
