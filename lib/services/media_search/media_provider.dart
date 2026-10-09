import '../../models/media_entry.dart';
import '../../models/media_result.dart';

abstract class MediaProvider {
  String get id;

  String get name;

  Set<MediaType> get types;

  bool get isConfigured;

  String? get configKey => null;

  Future<List<MediaResult>> search(String query, {MediaType? type});

  Future<MediaResult> enrich(MediaResult result) async => result;
}
