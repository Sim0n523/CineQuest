import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/models/movie_model.dart';
import '../core/models/watch_history_entry.dart';
import '../core/providers/auth_provider.dart';
import '../core/providers/watch_history_provider.dart';
import '../core/services/progression_service.dart';
import '../core/services/local_photo_service.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../utils/photo_source_picker.dart';
import '../widgets/primary_button.dart';
import '../widgets/star_rating.dart';
import '../widgets/reward_dialog.dart';
import 'nearby_cinemas_screen.dart';

/// Handles both logging a movie for the first time and editing an
/// existing log — pass the current entry via existingEntry to pre-fill
/// the form; leave it null for a fresh log.
class LogMovieScreen extends StatefulWidget {
  final MovieModel movie;
  final WatchHistoryEntry? existingEntry;

  const LogMovieScreen({super.key, required this.movie, this.existingEntry});

  @override
  State<LogMovieScreen> createState() => _LogMovieScreenState();
}

class _LogMovieScreenState extends State<LogMovieScreen> {
  late double _rating;
  late TextEditingController _reviewController;
  late TextEditingController _cinemaController;
  late DateTime _watchDate;
  bool _isSaving = false;

  String? _localPhotoPath; // newly captured this session, not yet uploaded
  String? _existingPhotoPath; // from the existing entry, or after saving

  ImageProvider? get _photoPreview {
    if (_localPhotoPath != null) return FileImage(File(_localPhotoPath!));
    if (_existingPhotoPath != null) return FileImage(File(_existingPhotoPath!));
    return null;
  }

  @override
  void initState() {
    super.initState();
    final existing = widget.existingEntry;
    _rating = existing?.rating ?? 0.0;
    _reviewController = TextEditingController(text: existing?.review ?? '');
    _cinemaController = TextEditingController(text: existing?.cinema ?? '');
    _watchDate = existing?.watchDate ?? DateTime.now();
    _existingPhotoPath = existing?.photoPath;
  }

  @override
  void dispose() {
    _reviewController.dispose();
    _cinemaController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _watchDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _watchDate = picked);
  }

  /// Offers a choice between the custom live-preview camera capture
  /// and picking an existing photo from the gallery (see
  /// utils/photo_source_picker.dart). Either path ends with the same
  /// result: a local temp file path in _localPhotoPath, copied to
  /// permanent storage by LocalPhotoService only once _save() runs — so
  /// nothing downstream of this method needs to care which source was
  /// used.
  Future<void> _pickPhoto() async {
    final path = await pickPhotoFromCameraOrGallery(context);
    if (path != null && mounted) {
      setState(() {
        _localPhotoPath = path;
        _existingPhotoPath = null; // the new photo replaces whatever was there
      });
    }
  }

  Future<void> _save() async {
    final uid = context.read<AuthProvider>().currentUser?.uid;
    if (uid == null) return;

    setState(() => _isSaving = true);

    final isNewLog = widget.existingEntry == null;

    String? photoPath = _existingPhotoPath;
    if (_localPhotoPath != null) {
      try {
        photoPath = await LocalPhotoService().saveMoviePhoto(
          movieId: widget.movie.id,
          capturedFile: File(_localPhotoPath!),
        );
      } catch (e) {
        if (!mounted) return;
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Couldn't save the photo: $e"),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    final entry = WatchHistoryEntry(
      movieId: widget.movie.id,
      movieTitle: widget.movie.title,
      moviePosterPath: widget.movie.posterPath,
      runtimeMinutes: widget.movie.runtime,
      genreIds: widget.movie.genreIds,
      releaseYear: widget.movie.releaseDate?.year,
      rating: _rating == 0.0 ? null : _rating,
      review: _reviewController.text.trim().isEmpty ? null : _reviewController.text.trim(),
      watchDate: _watchDate,
      cinema: _cinemaController.text.trim().isEmpty ? null : _cinemaController.text.trim(),
      photoPath: photoPath,
      loggedAt: widget.existingEntry?.loggedAt ?? DateTime.now(),
      directorId: widget.movie.directorId,
      directorName: widget.movie.directorName,
      leadActorId: widget.movie.leadActorId,
      leadActorName: widget.movie.leadActorName,
    );

    final historyProvider = context.read<WatchHistoryProvider>();
    final success = await historyProvider.logMovie(uid, entry);

    // Progression (XP, levels, achievements) only fires on a brand-new
    // log — never an edit. See ProgressionService for why.
    ProgressionResult? progressionResult;
    if (success && isNewLog && mounted) {
      progressionResult = await context.read<AuthProvider>().recordMovieLogged(
            updatedHistory: historyProvider.watchHistory,
            wroteReview: entry.review != null,
          );
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      // Show the reward (if any) while this screen is still on top —
      // popping first and then showing a dialog would use a context
      // that's about to be disposed.
      if (progressionResult != null) {
        await RewardDialog.show(context, progressionResult);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isNewLog ? 'Logged! 🎬' : 'Log updated'),
            backgroundColor: AppColors.card,
          ),
        );
      }
      if (mounted) Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Couldn't save — check your connection and try again"),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingEntry != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(isEditing ? 'Edit Log' : 'Log Movie')),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 56,
                        height: 84,
                        child: widget.movie.posterUrl != null
                            ? CachedNetworkImage(imageUrl: widget.movie.posterUrl!, fit: BoxFit.cover)
                            : Container(color: AppColors.card),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        widget.movie.title,
                        style: AppTextStyles.h3,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text('Your Rating', style: AppTextStyles.body),
                const SizedBox(height: 8),
                StarRating(
                  rating: _rating,
                  size: 40,
                  onChanged: (value) => setState(() => _rating = value),
                ),
                const SizedBox(height: 24),
                Text('Watch Date', style: AppTextStyles.body),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, color: AppColors.textSecondary, size: 18),
                        const SizedBox(width: 10),
                        Text(_formatDate(_watchDate), style: AppTextStyles.body),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Review (optional)', style: AppTextStyles.body),
                const SizedBox(height: 8),
                TextField(
                  controller: _reviewController,
                  maxLines: 4,
                  style: AppTextStyles.body,
                  decoration: const InputDecoration(hintText: 'What did you think?'),
                ),
                const SizedBox(height: 20),
                Text('Cinema (optional)', style: AppTextStyles.body),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _cinemaController,
                        style: AppTextStyles.body,
                        decoration: const InputDecoration(hintText: 'Where did you watch it?'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Find a nearby cinema',
                      icon: const Icon(Icons.near_me_rounded, color: AppColors.primaryAccent),
                      onPressed: () async {
                        final selected = await Navigator.of(context).push<String>(
                          MaterialPageRoute(
                            builder: (_) => const NearbyCinemasScreen(selectionMode: true),
                          ),
                        );
                        if (selected != null) {
                          _cinemaController.text = selected;
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Photo (optional)', style: AppTextStyles.body),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickPhoto,
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      image: _photoPreview != null
                          ? DecorationImage(image: _photoPreview!, fit: BoxFit.cover)
                          : null,
                    ),
                    child: _photoPreview == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.camera_alt_rounded, color: AppColors.textSecondary, size: 32),
                              const SizedBox(height: 8),
                              Text('Add a photo', style: AppTextStyles.bodySecondary),
                            ],
                          )
                        : Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: GestureDetector(
                                onTap: () => setState(() {
                                  _localPhotoPath = null;
                                  _existingPhotoPath = null;
                                }),
                                child: const CircleAvatar(
                                  backgroundColor: Colors.black54,
                                  radius: 16,
                                  child: Icon(Icons.close_rounded, color: Colors.white, size: 18),
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  label: isEditing ? 'Save Changes' : 'Log This Movie',
                  isLoading: _isSaving,
                  onPressed: _save,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
