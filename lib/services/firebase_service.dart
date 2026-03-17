// lib/services/firebase_service.dart

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:crownfall/models/player_profile.dart';

/// Servizio per tutte le operazioni Firebase relative al multiplayer online.
///
/// STRUTTURA FIRESTORE:
/// /games/{gameCode}:
///   status:    'waiting' | 'playing' | 'finished'
///   createdAt: Timestamp
///   player1:   { uid, name, army, upgrades, wins, losses }
///   player2:   null | { uid, name, army, upgrades, wins, losses }
///   lastMove:  null | { fromRow, fromCol, toRow, toCol, moveIndex }
///   moveCount: int
///   winner:    null | 'player1' | 'player2'
class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String get currentUserId => _auth.currentUser?.uid ?? '';

  /// Accesso anonimo (nessuna registrazione richiesta al giocatore).
  static Future<String> signInAnonymously() async {
    if (_auth.currentUser != null) return _auth.currentUser!.uid;
    final credential = await _auth.signInAnonymously();
    return credential.user!.uid;
  }

  /// Genera un codice partita di 6 caratteri (lettere maiuscole + cifre).
  static String generateGameCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // no caratteri ambigui (0,O,1,I)
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
    final docRef = _db.collection('games').doc(code.toUpperCase());
    final doc = await docRef.get();

    if (!doc.exists) return false;
    final data = doc.data()!;
    if (data['status'] != 'waiting') return false;
    if (data['player2'] != null) return false;

    await docRef.update({
      'player2': {
        ...profile.toJson(),
        'uid': uid,
      },
      'status': 'playing',
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
    final docRef = _db.collection('games').doc(gameCode);
    final snap = await docRef.get();
    final moveCount = (snap.data()?['moveCount'] as int?) ?? 0;

    await docRef.update({
      'lastMove': {
        'fromRow': fromRow,
        'fromCol': fromCol,
        'toRow': toRow,
        'toCol': toCol,
        'moveIndex': moveCount,
      },
      'moveCount': moveCount + 1,
    });
  }

  /// Notifica il server della fine della partita.
  static Future<void> setWinner(String gameCode, String winner) async {
    await _db.collection('games').doc(gameCode).update({
      'status': 'finished',
      'winner': winner,
    });
  }

  /// Stream dei dati della partita in tempo reale.
  static Stream<DocumentSnapshot<Map<String, dynamic>>> watchGame(String gameCode) {
    return _db.collection('games').doc(gameCode).snapshots();
  }

  /// Estrae un [PlayerProfile] dai dati Firestore di un giocatore.
  static PlayerProfile profileFromData(Map<String, dynamic> data) {
    return PlayerProfile.fromJson(data);
  }

  /// Abbandona la partita (imposta lo stato a 'abandoned').
  static Future<void> abandonGame(String gameCode, String loserSide) async {
    final winner = loserSide == 'player1' ? 'player2' : 'player1';
    await _db.collection('games').doc(gameCode).update({
      'status': 'finished',
      'winner': winner,
    });
  }
}
