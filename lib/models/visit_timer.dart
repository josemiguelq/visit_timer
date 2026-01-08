import 'dart:convert';

enum VisitCategory {
  medico('Médico', 4, 15),
  conhecido('Conhecido', 16, 40),
  amigo('Amigo', 40, 180),
  fofoqueiro('Fofoqueiro', 10, 30);

  final String displayName;
  final int minMinutes;
  final int maxMinutes;

  const VisitCategory(this.displayName, this.minMinutes, this.maxMinutes);

  static VisitCategory fromString(String value) {
    return VisitCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => VisitCategory.conhecido,
    );
  }
}

class VisitTimer {
  final String id;
  final VisitCategory category;
  final String name;
  final DateTime dateTime;
  final int durationSeconds;

  VisitTimer({
    required this.id,
    required this.category,
    required this.name,
    required this.dateTime,
    required this.durationSeconds,
  });

  String get formattedDuration {
    final hours = durationSeconds ~/ 3600;
    final minutes = (durationSeconds % 3600) ~/ 60;
    final seconds = durationSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  String get displayTitle => 'Visita de ${category.displayName} de $name';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category.name,
      'name': name,
      'dateTime': dateTime.toIso8601String(),
      'durationSeconds': durationSeconds,
    };
  }

  factory VisitTimer.fromJson(Map<String, dynamic> json) {
    return VisitTimer(
      id: json['id'] as String,
      category: VisitCategory.fromString(json['category'] as String),
      name: json['name'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      durationSeconds: json['durationSeconds'] as int,
    );
  }

  static String encodeList(List<VisitTimer> timers) {
    return jsonEncode(timers.map((t) => t.toJson()).toList());
  }

  static List<VisitTimer> decodeList(String jsonString) {
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => VisitTimer.fromJson(json)).toList();
  }
}

