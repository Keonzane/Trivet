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
  final String Function(T item) idOf;

  ListStore({
    required this.key,
    required this.toMap,
    required this.fromMap,
    required this.idOf,
  });

  Future<List<T>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(key) ?? const [];
    final items = <T>[];
    for (final s in raw) {
      try {
        items.add(fromMap(jsonDecode(s) as Map<String, dynamic>));
      } catch (_) {
        continue;
      }
    }
    return items;
  }

  Future<void> save(List<T> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        key, items.map((item) => jsonEncode(toMap(item))).toList());
  }

  Future<void> put(T item) async {
    final items = await load();
    final i = items.indexWhere((x) => idOf(x) == idOf(item));
    if (i == -1) {
      items.add(item);
    } else {
      items[i] = item;
    }
    await save(items);
  }

  Future<void> removeWhere(bool Function(T item) test) async {
    await save((await load())..removeWhere(test));
  }
}

class ProjectStore extends ListStore<Project> {
  ProjectStore()
      : super(
            key: 'projects',
            toMap: (p) => p.toMap(),
            fromMap: Project.fromMap,
            idOf: (p) => p.id);
}

class WorkLogStore extends ListStore<WorkLog> {
  WorkLogStore()
      : super(
            key: 'worklogs',
            toMap: (l) => l.toMap(),
            fromMap: WorkLog.fromMap,
            idOf: (l) => l.id);
}

class WorkoutStore extends ListStore<Workout> {
  WorkoutStore()
      : super(
            key: 'workouts',
            toMap: (w) => w.toMap(),
            fromMap: Workout.fromMap,
            idOf: (w) => w.id);
}

class MediaStore extends ListStore<MediaEntry> {
  MediaStore()
      : super(
            key: 'media',
            toMap: (m) => m.toMap(),
            fromMap: MediaEntry.fromMap,
            idOf: (m) => m.id);
}

class LeisureLogStore extends ListStore<LeisureLog> {
  LeisureLogStore()
      : super(
            key: 'leisurelogs',
            toMap: (l) => l.toMap(),
            fromMap: LeisureLog.fromMap,
            idOf: (l) => l.id);
}

class WeekRange {
  final DateTime start; // Monday 00:00
  final DateTime end; // Sunday 23:59:59.999

  const WeekRange(this.start, this.end);

  static WeekRange containing(DateTime day) {
    final start = DateTime(day.year, day.month, day.day - (day.weekday - 1));
    final end = DateTime(start.year, start.month, start.day + 7)
        .subtract(const Duration(milliseconds: 1));
    return WeekRange(start, end);
  }

  static WeekRange thisWeek() => containing(DateTime.now());

  bool contains(DateTime d) => !d.isBefore(start) && !d.isAfter(end);
}

extension WorkLogTotals on Iterable<WorkLog> {
  double hoursIn(WeekRange week) =>
      where((l) => week.contains(l.date)).fold(0.0, (sum, l) => sum + l.hours);
}

extension LeisureLogTotals on Iterable<LeisureLog> {
  double hoursIn(WeekRange week) =>
      where((l) => week.contains(l.date)).fold(0, (sum, l) => sum + l.minutes) /
      60;
}

extension WorkoutTotals on Iterable<Workout> {
  int doneMinutesIn(WeekRange week) =>
      where((w) => w.done && week.contains(w.date))
          .fold(0, (sum, w) => sum + w.durationMinutes);
}
