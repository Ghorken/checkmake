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
import 'package:checkmake/services/profile_persistence_service.dart';

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
  final profile = await ProfilePersistenceService.load();
  runApp(Checkmake(profile: profile));
}

class Checkmake extends StatelessWidget {
  final PlayerProfile profile;
  const Checkmake({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    const medievalGold = Color(0xFFD4AF37);
    const bloodRed = Color(0xFF6B0F1A);
    const deepCrimson = Color(0xFF8B1E2D);
    const ironBlack = Color(0xFF0A0A0F);
    const parchmentWhite = Color(0xFFF0E6D3);
    const darkStone = Color(0xFF1A1A2E);
    const burnishedBronze = Color(0xFFCD7F32);

    final base = ThemeData.dark(useMaterial3: true);

    // Cinzel Decorative for titles, Cinzel for body
    final cinzelTextTheme = GoogleFonts.cinzelTextTheme(base.textTheme);

    profile.addListener(() => ProfilePersistenceService.save(profile));

    return ChangeNotifierProvider.value(
      value: profile,
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
            secondary: deepCrimson,
            onSecondary: parchmentWhite,
            surface: darkStone,
            onSurface: parchmentWhite,
            error: bloodRed,
            onError: parchmentWhite,
            tertiary: burnishedBronze,
          ),
          scaffoldBackgroundColor: ironBlack,
          textTheme: cinzelTextTheme.apply(
            bodyColor: parchmentWhite,
            displayColor: medievalGold,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: const Color(0xFF120E1A).withValues(alpha: 0.95),
            foregroundColor: parchmentWhite,
            elevation: 0,
            titleTextStyle: GoogleFonts.cinzelDecorative(
              color: medievalGold,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: parchmentWhite,
              textStyle: GoogleFonts.cinzel(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          cardTheme: CardThemeData(
            color: darkStone,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
              side: BorderSide(
                color: medievalGold.withValues(alpha: 0.2),
              ),
            ),
          ),
          dividerTheme: DividerThemeData(
            color: medievalGold.withValues(alpha: 0.3),
            thickness: 1,
          ),
          dialogTheme: const DialogThemeData(
            backgroundColor: Color(0xFF1A1A2E),
            titleTextStyle: TextStyle(
              color: medievalGold,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        home: const MainMenuScreen(),
      ),
    );
  }
}
