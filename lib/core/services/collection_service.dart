import '../models/movie_model.dart';
import '../services/tmdb_service.dart';
import '../../utils/collection_config.dart';

/// Resolves a CollectionDefinition to its actual movie list. Delegates
/// the raw TMDB calls to TMDBService; this layer's job is just picking
/// the right search-then-fetch path per source type.
class CollectionService {
  final TMDBService _tmdbService;

  CollectionService({TMDBService? tmdbService}) : _tmdbService = tmdbService ?? TMDBService();

  Future<List<MovieModel>> fetchMovies(CollectionDefinition definition) async {
    switch (definition.sourceType) {
      case CollectionSourceType.tmdbCollection:
        final id = await _tmdbService.searchCollectionId(definition.searchQuery);
        if (id == null) {
          throw TMDBException('Could not find "${definition.searchQuery}" on TMDB.');
        }
        return _tmdbService.getCollectionMovies(id);

      case CollectionSourceType.studio:
        final id = await _tmdbService.searchCompanyId(definition.searchQuery);
        if (id == null) {
          throw TMDBException('Could not find studio "${definition.searchQuery}" on TMDB.');
        }
        return _tmdbService.getMoviesByCompany(id);

      case CollectionSourceType.director:
        final id = await _tmdbService.searchPersonId(definition.searchQuery);
        if (id == null) {
          throw TMDBException('Could not find "${definition.searchQuery}" on TMDB.');
        }
        return _tmdbService.getMoviesDirectedByPerson(id);

      case CollectionSourceType.actor:
        final id = await _tmdbService.searchPersonId(definition.searchQuery);
        if (id == null) {
          throw TMDBException('Could not find "${definition.searchQuery}" on TMDB.');
        }
        return _tmdbService.getMoviesActedInByPerson(id);
    }
  }
}
