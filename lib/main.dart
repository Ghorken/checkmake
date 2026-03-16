// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:crownfall/l10n/app_localizations.dart';
import 'package:crownfall/models/player_profile.dart';
import 'package:crownfall/screens/main_menu_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const CrownFallApp());
}

class CrownFallApp extends StatelessWidget {
  const CrownFallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PlayerProfile(name: 'Giocatore'),
      child: MaterialApp(
        title: 'Crown Fall',
        debugShowCheckedModeBanner: false,

        // ── Localizzazione ──────────────────────────────────────────
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('it'),
          Locale('en'),
        ],
        // ────────────────────────────────────────────────────────────

        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.amber,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        ),
        home: const MainMenuScreen(),
      ),
    );
  }
}
