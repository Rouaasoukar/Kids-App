import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/data/models/user_profile.dart';
import '../../../shared/data/repositories/profile_repository.dart';

// TODO: Full implementation coming in next phase
// For now this is a basic working version

class CreateProfileScreen extends ConsumerStatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  ConsumerState<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends ConsumerState<CreateProfileScreen> {
  final _nameController = TextEditingController();
  final _passcodeController = TextEditingController();
  int _age = 5;
  AvatarType _selectedAvatar = AvatarType.robot;
  AppLanguage _selectedLanguage = AppLanguage.swedish;
  bool _usePasscode = false;
  bool _isSaving = false;

  final _repo = ProfileRepository();

  @override
  void dispose() {
    _nameController.dispose();
    _passcodeController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) return;

    setState(() => _isSaving = true);
    await _repo.init();

    final profile = UserProfile(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      age: _age,
      avatarType: _selectedAvatar,
      language: _selectedLanguage,
      passcode: _usePasscode && _passcodeController.text.isNotEmpty
          ? _passcodeController.text
          : null,
      createdAt: DateTime.now(),
      lastPlayedAt: DateTime.now(),
    );

    await _repo.saveProfile(profile);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ny profil / New Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name
            Text('Namn / Name', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'Skriv namn hÃ¤r...'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 24),

            // Age
            Text('Ã…lder / Age: $_age Ã¥r', style: AppTextStyles.headlineMedium),
            Slider(
              value: _age.toDouble(),
              min: 3,
              max: 16,
              divisions: 13,
              
              onChanged: (v) => setState(() => _age = v.round()),
            ),

            const SizedBox(height: 24),

            // Avatar
            Text('VÃ¤lj avatar / Choose Avatar', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: AvatarType.values.map((avatar) {
                final emojis = {'princess': 'ðŸ‘¸', 'unicorn': 'ðŸ¦„', 'superhero': 'ðŸ¦¸', 'robot': 'ðŸ¤–'};
                final emoji = emojis[avatar.name] ?? 'ðŸ˜€';
                final isSelected = _selectedAvatar == avatar;
                return GestureDetector(
                  onTap: () => setState(() => _selectedAvatar = avatar),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: Center(child: Text(emoji, style: const TextStyle(fontSize: 32))),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Language
            Text('SprÃ¥k / Language', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                _LanguageChip(
                  label: 'ðŸ‡¸ðŸ‡ª Svenska',
                  selected: _selectedLanguage == AppLanguage.swedish,
                  onTap: () => setState(() => _selectedLanguage = AppLanguage.swedish),
                ),
                const SizedBox(width: 12),
                _LanguageChip(
                  label: 'ðŸ‡¬ðŸ‡§ English',
                  selected: _selectedLanguage == AppLanguage.english,
                  onTap: () => setState(() => _selectedLanguage = AppLanguage.english),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Passcode
            SwitchListTile(
              title: Text('LÃ¶senkod / Passcode', style: AppTextStyles.bodyLarge),
              subtitle: const Text('Skydda profilen med en kod'),
              value: _usePasscode,
              
              onChanged: (v) => setState(() => _usePasscode = v),
            ),
            if (_usePasscode) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _passcodeController,
                decoration: const InputDecoration(hintText: 'Ange 4-siffrig kod...'),
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
              ),
            ],

            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Spara / Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.primary : AppColors.neutral),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyLarge.copyWith(
            color: selected ? Colors.white : AppColors.textMedium,
          ),
        ),
      ),
    );
  }
}



