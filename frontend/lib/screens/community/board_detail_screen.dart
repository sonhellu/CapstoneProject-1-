// lib/screens/community/board_detail_screen.dart
import 'package:flutter/material.dart';
import '../../models/board_post.dart';
import '../../services/translation_service.dart';
import '../../l10n/app_localizations.dart';

class BoardDetailScreen extends StatefulWidget {
  final BoardPost post;
  const BoardDetailScreen({super.key, required this.post});

  @override
  State<BoardDetailScreen> createState() => _BoardDetailScreenState();
}

class _BoardDetailScreenState extends State<BoardDetailScreen> {
  String _translatedTitle = '';
  String _translatedContent = '';
  bool _isTranslating = false;
  bool _isTranslated = false;

  Future<void> _translatePost() async {
    if (_isTranslating) return;

    setState(() {
      _isTranslating = true;
    });

    try {
      // Dịch title và content song song
      final results = await Future.wait([
        TranslationService.translateText(text: widget.post.title),
        TranslationService.translateText(text: widget.post.content),
      ]);

      if (mounted) {
        setState(() {
          _translatedTitle = results[0];
          _translatedContent = results[1];
          _isTranslated = true;
          _isTranslating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTranslating = false;
        });
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.translationFailed}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showOriginal() {
    setState(() {
      _isTranslated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isTranslated ? _translatedTitle : widget.post.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: _isTranslating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(_isTranslated ? Icons.language : Icons.translate),
            onPressed: _isTranslating 
                ? null 
                : (_isTranslated ? _showOriginal : _translatePost),
            tooltip: _isTranslated ? l10n.showOriginal : l10n.translateText,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_isTranslated)
              Text(
                widget.post.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            if (_isTranslated)
              Text(
                _translatedTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            const SizedBox(height: 8),
            Text(
              '${widget.post.author} · ${widget.post.createdAt}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Divider(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _isTranslated ? _translatedContent : widget.post.content,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
