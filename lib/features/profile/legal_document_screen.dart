import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../core/utils/legal_documents.dart';

/// Renders a legal document (Privacy Policy / Terms of Service) from the
/// canonical Markdown source in `legal_documents.dart`, replacing the old
/// placeholder pages.
///
/// Picks the French version when the app locale is French. Uses a small
/// built-in renderer for the subset of Markdown the documents use (headings,
/// bullet lists, bold, paragraphs) so no extra dependency is needed.
class LegalDocumentScreen extends StatelessWidget {
  final String title;
  final String markdown;

  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.markdown,
  });

  /// Privacy Policy in the app's current locale.
  static LegalDocumentScreen privacyPolicyOf(BuildContext context) {
    final isFrench = Localizations.localeOf(context).languageCode == 'fr';
    return isFrench
        ? const LegalDocumentScreen(
            title: 'Politique de confidentialité',
            markdown: kPrivacyPolicyMarkdownFr,
          )
        : const LegalDocumentScreen(
            title: 'Privacy Policy',
            markdown: kPrivacyPolicyMarkdown,
          );
  }

  /// Terms of Service in the app's current locale.
  static LegalDocumentScreen termsOfServiceOf(BuildContext context) {
    final isFrench = Localizations.localeOf(context).languageCode == 'fr';
    return isFrench
        ? const LegalDocumentScreen(
            title: "Conditions d'utilisation",
            markdown: kTermsOfServiceMarkdownFr,
          )
        : const LegalDocumentScreen(
            title: 'Terms of Service',
            markdown: kTermsOfServiceMarkdown,
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: _parseBlocks(context, markdown),
        ),
      ),
    );
  }

  List<Widget> _parseBlocks(BuildContext context, String markdown) {
    final widgets = <Widget>[];
    final lines = markdown.split('\n');
    final paragraphBuffer = <String>[];

    void flushParagraph() {
      if (paragraphBuffer.isEmpty) return;
      final text = paragraphBuffer.join(' ').trim();
      if (text.isNotEmpty) {
        widgets.add(_RichTextLine(text: text));
        widgets.add(const SizedBox(height: 12));
      }
      paragraphBuffer.clear();
    }

    for (final rawLine in lines) {
      final line = rawLine.trimRight();
      if (line.trim().isEmpty) {
        flushParagraph();
        continue;
      }
      if (line.startsWith('## ')) {
        flushParagraph();
        widgets.add(Text(
          _stripEmphasis(line.substring(3)),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: SawaLoveTheme.onSurface,
              ),
        ));
        widgets.add(const SizedBox(height: 8));
      } else if (line.startsWith('# ')) {
        flushParagraph();
        widgets.add(Text(
          _stripEmphasis(line.substring(2)),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: SawaLoveTheme.onSurface,
              ),
        ));
        widgets.add(const SizedBox(height: 12));
      } else {
        final trimmed = line.trimLeft();
        if (trimmed.startsWith('- ')) {
          flushParagraph();
          final bullet = trimmed.substring(2);
          widgets.add(Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('•  '),
                Expanded(child: _RichTextLine(text: bullet)),
              ],
            ),
          ));
        } else {
          paragraphBuffer.add(line.trim());
        }
      }
    }
    flushParagraph();
    return widgets;
  }

  String _stripEmphasis(String text) => text.replaceAll('**', '');
}

/// A paragraph with `**bold**` spans resolved into styled TextSpans.
class _RichTextLine extends StatelessWidget {
  final String text;
  const _RichTextLine({required this.text});

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: SawaLoveTheme.onSurface,
          height: 1.5,
        );
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.+?)\*\*');
    var cursor = 0;
    for (final match in regex.allMatches(text)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(fontWeight: FontWeight.w700),
      ));
      cursor = match.end;
    }
    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor)));
    }
    return Text.rich(
      TextSpan(style: baseStyle, children: spans),
    );
  }
}
