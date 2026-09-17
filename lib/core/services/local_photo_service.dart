import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Persists a captured "movie memory" photo to the app's local
/// documents directory — no cloud upload, no billing account needed.
///
/// One photo per logged movie; re-capturing for the same movie
/// overwrites the previous file.
///
/// Trade-off: the photo lives only on this device and won't survive an
/// uninstall or show up on a second device.
class LocalPhotoService {
  Future<String> saveMoviePhoto({required int movieId, required File capturedFile}) async {
    final directory = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${directory.path}/movie_photos');
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }

    final savedPath = '${photosDir.path}/$movieId.jpg';
    final target = File(savedPath);
    if (await target.exists()) {
      await target.delete();
    }
    await capturedFile.copy(savedPath);
    return savedPath;
  }

  Future<void> deleteMoviePhoto(int movieId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/movie_photos/$movieId.jpg');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
    }
  }
}
