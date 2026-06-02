import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../app/router.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/data/repositories/profile_repository.dart';

/// A PIN-entry screen shown when a profile has a passcode.
/// The child taps 4 digits on the number pad.
class PasscodeScreen extends StatefulWidget {
  final String profileId;
  const PasscodeScreen({super.key, required this.profileId});

  @override
  State<PasscodeScreen> createState() => _PasscodeScreenState();
}

class _PasscodeScreenState extends State<PasscodeScreen> {
  final _repo = ProfileRepository();
  String _entered = '';
  bool _isWrong = false;

  void _onDigitTap(String digit) {
    if (_entered.length >= 4) return;
    setState(() {
      _entered += digit;
      _isWrong = false;
    });
    if (_entered.length == 4) _checkPasscode();
  }

  void _onDelete() {
    if (_entered.isEmpty) return;
    setState(() => _entered = _entered.substring(0, _entered.length - 1));
  }

  Future<void> _checkPasscode() async {
    await _repo.init();
    final profile = _repo.getProfile(widget.profileId);
    if (profile == null) return;

    if (_entered == profile.passcode) {
      if (mounted) {
        context.pushReplacement('${AppRoutes.home}?profileId=${widget.profileId}');
      }
    } else {
      setState(() {
        _isWrong = true;
        _entered = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
            const Spacer(),

            const Text('🔒', style: TextStyle(fontSize: 56))
                .animate(target: _isWrong ? 1 : 0)
                .shake(hz: 4, offset: const Offset(6, 0)),

            const SizedBox(height: 16),
            Text('Ange kod / Enter code',
                style: AppTextStyles.headlineMedium),

            if (_isWrong) ...[
              const SizedBox(height: 8),
              Text('Fel kod! / Wrong code!',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.wrong))
                  .animate().fadeIn(),
            ],

            const SizedBox(height: 32),

            // Dots showing how many digits entered
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final filled = i < _entered.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled ? AppColors.primary : AppColors.neutral,
                  ),
                );
              }),
            ),

            const Spacer(),

            // Number pad
            _NumberPad(onDigit: _onDigitTap, onDelete: _onDelete),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _NumberPad extends StatelessWidget {
  final void Function(String) onDigit;
  final VoidCallback onDelete;

  const _NumberPad({required this.onDigit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final buttons = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '⌫'],
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: buttons.map((row) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((label) {
              if (label.isEmpty) return const SizedBox(width: 72, height: 72);
              return GestureDetector(
                onTap: () => label == '⌫' ? onDelete() : onDigit(label),
                child: Container(
                  width: 72,
                  height: 72,
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: AppTextStyles.headlineLarge,
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}
