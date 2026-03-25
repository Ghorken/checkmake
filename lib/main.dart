// lib/main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:checkmake/firebase_options.dart';
import 'package:checkmake/l10n/app_localizations.dart';
import 'package:checkmake/models/player_profile.dart';
import 'package:checkmake/screens/main_menu_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // On mobile/desktop, prefer native config files (google-services.json / GoogleService-Info.plist).
  // On web, options must be provided explicitly.
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(const Checkmake());
}

class Checkmake extends StatelessWidget {
  const Checkmake({super.key});

  @override
  Widget build(BuildContext context) {
    const medievalGold = Color(0xFFD4AF37);
    const royalBlue = Color(0xFF1E3A8A);
    const warRed = Color(0xFF8B1E2D);
    const ironBlack = Color(0xFF0B0B10);
    const parchmentWhite = Color(0xFFF8F7F2);

    final base = ThemeData.dark(useMaterial3: true);
    return ChangeNotifierProvider(
      create: (_) => PlayerProfile(name: 'Giocatore'),
      child: MaterialApp(
        title: 'CheckMake',
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

        theme: base.copyWith(
          colorScheme: const ColorScheme.dark(
            primary: medievalGold,
            onPrimary: ironBlack,
            secondary: warRed,
            onSecondary: parchmentWhite,
            surface: Color(0xFF111626),
            onSurface: parchmentWhite,
            error: warRed,
            onError: parchmentWhite,
          ),
          scaffoldBackgroundColor: ironBlack,
          textTheme: GoogleFonts.cinzelTextTheme(base.textTheme).apply(
            bodyColor: parchmentWhite,
            displayColor: medievalGold,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: royalBlue.withValues(alpha: 0.35),
            foregroundColor: parchmentWhite,
            elevation: 0,
            titleTextStyle: GoogleFonts.cinzel(
              color: medievalGold,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.6,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: parchmentWhite,
              textStyle: GoogleFonts.cinzel(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        home: const MainMenuScreen(),
      ),
    );
  }
}
