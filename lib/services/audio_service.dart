import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioPlayer _player = AudioPlayer();
  static final Random _random = Random();

  static Future<void> playAlarm() async {
    // Escolhe aleatoriamente um dos 4 áudios
    final audioNumber = _random.nextInt(4) + 1; // 1, 2, 3 ou 4
    final file = '$audioNumber.m4a';

    try {
      await _player.play(AssetSource('audio/$file'));
    } catch (e) {
      print('Erro ao tocar áudio $file: $e');
    }
  }

  static Future<void> stop() async {
    await _player.stop();
  }

  static void dispose() {
    _player.dispose();
  }
}
