import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioPlayer _player = AudioPlayer();
  
  static Future<void> playAlarm() async {
    try {
      // Tenta tocar o áudio personalizado
      await _player.play(AssetSource('audio/alarm.mp3'));
    } catch (e) {
      // Se o arquivo não existir, usa um som do sistema ou ignora
      print('Áudio não encontrado: $e');
    }
  }
  
  static Future<void> stop() async {
    await _player.stop();
  }
  
  static void dispose() {
    _player.dispose();
  }
}

