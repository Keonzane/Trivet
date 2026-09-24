import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/leisure_log.dart';
import '../models/media_entry.dart';
import '../models/project.dart';
import '../models/work_log.dart';
import '../models/workout.dart';

/// Generic list-of-JSON-records store. One shared_preferences key holds a
/// List<String>, one JSON string per record. Every change rewrites the
/// whole list for that key — fine at the record counts Trivet expects
/// (a few hundred over a term). See proposal §"How my app saves data".
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
    return raw
        .map((s) => fromMap(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<void> save(List<T> items) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = items.map((item) => jsonEncode(toMap(item))).toList();
    await prefs.setStringList(key, raw);
  }
}

/// One store per model, per the proposal's shared_preferences plan.
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
  final DateTime start; // Monday 00:00
  final DateTime end; // Sunday 23:59:59.999

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
