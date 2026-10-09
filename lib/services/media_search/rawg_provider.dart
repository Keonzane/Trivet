import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/media_entry.dart';
import '../../models/media_result.dart';
import 'media_provider.dart';
import 'media_search_config.dart';

class RawgProvider extends MediaProvider {
  RawgProvider({http.Client? client, String? proxyUrl})
      : _client = client ?? http.Client(),
        _proxyUrl = proxyUrl ?? MediaSearchConfig.proxyUrl;

  final http.Client _client;
  final String _proxyUrl;

  static const creditText = 'Game data from RAWG';
  static final creditUrl = Uri.parse('https://rawg.io');

  @override
  String get id => 'rawg';

  @override
  String get name => 'RAWG';

  @override
  String get configKey => 'MEDIA_PROXY_URL';

  @override
  Set<MediaType> get types => {MediaType.game};

  @override
  bool get isConfigured => _proxyUrl.isNotEmpty;

  @override
  Future<List<MediaResult>> search(String query, {MediaType? type}) async {
    final uri =
        Uri.parse('$_proxyUrl/rawg/api/games').replace(queryParameters: {
      'search': query,
      'page_size': '20',
      'search_precise': 'true',
      'exclude_additions': 'true',
    });
    final res = await _client.get(uri, headers: {'Accept': 'application/json'});
    if (res.statusCode != 200) {
      throw Exception('RAWG via proxy HTTP ${res.statusCode}: ${res.body}');
    }
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final games = [
      for (final raw in (json['results'] as List? ?? const []))
        if (raw is Map<String, dynamic>) raw,
    ]..sort((a, b) => _popularity(b).compareTo(_popularity(a)));
    final known = games.where((g) => _popularity(g) > 0).toList();
    final out = <MediaResult>[];
    for (final g in (known.isEmpty ? games : known).take(8)) {
      final title = g['name'] as String?;
      if (title == null) continue;
      final released = g['released'] as String?;
      final rating = (g['rating'] as num?)?.toDouble();
      final playtime = (g['playtime'] as int?) ?? 0;
      final platforms = _platforms(g);
      final details = [
        if (platforms.isNotEmpty) platforms.take(3).join(', '),
        if (playtime > 0) '~$playtime h avg',
      ];
      out.add(MediaResult(
        source: id,
        sourceId: '${g['id']}',
        type: MediaType.game,
        title: title,
        year: released == null || released.length < 4
            ? null
            : int.tryParse(released.substring(0, 4)),
        posterUrl: _thumb(g['background_image'] as String?),
        rating: rating == null || rating == 0 ? null : rating * 2,
        subtitle: details.isEmpty ? null : details.join(' · '),
        externalIds: {
          'rawg': '${g['id']}',
          if (g['slug'] is String) 'rawg_slug': g['slug'] as String,
        },
      ));
    }
    return out;
  }

  int _popularity(Map<String, dynamic> g) =>
      ((g['added'] as int?) ?? 0) + ((g['ratings_count'] as int?) ?? 0);

  List<String> _platforms(Map<String, dynamic> g) => [
        for (final p in (g['parent_platforms'] as List? ?? const []))
          if (p is Map &&
              p['platform'] is Map &&
              p['platform']['name'] is String)
            p['platform']['name'] as String,
      ];

  String? _thumb(String? url) {
    if (url == null) return null;
    const marker = '/media/';
    final i = url.indexOf(marker);
    if (i < 0 || url.contains('/media/crop/')) return url;
    return '${url.substring(0, i + marker.length)}crop/600/400/'
        '${url.substring(i + marker.length)}';
  }
}
