// Firebase imports — only used on iOS/Android builds
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';

/// Syncs profiles to Firebase Firestore so a child can use multiple devices.
///
/// How it works:
/// 1. When the app starts, we sign in anonymously (no email needed)
/// 2. Each device gets a unique Firebase user ID
/// 3. Profiles are stored in Firestore under that user ID
/// 4. When profiles change locally, we push to Firestore
/// 5. On a new device, the child enters a "family code" to link devices
///
/// Firestore structure:
///   users/{userId}/profiles/{profileId}  → UserProfile data
///   users/{userId}/metadata              → deviceName, lastSeen
class FirebaseRepository {
  // TODO: Uncomment when Firebase is fully configured
  // final _auth = FirebaseAuth.instance;
  // final _db = FirebaseFirestore.instance;

  bool _isAvailable = false;
  String? _userId;

  bool get isAvailable => _isAvailable;
  String? get userId => _userId;

  /// Initialize — signs in anonymously and sets up the user ID
  Future<void> init() async {
    // TODO: Enable when google-services files are in place
    // try {
    //   final credential = await _auth.signInAnonymously();
    //   _userId = credential.user?.uid;
    //   _isAvailable = _userId != null;
    // } catch (e) {
    //   _isAvailable = false;
    // }
    _isAvailable = false; // placeholder until Firebase is enabled
  }

  /// Upload a profile to Firestore
  Future<void> syncProfile(UserProfile profile) async {
    if (!_isAvailable || _userId == null) return;
    // TODO: enable when Firebase is configured
    // await _db
    //     .collection('users')
    //     .doc(_userId)
    //     .collection('profiles')
    //     .doc(profile.id)
    //     .set(profile.toMap(), SetOptions(merge: true));
  }

  /// Download all profiles for this user from Firestore
  Future<List<UserProfile>> fetchProfiles() async {
    if (!_isAvailable || _userId == null) return [];
    // TODO: enable when Firebase is configured
    // final snapshot = await _db
    //     .collection('users')
    //     .doc(_userId)
    //     .collection('profiles')
    //     .get();
    // return snapshot.docs
    //     .map((d) => UserProfile.fromMap(d.data()))
    //     .toList();
    return [];
  }

  /// Delete a profile from Firestore
  Future<void> deleteProfile(String profileId) async {
    if (!_isAvailable || _userId == null) return;
    // TODO: enable when Firebase is configured
    // await _db
    //     .collection('users')
    //     .doc(_userId)
    //     .collection('profiles')
    //     .doc(profileId)
    //     .delete();
  }
}

final firebaseRepository = FirebaseRepository();
