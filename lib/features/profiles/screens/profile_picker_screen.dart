import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../app/router.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/data/models/user_profile.dart';
import '../../../shared/data/repositories/profile_repository.dart';

/// The first screen the app shows — a list of all child profiles on the device.
/// Tapping a profile either asks for a passcode or goes straight to home.
class ProfilePickerScreen extends ConsumerStatefulWidget {
  const ProfilePickerScreen({super.key});

  @override
  ConsumerState<ProfilePickerScreen> createState() =>
      _ProfilePickerScreenState();
}

class _ProfilePickerScreenState extends ConsumerState<ProfilePickerScreen> {
  final _repo = ProfileRepository();
  List<UserProfile> _profiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    await _repo.init();
    setState(() {
      _profiles = _repo.getAllProfiles();
      _isLoading = false;
    });
  }

  void _onProfileTap(UserProfile profile) {
    if (profile.passcode != null) {
      context.push('${AppRoutes.passcode}?profileId=${profile.id}');
    } else {
      context.push('${AppRoutes.home}?profileId=${profile.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            children: [
              const SizedBox(height: 40),

              Text(
                'Vem spelar? 👋',
                style: AppTextStyles.displayLarge,
              ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),

              const SizedBox(height: 8),

              Text(
                'Who is playing?',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textLight,
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 40),

              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _profiles.isEmpty
                        ? _buildEmptyState()
                        : _buildProfileGrid(),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await context.push(AppRoutes.createProfile);
                    _loadProfiles();
                  },
                  icon: const Icon(Icons.add_rounded, size: 24),
                  label: const Text('Ny profil / New Profile'),
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎮', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'Inga profiler ännu!\nNo profiles found.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge,
          ),
        ],
      ).animate().fadeIn(delay: 300.ms),
    );
  }

  Widget _buildProfileGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 160,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: _profiles.length,
      itemBuilder: (context, index) {
        final profile = _profiles[index];
        return _ProfileCard(
          profile: profile,
          onTap: () => _onProfileTap(profile),
        ).animate().fadeIn(delay: (100 * index).ms).scale(begin: const Offset(0.8, 0.8));
      },
    );
  }
}

/// One profile card in the grid — shows avatar emoji, name, and a lock if passcode set
class _ProfileCard extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onTap;

  const _ProfileCard({required this.profile, required this.onTap});

  String get _avatarEmoji {
    switch (profile.avatarType) {
      case AvatarType.princess: return '👸';
      case AvatarType.unicorn:  return '🦄';
      case AvatarType.superhero: return '🦸';
      case AvatarType.robot:    return '🤖';
    }
  }

  Color get _cardColor {
    switch (profile.avatarType) {
      case AvatarType.princess:  return const Color(0xFFFFE4F0);
      case AvatarType.unicorn:   return const Color(0xFFF0E4FF);
      case AvatarType.superhero: return const Color(0xFFE4F0FF);
      case AvatarType.robot:     return const Color(0xFFE4FFF0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Center(
                child: Text(_avatarEmoji, style: const TextStyle(fontSize: 36)),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              profile.name,
              style: AppTextStyles.headlineMedium,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            if (profile.passcode != null)
              const Icon(Icons.lock_rounded, size: 16, color: AppColors.textLight)
            else
              const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
