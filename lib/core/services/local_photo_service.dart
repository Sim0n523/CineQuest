import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Persists a captured "movie memory" photo to the app's local
/// documents directory — no cloud upload, no billing account needed.
/// Replaces what was originally Firebase Storage; switched after
/// Firebase Storage dropped its free tier (Feb 2026), which would have
/// required a billing account just to provision a bucket at all.
///
/// One photo per logged movie; re-capturing for the same movie
/// overwrites the previous file, matching how the log entry itself
/// works (one Firestore doc per movie).
///
/// Trade-off, stated plainly: the photo lives only on this device. It
/// won't survive an app uninstall/reinstall and won't show up if this
/// app ever runs on a second device. Fine for a single-device project;
/// would need a real cloud service again if that ever matters.
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
      // Fine if it never existed.
    }
  }
}
