import '../../utils/collection_config.dart';
import 'movie_model.dart';

class CollectionProgress {
  final CollectionDefinition definition;
  final List<MovieModel> movies;
  final int loggedCount;
  final bool isComplete;

  const CollectionProgress({
    required this.definition,
    required this.movies,
    required this.loggedCount,
    required this.isComplete,
  });
}
