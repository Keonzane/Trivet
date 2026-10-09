import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/media_entry.dart';
import '../../models/media_result.dart';
import 'media_provider.dart';
import 'media_search_config.dart';

class TmdbProvider extends MediaProvider {
  TmdbProvider({http.Client? client, String? proxyUrl})
      : _client = client ?? http.Client(),
        _proxyUrl = proxyUrl ?? MediaSearchConfig.proxyUrl;

  final http.Client _client;
  final String _proxyUrl;

  static const _imageBase = 'https://image.tmdb.org/t/p/w185';

  @override
  String get id => 'tmdb';

  @override
  String get name => 'TMDB';

  @override
  String get configKey => 'MEDIA_PROXY_URL';

  @override
  Set<MediaType> get types => {MediaType.film, MediaType.series};

  @override
  bool get isConfigured => _proxyUrl.isNotEmpty;

  Future<Map<String, dynamic>> _get(String path, Map<String, String> q) async {
    final base = Uri.parse('$_proxyUrl/tmdb/3$path');
    final uri = q.isEmpty ? base : base.replace(queryParameters: q);
    final res = await _client.get(uri, headers: {'Accept': 'application/json'});
    if (res.statusCode == 401) {
      throw Exception('TMDB rejected the proxy\'s key (401)');
    }
    if (res.statusCode != 200) {
      throw Exception('TMDB via proxy HTTP ${res.statusCode}: ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  int? _year(Object? date) {
    if (date is! String || date.length < 4) return null;
    return int.tryParse(date.substring(0, 4));
  }

  @override
  Future<List<MediaResult>> search(String query, {MediaType? type}) async {
    final path = switch (type) {
      MediaType.film => '/search/movie',
      MediaType.series => '/search/tv',
      _ => '/search/multi',
    };
    final json = await _get(path, {'query': query, 'include_adult': 'false'});
    final out = <MediaResult>[];
    for (final raw in (json['results'] as List? ?? const [])) {
      final r = raw as Map<String, dynamic>;
      final kind = switch (type) {
        MediaType.film => 'movie',
        MediaType.series => 'tv',
        _ => r['media_type'] as String?,
      };
      if (kind != 'movie' && kind != 'tv') continue;
      final isMovie = kind == 'movie';
      final poster = r['poster_path'] as String?;
      final vote = (r['vote_average'] as num?)?.toDouble();
      final tid = '$kind/${r['id']}';
      out.add(MediaResult(
        source: id,
        sourceId: tid,
        type: isMovie ? MediaType.film : MediaType.series,
        title: (isMovie ? r['title'] : r['name']) as String? ?? 'Untitled',
        year: _year(isMovie ? r['release_date'] : r['first_air_date']),
        posterUrl: poster == null ? null : '$_imageBase$poster',
        rating: vote == null || vote == 0 ? null : vote,
        subtitle: isMovie ? 'Film' : 'TV',
        externalIds: {'tmdb': tid},
      ));
    }
    return out.take(8).toList();
  }

  @override
  Future<MediaResult> enrich(MediaResult result) async {
    try {
      final json = await _get('/${result.sourceId}', const {});
      if (result.type == MediaType.film) {
        return result.copyWith(totalMinutes: (json['runtime'] as int?) ?? 0);
      }
      final seasons = (json['number_of_seasons'] as int?) ?? 1;
      final episodes = (json['number_of_episodes'] as int?) ?? 1;
      final runtimes =
          (json['episode_run_time'] as List?)?.whereType<int>().toList() ??
              const <int>[];
      var perEpisode = runtimes.isEmpty
          ? 0
          : runtimes.reduce((a, b) => a + b) ~/ runtimes.length;
      if (perEpisode == 0) {
        perEpisode =
            ((json['last_episode_to_air'] as Map?)?['runtime'] as int?) ?? 0;
      }
      return result.copyWith(
        totalSeasons: seasons < 1 ? 1 : seasons,
        totalEpisodes: episodes < 1 ? 1 : episodes,
        totalMinutes: perEpisode * episodes,
      );
    } catch (_) {
      return result;
    }
  }
}
