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

  /// append_to_response=credits pulls director/cast data into this same
  /// call rather than needing a separate /movie/{id}/credits request —
  /// MovieModel.fromJson reads it straight out of json['credits'].
  Future<MovieModel> getMovieDetails(int movieId) async {
    final response =
        await _client.get(_buildUri('/movie/$movieId', {'append_to_response': 'credits'}));
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

  /// Resolves a collection by name (e.g. "Star Wars Collection") to its
  /// TMDB collection id via search — never hardcode a numeric id
  /// directly, since a wrong/stale one would silently show wrong movies.
  Future<int?> searchCollectionId(String query) async {
    final response = await _client.get(_buildUri('/search/collection', {'query': query}));
    _throwIfNotOk(response);
    final results = jsonDecode(response.body)['results'] as List;
    if (results.isEmpty) return null;
    return results.first['id'] as int;
  }

  Future<int?> searchCompanyId(String query) async {
    final response = await _client.get(_buildUri('/search/company', {'query': query}));
    _throwIfNotOk(response);
    final results = jsonDecode(response.body)['results'] as List;
    if (results.isEmpty) return null;
    return results.first['id'] as int;
  }

  Future<int?> searchPersonId(String query) async {
    final response = await _client.get(_buildUri('/search/person', {'query': query}));
    _throwIfNotOk(response);
    final results = jsonDecode(response.body)['results'] as List;
    if (results.isEmpty) return null;
    return results.first['id'] as int;
  }

  /// A TMDB "collection" is a real franchise grouping (Star Wars, Harry
  /// Potter) — this fetches every movie in it directly, no pagination
  /// needed since TMDB returns the full "parts" array in one response.
  Future<List<MovieModel>> getCollectionMovies(int collectionId) async {
    final response = await _client.get(_buildUri('/collection/$collectionId'));
    _throwIfNotOk(response);
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final parts = decoded['parts'] as List? ?? [];
    return parts.map((m) => MovieModel.fromJson(m as Map<String, dynamic>)).toList();
  }

  /// A studio's filmography via /discover/movie — fetches 2 pages
  /// (~40 movies) to reasonably cover prolific studios like Pixar.
  Future<List<MovieModel>> getMoviesByCompany(int companyId) => _discoverByFilter({
        'with_companies': '$companyId',
        'sort_by': 'popularity.desc',
      });

  /// A director's complete filmography via TMDB's person credits
  /// endpoint, filtered to crew entries where job is specifically
  /// "Director" (not producer/writer/editor). No pagination needed —
  /// movie_credits returns the complete list in one call.
  Future<List<MovieModel>> getMoviesDirectedByPerson(int personId) async {
    final credits = await _fetchPersonCredits(personId);
    final directed = (credits['crew'] as List? ?? [])
        .where((c) => (c as Map<String, dynamic>)['job'] == 'Director')
        .toList();
    return _moviesSortedByPopularity(directed);
  }

  /// An actor's filmography via the same endpoint's cast list, capped
  /// to their top-billed appearances (cast order <= 5, roughly "main
  /// cast" rather than "appeared in") and then to the 40 most popular
  /// of those. A prolific actor's complete cast credits can run into
  /// the hundreds once cameos, shorts, and minor roles are included —
  /// uncapped, "complete the collection" would be unreasonable.
  Future<List<MovieModel>> getMoviesActedInByPerson(int personId) async {
    final credits = await _fetchPersonCredits(personId);
    final topBilled = (credits['cast'] as List? ?? [])
        .where((c) => ((c as Map<String, dynamic>)['order'] as int? ?? 999) <= 5)
        .toList();
    final sorted = _moviesSortedByPopularity(topBilled);
    return sorted.length > 40 ? sorted.sublist(0, 40) : sorted;
  }

  Future<Map<String, dynamic>> _fetchPersonCredits(int personId) async {
    final response = await _client.get(_buildUri('/person/$personId/movie_credits'));
    _throwIfNotOk(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// TMDB's credits endpoint doesn't guarantee any particular order —
  /// sorting by popularity (present on cast/crew entries even though
  /// MovieModel itself doesn't store it) surfaces the person's
  /// best-known work first, which matters once a list gets capped.
  List<MovieModel> _moviesSortedByPopularity(List<dynamic> rawCredits) {
    final sorted = [...rawCredits]
      ..sort((a, b) => ((b['popularity'] as num?) ?? 0).compareTo((a['popularity'] as num?) ?? 0));
    return sorted.map((m) => MovieModel.fromJson(m as Map<String, dynamic>)).toList();
  }

  Future<List<MovieModel>> _discoverByFilter(Map<String, String> baseQuery) async {
    final allMovies = <MovieModel>[];
    for (final page in [1, 2]) {
      final response =
          await _client.get(_buildUri('/discover/movie', {...baseQuery, 'page': '$page'}));
      _throwIfNotOk(response);
      final results = jsonDecode(response.body)['results'] as List;
      if (results.isEmpty) break;
      allMovies.addAll(results.map((m) => MovieModel.fromJson(m as Map<String, dynamic>)));
    }
    return allMovies;
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
