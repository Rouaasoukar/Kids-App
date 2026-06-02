import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app/router.dart';
import 'shared/theme/app_theme.dart';
import 'shared/audio/tts_service.dart';
import 'features/ai/gemini_service.dart';

void main() async {
  // Must be called before anything async in main()
  WidgetsFlutterBinding.ensureInitialized();

  // Lock the app to portrait mode (best for kids)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Load API keys from .env file (never committed to GitHub)
  await dotenv.load(fileName: '.env');

  // Initialize Hive (local storage) in the device's documents folder
  await Hive.initFlutter();

  // Initialize Text-to-Speech engine
  await ttsService.init();

  // Initialize Gemini AI (gracefully does nothing if key is missing)
  await geminiService.init();

  // TODO: Initialize Firebase when google-services.json is added
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ProviderScope wraps the whole app so Riverpod state management works
  runApp(const ProviderScope(child: KidsApp()));
}

class KidsApp extends StatelessWidget {
  const KidsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Kids Learning App',
      debugShowCheckedModeBanner: false,

      // Apply our custom theme
      theme: AppTheme.light,

      // Navigation
      routerConfig: appRouter,

      // Localization — supports Swedish and English
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('sv'), // Swedish
        Locale('en'), // English
      ],
      // Default to Swedish
      locale: const Locale('sv'),
    );
  }
}
