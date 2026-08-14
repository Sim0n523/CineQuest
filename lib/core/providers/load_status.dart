/// Shared loading-state enum used by any provider that fetches async data.
/// Pulled into its own file (rather than declared inside MovieProvider)
/// once WatchHistoryProvider needed the same states in Phase 2.
enum LoadStatus { initial, loading, loaded, error }
