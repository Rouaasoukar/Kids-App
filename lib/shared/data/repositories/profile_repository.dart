import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_profile.dart';

/// Handles saving and loading profiles using Hive (local device storage).
/// Think of Hive as a fast key-value drawer: you store something with a key,
/// and retrieve it with the same key.
class ProfileRepository {
  static const String _boxName = 'profiles';
  late Box<Map> _box;

  /// Must be called once at app startup before anything else uses this
  Future<void> init() async {
    _box = await Hive.openBox<Map>(_boxName);
  }

  /// Returns all saved profiles (one per child on the device)
  List<UserProfile> getAllProfiles() {
    return _box.values
        .map((map) => UserProfile.fromMap(Map<String, dynamic>.from(map)))
        .toList()
      ..sort((a, b) => b.lastPlayedAt.compareTo(a.lastPlayedAt));
  }

  /// Returns a single profile by ID, or null if not found
  UserProfile? getProfile(String id) {
    final map = _box.get(id);
    if (map == null) return null;
    return UserProfile.fromMap(Map<String, dynamic>.from(map));
  }

  /// Saves a new profile or updates an existing one
  Future<void> saveProfile(UserProfile profile) async {
    await _box.put(profile.id, profile.toMap());
  }

  /// Permanently deletes a profile
  Future<void> deleteProfile(String id) async {
    await _box.delete(id);
  }

  /// Updates only the score fields — called after every exercise
  Future<void> updateScore(String id, int addPoints, int addStars) async {
    final profile = getProfile(id);
    if (profile == null) return;
    final updated = profile.copyWith(
      points: profile.points + addPoints,
      stars: profile.stars + addStars,
      lastPlayedAt: DateTime.now(),
    );
    await saveProfile(updated);
  }
}
