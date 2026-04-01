import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:checkmake/models/player_profile.dart';

class ProfilePersistenceService {
  static const _key = 'player_profile';

  static Future<PlayerProfile> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return PlayerProfile(name: 'Giocatore');
    try {
      return PlayerProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return PlayerProfile(name: 'Giocatore');
    }
  }

  static Future<void> save(PlayerProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(profile.toJson()));
  }
}
