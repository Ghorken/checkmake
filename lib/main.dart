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
    const brightGold = Color(0xFFFFD700);
    const shadowGold = Color(0xFFB8860B);
    const regalBlue = Color(0xFF1A468E);
    const imperialRed = Color(0xFFB22222);
    const darkStone = Color(0xFF2C3E50);
    const parchmentWhite = Color(0xFFFDF5E6);

    final base = ThemeData.light(useMaterial3: true);
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
          colorScheme: const ColorScheme.light(
            primary: regalBlue,
            onPrimary: parchmentWhite,
            secondary: imperialRed,
            onSecondary: parchmentWhite,
            surface: parchmentWhite,
            onSurface: darkStone,
            error: imperialRed,
            onError: parchmentWhite,
          ),
          scaffoldBackgroundColor: parchmentWhite,
          textTheme: GoogleFonts.cinzelTextTheme(base.textTheme).apply(
            bodyColor: darkStone,
            displayColor: shadowGold,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: darkStone,
            foregroundColor: brightGold,
            elevation: 4,
            shadowColor: Colors.black45,
            centerTitle: true,
            titleTextStyle: GoogleFonts.macondo(
              color: brightGold,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.0,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: darkStone,
              foregroundColor: brightGold,
              textStyle: GoogleFonts.macondo(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                letterSpacing: 1.2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: const BorderSide(color: shadowGold, width: 2),
              ),
              elevation: 4,
            ),
          ),
        ),
        home: const MainMenuScreen(),
      ),
    );
  }
}
