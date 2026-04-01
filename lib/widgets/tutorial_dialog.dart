import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _gold = Color(0xFFD4AF37);
const _crimson = Color(0xFF8B1E2D);
const _ironBlack = Color(0xFF0A0A0F);
const _parchment = Color(0xFFF0E6D3);
const _darkStone = Color(0xFF1A1A2E);
const _steelBlue = Color(0xFF2B5798);

class TutorialDialog extends StatefulWidget {
  const TutorialDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const TutorialDialog(),
    );
  }

  @override
  State<TutorialDialog> createState() => _TutorialDialogState();
}

class _TutorialDialogState extends State<TutorialDialog> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = [
    _TutorialPage(
      icon: Icons.auto_awesome,
      iconColor: _gold,
      title: 'La filosofia del gioco',
      paragraphs: [
        'CheckMake fonde gli scacchi classici con la profondità di un gioco di ruolo: ogni pezzo non è solo una pedina, ma un combattente con punti vita, attacco e valore.',
        'Le mosse non determinano vincitori istantanei — ogni scontro si risolve in combattimento. Un pedone potenziato può abbattere una regina trascurata.',
        'Costruisci il tuo esercito, potenzia le unità e affronta avversari locali o online nella guerra per la scacchiera.',
      ],
    ),
    _TutorialPage(
      icon: Icons.people,
      iconColor: _steelBlue,
      title: 'Partita locale',
      paragraphs: [
        'Due giocatori si alternano sullo stesso dispositivo, tenuto in orizzontale: il Giocatore 1 guarda dalla parte inferiore, il Giocatore 2 da quella superiore (ruotata).',
        'Nel tuo turno seleziona un pezzo e poi la casella di destinazione. Muovere su un nemico avvia uno scontro automatico basato sulle statistiche.',
        'Vince chi elimina il Re avversario. Entrambi i giocatori condividono la configurazione dell\'esercito del profilo corrente.',
      ],
    ),
    _TutorialPage(
      icon: Icons.wifi,
      iconColor: _crimson,
      title: 'Partita online',
      paragraphs: [
        'Crea una partita e condividi il codice con il tuo avversario, oppure inserisci il codice di una partita esistente per unirti.',
        'I turni sono sincronizzati in tempo reale. Hai 30 secondi per muovere: allo scadere il turno passa all\'avversario.',
        'A fine partita ricevi monete in base all\'esito: vittoria, sconfitta o abbandono. Il tuo esercito e i potenziamenti vengono inviati al server.',
      ],
    ),
    _TutorialPage(
      icon: Icons.monetization_on,
      iconColor: _gold,
      title: 'Monete e negozio',
      paragraphs: [
        'Le monete si guadagnano giocando: 200 per una vittoria, 10 per una sconfitta. Accumula monete per sbloccare nuovi pezzi e potenziamenti.',
        'Nel negozio puoi sbloccare unità speciali con abilità uniche (tab Pezzi) e potenziare HP, Attacco e Valore di ogni pezzo già sbloccato (tab Potenziamenti).',
        'Nella schermata Aspetto puoi acquistare skin cosmetiche per personalizzare l\'aspetto del tuo esercito.',
      ],
    ),
    _TutorialPage(
      icon: Icons.shield,
      iconColor: _steelBlue,
      title: 'Costruzione dell\'esercito',
      paragraphs: [
        'Prima di ogni partita puoi personalizzare la composizione del tuo esercito dalla schermata "Costruisci Esercito".',
        'Ogni tipo di pezzo ha un limite massimo di unità schierabili. Puoi sostituire pezzi base con varianti speciali sbloccate nel negozio.',
        'Una composizione equilibrata è fondamentale: troppi pezzi forti e costosi possono lasciarti senza numero sufficiente di unità sul campo.',
      ],
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFirst = _page == 0;
    final isLast = _page == _pages.length - 1;

    return Dialog(
      backgroundColor: _darkStone,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: _gold.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Text(
              'MANUALE DEL CONDOTTIERO',
              style: GoogleFonts.cinzelDecorative(
                color: _gold,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Divider(color: _gold.withValues(alpha: 0.3)),
            ),
            // PageView
            SizedBox(
              height: 320,
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => _pages[i],
              ),
            ),
            const SizedBox(height: 12),
            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                final active = i == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 18 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: active
                        ? _gold
                        : _gold.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            // Navigation buttons
            Row(
              children: [
                if (!isFirst)
                  TextButton(
                    onPressed: () => _goTo(_page - 1),
                    child: Text(
                      '← Indietro',
                      style: GoogleFonts.cinzel(
                          color: _parchment.withValues(alpha: 0.7),
                          fontSize: 12),
                    ),
                  ),
                const Spacer(),
                if (isLast)
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _gold,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2)),
                    ),
                    child: Text(
                      'Inizia a giocare',
                      style: GoogleFonts.cinzel(
                          color: _ironBlack,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: () => _goTo(_page + 1),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _gold,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2)),
                    ),
                    child: Text(
                      'Avanti →',
                      style: GoogleFonts.cinzel(
                          color: _ironBlack,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TutorialPage extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final List<String> paragraphs;

  const _TutorialPage({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.paragraphs,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.cinzelDecorative(
                    color: _gold,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...paragraphs.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  p,
                  style: GoogleFonts.lora(
                    color: _parchment.withValues(alpha: 0.9),
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
