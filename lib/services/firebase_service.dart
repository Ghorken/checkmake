// lib/services/firebase_service.dart

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:checkmake/models/player_profile.dart';

/// Servizio per tutte le operazioni Firebase relative al multiplayer online.
///
/// STRUTTURA FIRESTORE:
/// /games/{gameCode}:
///   status:    'waiting' | 'playing' | 'finished'
///   createdAt: Timestamp
///   player1:   { uid, name, army, upgrades, wins, losses }
///   player2:   null | { uid, name, army, upgrades, wins, losses }
///   startingSide: 'player1' | 'player2'
///   initiativeTie: bool
///   lastMove:  null | { fromRow, fromCol, toRow, toCol, moveIndex }
///   moveCount: int
///   winner:    null | 'player1' | 'player2'
class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final RegExp _gameCodePattern = RegExp(r'^[A-Z0-9]{6}$');

  static String get currentUserId => _auth.currentUser?.uid ?? '';
  static bool isValidGameCode(String input) =>
      _gameCodePattern.hasMatch(input.trim().toUpperCase());

  static String _normalizeGameCode(String input) {
    final code = input.trim().toUpperCase();
    if (!_gameCodePattern.hasMatch(code)) {
      throw ArgumentError.value(
        input,
        'gameCode',
        'Codice partita non valido. Usa 6 caratteri alfanumerici (A-Z, 0-9).',
      );
    }
    return code;
  }

  /// Accesso anonimo (nessuna registrazione richiesta al giocatore).
  static Future<String> signInAnonymously() async {
    if (_auth.currentUser != null) return _auth.currentUser!.uid;
    final credential = await _auth.signInAnonymously();
    return credential.user!.uid;
  }

  /// Genera un codice partita di 6 caratteri (lettere maiuscole + cifre).
  static String generateGameCode() {
    const chars =
        'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // no caratteri ambigui (0,O,1,I)
    final random = Random.secure();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// Crea una nuova stanza e carica il profilo del giocatore come player1.
  /// Restituisce il codice della partita.
  static Future<String> createGame(PlayerProfile profile) async {
    final uid = await signInAnonymously();
    final code = generateGameCode();

    await _db.collection('games').doc(code).set({
      'status': 'waiting',
      'createdAt': FieldValue.serverTimestamp(),
      'player1': {
        ...profile.toJson(),
        'uid': uid,
      },
      'player2': null,
      'startingSide': null,
      'initiativeTie': null,
      'lastMove': null,
      'moveCount': 0,
      'winner': null,
    });

    return code;
  }

  /// Unisce il giocatore a una stanza esistente come player2.
  /// Restituisce `true` se l'operazione è riuscita, `false` se il codice non è valido
  /// o la stanza è già piena.
  static Future<bool> joinGame(String code, PlayerProfile profile) async {
    final uid = await signInAnonymously();
    final normalizedCode = _normalizeGameCode(code);
    final docRef = _db.collection('games').doc(normalizedCode);
    final doc = await docRef.get();

    if (!doc.exists) return false;
    final data = doc.data()!;
    if (data['status'] != 'waiting') return false;
    if (data['player2'] != null) return false;

    final player1Data = data['player1'] as Map<String, dynamic>?;
    final p1Initiative = (player1Data?['initiative'] as int?) ?? 1;
    final p2Initiative = profile.initiative;
    final tie = p2Initiative == p1Initiative;
    final startingSide = p2Initiative > p1Initiative
        ? 'player2'
        : p2Initiative < p1Initiative
            ? 'player1'
            : (Random.secure().nextBool() ? 'player1' : 'player2');

    await docRef.update({
      'player2': {
        ...profile.toJson(),
        'uid': uid,
      },
      'status': 'playing',
      'startingSide': startingSide,
      'initiativeTie': tie,
    });

    return true;
  }

  /// Invia una mossa al server.
  static Future<void> sendMove(
    String gameCode,
    int fromRow,
    int fromCol,
    int toRow,
    int toCol,
  ) async {
    final normalizedCode = _normalizeGameCode(gameCode);
    final docRef = _db.collection('games').doc(normalizedCode);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      final moveCount = (snap.data()?['moveCount'] as int?) ?? 0;
      tx.update(docRef, {
        'lastMove': {
          'fromRow': fromRow,
          'fromCol': fromCol,
          'toRow': toRow,
          'toCol': toCol,
          'moveIndex': moveCount,
          'movedBy': currentUserId,
        },
        'moveCount': moveCount + 1,
      });
    });
  }

  /// Notifica il server della fine della partita.
  static Future<void> setWinner(String gameCode, String winner) async {
    final normalizedCode = _normalizeGameCode(gameCode);
    final docRef = _db.collection('games').doc(normalizedCode);
    await docRef.update({
      'status': 'finished',
      'winner': winner,
    });
    await docRef.delete();
  }

  /// Stream dei dati della partita in tempo reale.
  static Stream<DocumentSnapshot<Map<String, dynamic>>> watchGame(
      String gameCode) {
    final normalizedCode = _normalizeGameCode(gameCode);
    return _db.collection('games').doc(normalizedCode).snapshots();
  }

  /// Estrae un [PlayerProfile] dai dati Firestore di un giocatore.
  static PlayerProfile profileFromData(Map<String, dynamic> data) {
    return PlayerProfile.fromJson(data);
  }

  /// Abbandona la partita (imposta lo stato a 'abandoned').
  static Future<void> abandonGame(String gameCode, String loserSide) async {
    final winner = loserSide == 'player1' ? 'player2' : 'player1';
    final normalizedCode = _normalizeGameCode(gameCode);
    final docRef = _db.collection('games').doc(normalizedCode);
    await docRef.update({
      'status': 'finished',
      'winner': winner,
    });
    await docRef.delete();
  }

  /// Cancella una stanza in attesa (usato quando il creator annulla il matchmaking).
  static Future<void> cancelWaitingGame(String gameCode) async {
    final normalizedCode = _normalizeGameCode(gameCode);
    final docRef = _db.collection('games').doc(normalizedCode);
    final snap = await docRef.get();
    if (!snap.exists) return;

    final data = snap.data();
    if (data?['status'] == 'waiting') {
      await docRef.delete();
    }
  }
}
