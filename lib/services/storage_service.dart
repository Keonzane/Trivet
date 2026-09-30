import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/leisure_log.dart';
import '../models/media_entry.dart';
import '../models/project.dart';
import '../models/work_log.dart';
import '../models/workout.dart';

class ListStore<T> {
  final String key;
  final Map<String, dynamic> Function(T item) toMap;
  final T Function(Map<String, dynamic> map) fromMap;

  ListStore({
    required this.key,
    required this.toMap,
    required this.fromMap,
  });

  Future<List<T>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(key) ?? const [];
    final items = <T>[];
    for (final s in raw) {
      try {
        items.add(fromMap(jsonDecode(s) as Map<String, dynamic>));
      } catch (_) {
        // One corrupted record (malformed JSON, a missing field, an enum
        // value that no longer exists) used to throw here and take the
        // whole list down with it — every other record for that model
        // never loaded, and the screen sat on its spinner forever. Now a
        // bad record is just dropped; everything else still loads.
      }
    }
    return items;
  }

  Future<void> save(List<T> items) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = items.map((item) => jsonEncode(toMap(item))).toList();
    await prefs.setStringList(key, raw);
  }
}

class ProjectStore extends ListStore<Project> {
  ProjectStore()
      : super(
          key: 'projects',
          toMap: (p) => p.toMap(),
          fromMap: Project.fromMap,
        );
}

class WorkLogStore extends ListStore<WorkLog> {
  WorkLogStore()
      : super(
          key: 'worklogs',
          toMap: (w) => w.toMap(),
          fromMap: WorkLog.fromMap,
        );
}

class WorkoutStore extends ListStore<Workout> {
  WorkoutStore()
      : super(
          key: 'workouts',
          toMap: (w) => w.toMap(),
          fromMap: Workout.fromMap,
        );
}

class MediaStore extends ListStore<MediaEntry> {
  MediaStore()
      : super(
          key: 'media',
          toMap: (m) => m.toMap(),
          fromMap: MediaEntry.fromMap,
        );
}

class LeisureLogStore extends ListStore<LeisureLog> {
  LeisureLogStore()
      : super(
          key: 'leisurelogs',
          toMap: (l) => l.toMap(),
          fromMap: LeisureLog.fromMap,
        );
}

class WeekRange {
  final DateTime start;
  final DateTime end;

  const WeekRange(this.start, this.end);

  static WeekRange containing(DateTime day) {
    final monday = day.subtract(Duration(days: day.weekday - 1));
    final start = DateTime(monday.year, monday.month, monday.day);
    final end = start
        .add(const Duration(days: 7))
        .subtract(const Duration(milliseconds: 1));
    return WeekRange(start, end);
  }

  bool contains(DateTime d) => !d.isBefore(start) && !d.isAfter(end);
}
