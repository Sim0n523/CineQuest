import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie_model.dart';
import '../../utils/app_constants.dart';

/// Talks to TMDB directly. Nothing else in the app should call `http`
/// for movie data — that always goes through here, and one layer up,
/// through MovieRepository — so the data source stays swappable.
class TMDBService {
  final http.Client _client;

  TMDBService({http.Client? client}) : _client = client ?? http.Client();

  Uri _buildUri(String path, [Map<String, String>? query]) {
    return Uri.parse('${AppConstants.tmdbBaseUrl}$path').replace(
      queryParameters: {
        'api_key': AppConstants.tmdbApiKey,
        'language': 'en-US',
        ...?query,
      },
    );
  }

  Future<List<MovieModel>> getTrending({String timeWindow = 'week'}) async {
    final response = await _client.get(_buildUri('/trending/movie/$timeWindow'));
    _throwIfNotOk(response);
    final results = jsonDecode(response.body)['results'] as List;
    return results
        .map((m) => MovieModel.fromJson(m as Map<String, dynamic>))
        .toList();
  }

  Future<List<MovieModel>> getPopular({int page = 1}) async {
    final response =
        await _client.get(_buildUri('/movie/popular', {'page': '$page'}));
    _throwIfNotOk(response);
    final results = jsonDecode(response.body)['results'] as List;
    return results
        .map((m) => MovieModel.fromJson(m as Map<String, dynamic>))
        .toList();
  }

  Future<List<MovieModel>> searchMovies(String query, {int page = 1}) async {
    if (query.trim().isEmpty) return [];
    final response = await _client
        .get(_buildUri('/search/movie', {'query': query, 'page': '$page'}));
    _throwIfNotOk(response);
    final results = jsonDecode(response.body)['results'] as List;
    return results
        .map((m) => MovieModel.fromJson(m as Map<String, dynamic>))
        .toList();
  }

  Future<MovieModel> getMovieDetails(int movieId) async {
    final response = await _client.get(_buildUri('/movie/$movieId'));
    _throwIfNotOk(response);
    return MovieModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  void _throwIfNotOk(http.Response response) {
    if (response.statusCode != 200) {
      throw TMDBException(
        'TMDB request failed (${response.statusCode}): ${response.body}',
      );
    }
  }
}

class TMDBException implements Exception {
  final String message;
  TMDBException(this.message);

  @override
  String toString() => message;
}
