import 'package:flutter/foundation.dart';

import '../../models/media_entry.dart';
import '../../models/media_result.dart';
import 'anilist_provider.dart';
import 'media_provider.dart';
import 'open_library_provider.dart';
import 'rawg_provider.dart';
import 'tmdb_provider.dart';

class MediaSearchService {
  MediaSearchService({List<MediaProvider>? providers})
      : _providers = providers ??
            [
              TmdbProvider(),
              RawgProvider(),
              OpenLibraryProvider(),
              AniListProvider(),
            ] {
    if (kDebugMode) {
      for (final p in _providers) {
        debugPrint('[media-search] ${p.name}: '
            '${p.isConfigured ? 'ready' : 'OFF (missing ${p.configKey})'}');
      }
    }
  }

  static final instance = MediaSearchService();

  final List<MediaProvider> _providers;

  static const _timeout = Duration(seconds: 8);

  Iterable<MediaProvider> _serving(MediaType? type) =>
      _providers.where((p) => type == null || p.types.contains(type));

  bool canSearch([MediaType? type]) =>
      _serving(type).any((p) => p.isConfigured);

  String? setupHint(MediaType type) {
    if (canSearch(type)) return null;
    final missing = {
      for (final p in _serving(type))
        if (!p.isConfigured && p.configKey != null) p.configKey!,
    };
    if (missing.isEmpty) return null;
    return 'Search is off: run the app with ${missing.join(' / ')} set. '
        'You can still type a title.';
  }

  Future<List<MediaResult>> search(String query, {MediaType? type}) async {
    final q = query.trim();
    if (q.length < 2) return const [];

    final lists = await Future.wait([
      for (final p in _serving(type))
        if (p.isConfigured) _safeSearch(p, q, type),
    ]);

    final seen = <String>{};
    final merged = <MediaResult>[];
    final longest = lists.fold<int>(0, (m, l) => l.length > m ? l.length : m);
    for (var i = 0; i < longest; i++) {
      for (final list in lists) {
        if (i < list.length && seen.add(list[i].key)) merged.add(list[i]);
      }
    }
    return merged;
  }

  Future<List<MediaResult>> _safeSearch(
      MediaProvider p, String q, MediaType? type) async {
    try {
      return await p.search(q, type: type).timeout(_timeout);
    } catch (e) {
      debugPrint('[media-search] ${p.name} failed: $e');
      return const <MediaResult>[];
    }
  }

  Future<MediaResult> enrich(MediaResult result) async {
    for (final p in _providers) {
      if (p.id == result.source) {
        try {
          return await p.enrich(result).timeout(_timeout);
        } catch (_) {
          return result;
        }
      }
    }
    return result;
  }
}
