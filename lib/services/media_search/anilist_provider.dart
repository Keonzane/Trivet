import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/media_entry.dart';
import '../../models/media_result.dart';
import 'media_provider.dart';

class AniListProvider extends MediaProvider {
  AniListProvider({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static final _endpoint = Uri.parse('https://graphql.anilist.co');

  @override
  String get id => 'anilist';

  @override
  String get name => 'AniList';

  @override
  Set<MediaType> get types => {MediaType.series, MediaType.book};

  @override
  bool get isConfigured => true;

  static const _query = r'''
query ($search: String, $type: MediaType) {
  Page(perPage: 6) {
    media(search: $search, type: $type, isAdult: false, sort: SEARCH_MATCH) {
      id
      title { romaji english }
      startDate { year }
      coverImage { large }
      averageScore
      episodes
      duration
      chapters
      volumes
    }
  }
}
''';

  @override
  Future<List<MediaResult>> search(String query, {MediaType? type}) async {
    final lists = await Future.wait([
      if (type == null || type == MediaType.series) _fetch(query, anime: true),
      if (type == null || type == MediaType.book) _fetch(query, anime: false),
    ]);
    return [for (final l in lists) ...l];
  }

  Future<List<MediaResult>> _fetch(String query, {required bool anime}) async {
    final res = await _client.post(
      _endpoint,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'query': _query,
        'variables': {'search': query, 'type': anime ? 'ANIME' : 'MANGA'},
      }),
    );
    if (res.statusCode == 429) throw Exception('AniList rate limit, try again');
    if (res.statusCode != 200) {
      throw Exception('AniList HTTP ${res.statusCode}');
    }
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final errors = json['errors'] as List?;
    if (errors != null && errors.isNotEmpty) {
      throw Exception('AniList ${(errors.first as Map)['message']}');
    }
    final media =
        ((json['data'] as Map?)?['Page'] as Map?)?['media'] as List? ??
            const [];
    final prefix = anime ? 'anime' : 'manga';
    final out = <MediaResult>[];
    for (final raw in media) {
      final m = raw as Map<String, dynamic>;
      final titles = m['title'] as Map?;
      final title = (titles?['english'] ?? titles?['romaji']) as String?;
      if (title == null) continue;
      final aid = '$prefix/${m['id']}';
      final score = (m['averageScore'] as num?)?.toDouble();
      final episodes = (m['episodes'] as int?) ?? 0;
      final duration = (m['duration'] as int?) ?? 0;
      final volumes = m['volumes'] as int?;
      final chapters = m['chapters'] as int?;
      out.add(MediaResult(
        source: id,
        sourceId: aid,
        type: anime ? MediaType.series : MediaType.book,
        title: title,
        year: (m['startDate'] as Map?)?['year'] as int?,
        posterUrl: (m['coverImage'] as Map?)?['large'] as String?,
        rating: score == null || score == 0 ? null : score / 10,
        subtitle: anime
            ? 'Anime'
            : [
                'Manga',
                if (volumes != null)
                  '$volumes vol'
                else if (chapters != null)
                  '$chapters ch',
              ].join(' · '),
        externalIds: {'anilist': aid},
        totalSeasons: 1,
        totalEpisodes: anime && episodes > 0 ? episodes : 1,
        totalMinutes: anime ? duration * episodes : 0,
      ));
    }
    return out;
  }
}
