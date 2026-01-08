import 'package:shared_preferences/shared_preferences.dart';
import '../models/visit_timer.dart';

class StorageService {
  static const String _timersKey = 'visit_timers';

  static Future<List<VisitTimer>> loadTimers() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_timersKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      return VisitTimer.decodeList(jsonString);
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveTimers(List<VisitTimer> timers) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = VisitTimer.encodeList(timers);
    await prefs.setString(_timersKey, jsonString);
  }

  static Future<void> addTimer(VisitTimer timer) async {
    final timers = await loadTimers();
    timers.insert(0, timer);
    await saveTimers(timers);
  }
}
