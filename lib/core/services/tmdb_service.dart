import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie_model.dart';
import '../../utils/app_constants.dart';

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

  /// TMDB's actual discovery endpoint — supports genre filtering and
  /// several sort orders in one call, so genre + "Top Rated"/"Newest"
  /// combine naturally (e.g. top-rated horror).
  Future<List<MovieModel>> discoverMovies({
    int? genreId,
    String sortBy = 'popularity.desc',
    int page = 1,
  }) async {
    final query = <String, String>{'sort_by': sortBy, 'page': '$page'};
    if (genreId != null) query['with_genres'] = '$genreId';
    // Without a vote-count floor, "sort by rating" surfaces obscure
    // titles with a single 10/10 vote — mirrors what TMDB's own
    // /movie/top_rated does internally.
    if (sortBy == 'vote_average.desc') query['vote_count.gte'] = '200';
    if (sortBy == 'primary_release_date.desc') {
      query['primary_release_date.lte'] = DateTime.now().toIso8601String().split('T').first;
    }
    // Upcoming: mirror image of "Newest" — only unreleased movies,
    // soonest first.
    if (sortBy == 'primary_release_date.asc') {
      query['primary_release_date.gte'] = DateTime.now().toIso8601String().split('T').first;
    }
    final response = await _client.get(_buildUri('/discover/movie', query));
    _throwIfNotOk(response);
    final results = jsonDecode(response.body)['results'] as List;
    return results
        .map((m) => MovieModel.fromJson(m as Map<String, dynamic>))
        .toList();
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
