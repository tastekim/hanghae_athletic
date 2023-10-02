import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';

class AudioPlayerState extends GetxController {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void onInit() async {
    super.onInit();

    await _audioPlayer.play(
      AssetSource('audios/tetris.mp3'),
    );
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  void pause() {
    _audioPlayer.pause();
  }

  void play() {
    _audioPlayer.resume();
  }
}