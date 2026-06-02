import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../app/router.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/data/models/user_profile.dart';
import '../../../shared/data/repositories/profile_repository.dart';

/// The main dashboard after a child logs in.
/// Shows their avatar, points/stars, and big buttons to Play and Shop.
class HomeScreen extends StatefulWidget {
  final String profileId;
  const HomeScreen({super.key, required this.profileId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repo = ProfileRepository();
  UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    await _repo.init();
    setState(() => _profile = _repo.getProfile(widget.profileId));
  }

  String get _exerciseRoute {
    switch (_profile?.ageGroup) {
      case AgeGroup.early:
        return AppRoutes.letterPick;
      case AgeGroup.middle:
        return AppRoutes.wordBuild;
      case AgeGroup.advanced:
        return AppRoutes.sentenceType;
      case null:
        return AppRoutes.letterPick;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final avatarEmojis = {
      AvatarType.princess: 'ðŸ‘¸',
      AvatarType.unicorn: 'ðŸ¦„',
      AvatarType.superhero: 'ðŸ¦¸',
      AvatarType.robot: 'ðŸ¤–',
    };
    final emoji = avatarEmojis[_profile!.avatarType] ?? 'ðŸ˜€';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEDE7FF), Color(0xFFF8F4FF)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // --- Top bar: back + profile name ---
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => context.go(AppRoutes.profilePicker),
                    ),
                    const Spacer(),
                    Text(_profile!.name, style: AppTextStyles.headlineMedium),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),

                const SizedBox(height: 16),

                // --- Avatar ---
                GestureDetector(
                  onTap: () => context.push(
                      '${AppRoutes.avatar}?profileId=${widget.profileId}'),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(emoji,
                          style: const TextStyle(fontSize: 64)),
                    ),
                  ),
                ).animate().scale(delay: 200.ms),

                const SizedBox(height: 8),
                Text('Tryck fÃ¶r att anpassa / Tap to customize',
                    style: AppTextStyles.bodyMedium),

                const SizedBox(height: 24),

                // --- Points and Stars row ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _RewardBadge(
                      emoji: 'â­',
                      label: '${_profile!.points}',
                      sublabel: 'poÃ¤ng',
                      color: AppColors.pointsBadge,
                    ),
                    const SizedBox(width: 16),
                    _RewardBadge(
                      emoji: 'ðŸŒŸ',
                      label: '${_profile!.stars}',
                      sublabel: 'stjÃ¤rnor',
                      color: AppColors.star,
                    ),
                  ],
                ).animate().fadeIn(delay: 300.ms),

                const Spacer(),

                // --- Play button ---
                _BigButton(
                  emoji: 'ðŸŽ®',
                  label: 'Spela! / Play!',
                  color: AppColors.primary,
                  onTap: () => context.push(
                      '$_exerciseRoute?profileId=${widget.profileId}'),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),

                const SizedBox(height: 16),

                // --- Shop button ---
                _BigButton(
                  emoji: 'ðŸ›ï¸',
                  label: 'Butik / Shop',
                  color: AppColors.secondary,
                  onTap: () => context.push(
                      '${AppRoutes.shop}?profileId=${widget.profileId}'),
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RewardBadge extends StatelessWidget {
  final String emoji, label, sublabel;
  final Color color;

  const _RewardBadge({
    required this.emoji,
    required this.label,
    required this.sublabel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.headlineMedium),
              Text(sublabel, style: AppTextStyles.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }
}

class _BigButton extends StatelessWidget {
  final String emoji, label;
  final Color color;
  final VoidCallback onTap;

  const _BigButton({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Text(label,
                style: AppTextStyles.buttonLabel
                    .copyWith(color: Colors.white, fontSize: 20)),
          ],
        ),
      ),
    );
  }
}

