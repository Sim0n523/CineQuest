/// Named routes for the top-level auth flow. Feature screens reached by
/// pushing with arguments (Movie Details, Search, etc.) are navigated to
/// directly via MaterialPageRoute rather than listed here, since Flutter's
/// named-route API doesn't pass typed arguments cleanly.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
}
