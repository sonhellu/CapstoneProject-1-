// lib/screens/community/board_write_screen.dart
import 'package:flutter/material.dart';
import '../../services/community_service.dart';
import '../../services/api_service.dart';
import '../../l10n/app_localizations.dart';
import 'board_screen.dart'; // BoardCategory 쓰려고 import

// Map BoardCategory to board_id
const Map<BoardCategory, int> _categoryToBoardId = {
  BoardCategory.notice: 1,
  BoardCategory.free: 2,
  BoardCategory.info: 3,
  BoardCategory.promo: 4,
};

class BoardWriteScreen extends StatefulWidget {
  final BoardCategory? initialCategory; // Optional: default category if provided

  const BoardWriteScreen({super.key, this.initialCategory});

  @override
  State<BoardWriteScreen> createState() => _BoardWriteScreenState();
}

class _BoardWriteScreenState extends State<BoardWriteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isAnonymous = false;
  bool _isLoading = false;
  BoardCategory? _selectedCategory; // Selected board category

  @override
  void initState() {
    super.initState();
    // Set initial category if provided, otherwise default to notice
    _selectedCategory = widget.initialCategory ?? BoardCategory.notice;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// Validate và submit post
  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Validate board category is selected
      if (_selectedCategory == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).pleaseSelectBoard),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      final boardId = _categoryToBoardId[_selectedCategory!] ?? 1;
      
      await CommunityService.createPost(
        boardId: boardId,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        isAnonymous: _isAnonymous,
      );

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.postPublishedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true để reload posts
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.errorOccurred}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).writePost),
        backgroundColor: Colors.red[600],
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Board selection dropdown
              DropdownButtonFormField<BoardCategory>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).selectBoard,
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                  prefixIcon: const Icon(Icons.dashboard),
                ),
                items: BoardCategory.values.map((category) {
                  String label;
                  switch (category) {
                    case BoardCategory.notice:
                      label = AppLocalizations.of(context).noticeBoard;
                      break;
                    case BoardCategory.free:
                      label = AppLocalizations.of(context).freeBoard;
                      break;
                    case BoardCategory.info:
                      label = AppLocalizations.of(context).infoBoard;
                      break;
                    case BoardCategory.promo:
                      label = AppLocalizations.of(context).promoBoard;
                      break;
                  }
                  return DropdownMenuItem<BoardCategory>(
                    value: category,
                    child: Text(label),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return AppLocalizations.of(context).pleaseSelectBoard;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              
              // Title field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).title,
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppLocalizations.of(context).titleRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              
              // Content field
              Expanded(
                child: TextFormField(
                  controller: _contentController,
                  maxLines: null,
                  expands: true,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).content,
                    alignLabelWithHint: true,
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context).contentRequired;
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 12),
              
              // Anonymous checkbox
              CheckboxListTile(
                title: Text(AppLocalizations.of(context).writeAnonymously),
                value: _isAnonymous,
                onChanged: (value) {
                  setState(() {
                    _isAnonymous = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 12),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () {
                        Navigator.pop(context);
                      },
                      child: Text(AppLocalizations.of(context).cancel),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: _isLoading ? null : _submitPost,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red[600],
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(AppLocalizations.of(context).post),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
