import 'dart:io';

import 'package:checkmake/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

const _gold = Color(0xFFD4AF37);
const _ironBlack = Color(0xFF0A0A0F);
const _darkStone = Color(0xFF1A1A2E);

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  String _markdownContent = '';

  @override
  void initState() {
    super.initState();
    _loadMarkdown();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: _ironBlack,
      appBar: AppBar(
        backgroundColor: _darkStone.withValues(alpha: 0.95),
        title: Text(
          l10n.infoTitle,
          style: GoogleFonts.cinzelDecorative(color: _gold, fontSize: 18),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _darkStone.withValues(alpha: 0.3),
              _ironBlack,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.bugRequestTitle,
                  style: const TextStyle(
                      fontSize: 20.0, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.joinDiscordTitle,
                  style: const TextStyle(
                      fontSize: 18.0, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _openDiscord(context),
                  child: Image.asset('assets/icons/discord.png', height: 150),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.sendEmailTitle,
                  style: const TextStyle(
                      fontSize: 18.0, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => _sendEmail(context),
                  child: Text(
                    l10n.supportEmail,
                    style: const TextStyle(
                      fontSize: 18.0,
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.privacyTitle,
                  style: const TextStyle(
                      fontSize: 18.0, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        child: MarkdownBody(
                          data: _markdownContent,
                          styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(
                              color: Colors.white70,
                              height: 1.4,
                            ),
                            h1: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            h2: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            h3: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            listBullet: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadMarkdown() async {
    final String policyPath = Platform.localeName.contains('it')
        ? 'assets/privacy/privacy_it.md'
        : 'assets/privacy/privacy_en.md';
    final String content = await rootBundle.loadString(policyPath);
    if (!mounted) {
      return;
    }
    setState(() {
      _markdownContent = content;
    });
  }

  Future<void> _openDiscord(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final Uri url = Uri.parse(l10n.discordUrl);
    final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      _showError(context, l10n.urlError(url.toString()));
    }
  }

  Future<void> _sendEmail(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: l10n.supportEmail,
      queryParameters: {'subject': l10n.supportSubject},
    );
    final ok = await launchUrl(emailUri);
    if (!ok && context.mounted) {
      _showError(context, l10n.urlError(l10n.supportEmail));
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
