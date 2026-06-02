import 'package:go_router/go_router.dart';
import '../features/profiles/screens/profile_picker_screen.dart';
import '../features/profiles/screens/create_profile_screen.dart';
import '../features/profiles/screens/passcode_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/exercises/age_3_4/screens/letter_pick_screen.dart';
import '../features/exercises/age_4_7/screens/word_build_screen.dart';
import '../features/exercises/age_7_16/screens/sentence_type_screen.dart';
import '../features/rewards/screens/shop_screen.dart';
import '../features/avatar/screens/avatar_screen.dart';

/// All named routes in the app.
/// Using constants avoids typos when navigating.
class AppRoutes {
  static const String profilePicker = '/';
  static const String createProfile = '/create-profile';
  static const String passcode = '/passcode';
  static const String home = '/home';
  static const String letterPick = '/exercise/letter-pick';
  static const String wordBuild = '/exercise/word-build';
  static const String sentenceType = '/exercise/sentence-type';
  static const String shop = '/shop';
  static const String avatar = '/avatar';
}

/// The app's navigation configuration
final appRouter = GoRouter(
  initialLocation: AppRoutes.profilePicker,
  routes: [
    // --- Profile selection screen (app entry point) ---
    GoRoute(
      path: AppRoutes.profilePicker,
      builder: (context, state) => const ProfilePickerScreen(),
    ),

    // --- Create a new profile ---
    GoRoute(
      path: AppRoutes.createProfile,
      builder: (context, state) => const CreateProfileScreen(),
    ),

    // --- Passcode entry screen ---
    // We pass the profileId as a query parameter: /passcode?profileId=abc123
    GoRoute(
      path: AppRoutes.passcode,
      builder: (context, state) {
        final profileId = state.uri.queryParameters['profileId'] ?? '';
        return PasscodeScreen(profileId: profileId);
      },
    ),

    // --- Home dashboard (shown after profile is selected/unlocked) ---
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) {
        final profileId = state.uri.queryParameters['profileId'] ?? '';
        return HomeScreen(profileId: profileId);
      },
    ),

    // --- Exercises ---
    GoRoute(
      path: AppRoutes.letterPick,
      builder: (context, state) {
        final profileId = state.uri.queryParameters['profileId'] ?? '';
        return LetterPickScreen(profileId: profileId);
      },
    ),
    GoRoute(
      path: AppRoutes.wordBuild,
      builder: (context, state) {
        final profileId = state.uri.queryParameters['profileId'] ?? '';
        return WordBuildScreen(profileId: profileId);
      },
    ),
    GoRoute(
      path: AppRoutes.sentenceType,
      builder: (context, state) {
        final profileId = state.uri.queryParameters['profileId'] ?? '';
        return SentenceTypeScreen(profileId: profileId);
      },
    ),

    // --- Shop (spend points on accessories) ---
    GoRoute(
      path: AppRoutes.shop,
      builder: (context, state) {
        final profileId = state.uri.queryParameters['profileId'] ?? '';
        return ShopScreen(profileId: profileId);
      },
    ),

    // --- Avatar customization ---
    GoRoute(
      path: AppRoutes.avatar,
      builder: (context, state) {
        final profileId = state.uri.queryParameters['profileId'] ?? '';
        return AvatarScreen(profileId: profileId);
      },
    ),
  ],
);
