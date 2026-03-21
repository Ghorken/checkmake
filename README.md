# CheckMake 🏰⚔️

Gioco di scacchi modificato con elementi RPG in stile Clash Royale, sviluppato in Flutter.

## 📁 Struttura del Progetto

```
checkmake/
├── lib/
│   ├── main.dart                          # Entry point
│   ├── models/
│   │   ├── piece.dart                     # Classi Piece, PieceStats, SpecialAbility
│   │   ├── piece_definitions.dart         # Configurazione di tutti i pezzi
│   │   ├── board.dart                     # Scacchiera e Position
│   │   └── player_profile.dart            # Profilo, inventario, esercito
│   ├── providers/
│   │   ├── game_provider.dart             # Logica di gioco (state management)
│   │   └── shop_provider.dart             # Negozio, upgrades, skin
│   ├── services/
│   │   ├── movement_service.dart          # Regole di movimento
│   │   └── combat_service.dart            # Meccanica combattimento
│   ├── widgets/
│   │   ├── piece_widget.dart              # Widget pezzo + placeholder painter
│   │   └── game_board_widget.dart         # Griglia scacchiera
│   └── screens/
│       ├── main_menu_screen.dart          # Menu principale
│       ├── game_screen.dart               # Schermata di gioco
│       ├── shop_screen.dart               # Negozio
│       └── army_builder_screen.dart       # Costruttore esercito
└── assets/
    └── images/
        ├── pieces/      ← Qui vanno le immagini dei pezzi
        ├── ui/          ← Icone e grafica interfaccia
        ├── skins/       ← Skin alternative dei pezzi
        └── boards/      ← Texture alternative per la scacchiera
```

---

## 🖼️ Come Sostituire i Placeholder con Asset Reali

### Convenzione Nomi File

Ogni pezzo ha **4 immagini** — due prospettive × due stati di vita:

```
assets/images/pieces/{piece_id}_back_full.png   → giocatore,   vita piena  (> 50%)
assets/images/pieces/{piece_id}_back_half.png   → giocatore,   vita ridotta (≤ 50%)
assets/images/pieces/{piece_id}_front_full.png  → avversario,  vita piena
assets/images/pieces/{piece_id}_front_half.png  → avversario,  vita ridotta
```

> **`back`** = personaggio visto **di schiena** → pezzi del giocatore (player 1)  
> **`front`** = personaggio visto **di fronte** → pezzi dell'avversario (player 2)

Il path viene calcolato automaticamente da `Piece.imagePath` in base a `piece.side` e `piece.stats.isHalfHp`.

**Lista degli ID pezzi** (`piece_id`):
| ID              | Pezzo                |
|-----------------|----------------------|
| `pawn`          | Pedone               |
| `rook`          | Torre                |
| `knight`        | Cavallo              |
| `bishop`        | Alfiere              |
| `queen`         | Regina               |
| `king`          | Re                   |
| `fighter`       | Combattente          |
| `miner`         | Minatore             |
| `rifleman`      | Fuciliere            |
| `catapult`      | Catapulta            |
| `ironWall`      | Muro di Ferro        |
| `paladin`       | Paladino             |
| `shadowRider`   | Cavaliere Ombra      |
| `healer`        | Curatore             |
| `investigator`  | Investigatore        |
| `invisibleMan`  | Uomo Invisibile      |
| `warlord`       | Condottiera          |
| `heartQueen`    | Regina di Cuori      |
| `soulReaper`    | Rapitrice di Anime   |
| `commander`     | Comandante           |

### Esempio di file per il Pedone

```
assets/images/pieces/pawn_back_full.png    ← pedone giocatore, vita piena
assets/images/pieces/pawn_back_half.png    ← pedone giocatore, ferito
assets/images/pieces/pawn_front_full.png   ← pedone avversario, vita piena
assets/images/pieces/pawn_front_half.png   ← pedone avversario, ferito
```

### Come Funziona il Fallback

Il `PieceWidget` tenta di caricare l'asset PNG; se il file non esiste usa
automaticamente il **placeholder colorato** (simbolo scacchi).
Puoi aggiungere le immagini pezzo per pezzo senza rompere nulla:

```dart
// In PieceWidget (già implementato):
Image.asset(
  piece.imagePath,           // calcolato automaticamente
  fit: BoxFit.contain,
  errorBuilder: (_, __, ___) => _buildPlaceholder(),  // fallback
),
```

### Placeholder durante lo sviluppo

Finché gli asset non sono disponibili il placeholder mostra:
- **Simbolo normale** = pezzi del giocatore (di schiena)
- **Simbolo specchiato orizzontalmente** = pezzi dell'avversario (di fronte)
- **Bordo ciano** → giocatore 1 (tu)
- **Bordo rosso** → giocatore 2 (avversario)
- **Simbolo semitrasparente + crepa** → pezzo a metà vita

### Skin dei Pezzi

Per le skin la convenzione aggiunge il prefisso della skin:
```
assets/images/skins/{skin_id}_{piece_id}_back_full.png
assets/images/skins/{skin_id}_{piece_id}_back_half.png
assets/images/skins/{skin_id}_{piece_id}_front_full.png
assets/images/skins/{skin_id}_{piece_id}_front_half.png
```
Es: `assets/images/skins/army_fire_pawn_back_full.png`

---

## 🎮 Funzionalità Implementate

### Meccanica di Gioco
- ✅ Scacchiera 8x8 con coordinate
- ✅ Movimento valido per tutti i tipi base (pedone, torre, alfiere, cavallo, regina, re)
- ✅ **Combattimento**: quando un pezzo attacca, entrambi si infliggono danni simultaneamente
- ✅ Logica di posizionamento dopo il combattimento (attaccante torna alla casella libera più vicina se entrambi sopravvivono)
- ✅ Guadagno monete per eliminazione pezzi
- ✅ Rilevamento vittoria (re eliminato)
- ✅ Premio monete vittoria/sconfitta
- ✅ Selezione pezzo e visualizzazione mosse valide
- ✅ Turni alternati
- ✅ Nel turno: mossa + abilità speciale (in ordine qualsiasi)

### Pezzi
- ✅ 6 pezzi base
- ✅ 14 pezzi sbloccabili con abilità speciali
- ✅ Statistiche HP/ATK/Valore per ogni pezzo
- ✅ Immagine diversa a metà vita (placeholder con crepa visiva)
- ✅ Le statistiche del tuo giocatore sono visibili, quelle nemiche no

### Negozio
- ✅ Sblocco nuovi pezzi con monete
- ✅ Upgrade di HP, ATK, Valore per ogni pezzo (scalano diversamente)
- ✅ Potenziamento Iniziativa
- ✅ Acquisto Skin (per singoli pezzi o intera armata)

### Esercito
- ✅ Composizione esercito personalizzata
- ✅ Rispetto limiti per tipo base (max 8 pedoni, 2 torri, ecc.)
- ✅ Mix di varianti (es: 3 pedoni + 2 combattenti + 2 fucilieri + 1 minatore)

---

## 🔮 Espansione Futura

### Aggiungere Nuovi Pezzi
1. Aggiungi il valore a `PieceType` enum in `piece.dart`
2. Aggiungi la definizione in `pieceDefinitions` in `piece_definitions.dart`
3. Aggiungi il `PieceBaseType` se è una nuova categoria
4. Aggiorna `pieceMaxCount` se necessario
5. Aggiungi le immagini in `assets/images/pieces/`

### Aggiungere Nuove Modalità di Gioco
Crea una nuova schermata es. `capture_the_flag_screen.dart` e un provider dedicato.
Il `MovementService` e `CombatService` sono riusabili.

### Aggiungere Abilità Speciali
Implementa la logica in `game_provider.dart` nel metodo `useAbility()`.
Le abilità sono già definite per ogni pezzo, manca solo l'effetto concreto.

### Multiplayer Online
Sostituisci la logica "turno avversario" in `GameProvider` con chiamate a un backend/socket.

---

## 🚀 Setup

```bash
flutter pub get
flutter run
```

Dimensioni consigliate per le immagini: **128x128px** o **256x256px** in PNG con sfondo trasparente.
