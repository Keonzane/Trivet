import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/media_entry.dart';
import '../../models/media_result.dart';
import 'media_provider.dart';

class OpenLibraryProvider extends MediaProvider {
  OpenLibraryProvider({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  @override
  String get id => 'openlibrary';

  @override
  String get name => 'Open Library';

  @override
  Set<MediaType> get types => {MediaType.book};

  @override
  bool get isConfigured => true;

  @override
  Future<List<MediaResult>> search(String query, {MediaType? type}) async {
    final uri = Uri.https('openlibrary.org', '/search.json', {
      'q': query,
      'limit': '8',
      'fields': 'key,title,author_name,first_publish_year,cover_i,'
          'number_of_pages_median,ratings_average,isbn',
    });
    final res = await _client.get(uri, headers: {'Accept': 'application/json'});
    if (res.statusCode != 200) {
      throw Exception('Open Library HTTP ${res.statusCode}');
    }
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final out = <MediaResult>[];
    for (final raw in (json['docs'] as List? ?? const [])) {
      final d = raw as Map<String, dynamic>;
      final key = d['key'] as String?;
      final title = d['title'] as String?;
      if (key == null || title == null) continue;
      final workId = key.replaceFirst('/works/', '');
      final cover = d['cover_i'] as int?;
      final authors = (d['author_name'] as List?)?.cast<String>() ?? const [];
      final isbns = (d['isbn'] as List?)?.cast<String>() ?? const [];
      final rating = (d['ratings_average'] as num?)?.toDouble();
      out.add(MediaResult(
        source: id,
        sourceId: workId,
        type: MediaType.book,
        title: title,
        year: d['first_publish_year'] as int?,
        posterUrl: cover == null
            ? null
            : 'https://covers.openlibrary.org/b/id/$cover-M.jpg',
        rating: rating == null ? null : rating * 2,
        subtitle: authors.isEmpty ? null : authors.first,
        externalIds: {
          'openlibrary': workId,
          if (isbns.isNotEmpty) 'isbn': isbns.first,
        },
        totalPages: (d['number_of_pages_median'] as int?) ?? 0,
      ));
    }
    return out;
  }
}
