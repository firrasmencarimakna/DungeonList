import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/note.dart';
import '../providers/provider.dart';

class MarkdownEditingController extends TextEditingController {
  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final List<InlineSpan> children = [];

    // Updated pattern to handle empty text or nulls safely
    if (text.isEmpty) {
      return TextSpan(style: style, text: text);
    }

    final pattern = RegExp(r'(\*\*.*?\*\*)|(_.*?_)');
    final tagStyle = style?.copyWith(color: Colors.transparent, fontSize: 0.1);

    text.splitMapJoin(
      pattern,
      onMatch: (match) {
        final matchText = match[0]!;
        if (matchText.startsWith('**') && matchText.endsWith('**')) {
          final content = matchText.substring(2, matchText.length - 2);
          children.add(TextSpan(text: '**', style: tagStyle));
          children.add(
            TextSpan(
              text: content,
              style: style?.copyWith(fontWeight: FontWeight.bold),
            ),
          );
          children.add(TextSpan(text: '**', style: tagStyle));
        } else if (matchText.startsWith('_') && matchText.endsWith('_')) {
          final content = matchText.substring(1, matchText.length - 1);
          children.add(TextSpan(text: '_', style: tagStyle));
          children.add(
            TextSpan(
              text: content,
              style: style?.copyWith(fontStyle: FontStyle.italic),
            ),
          );
          children.add(TextSpan(text: '_', style: tagStyle));
        }
        return '';
      },
      onNonMatch: (nonMatch) {
        children.add(TextSpan(text: nonMatch, style: style));
        return '';
      },
    );

    return TextSpan(style: style, children: children);
  }
}

class NoteEditorScreen extends StatefulWidget {
  final Note? note;
  const NoteEditorScreen({super.key, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  late final UndoHistoryController _titleUndoController;
  late final UndoHistoryController _bodyUndoController;
  late Note _currentNote;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    _currentNote = widget.note ?? Note(userId: userId);

    _titleController = TextEditingController(text: _currentNote.title);
    _bodyController = MarkdownEditingController();
    _bodyController.text = _currentNote.content;
    _titleUndoController = UndoHistoryController();
    _bodyUndoController = UndoHistoryController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _titleUndoController.dispose();
    _bodyUndoController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (_titleController.text.isEmpty && _bodyController.text.isEmpty) return;

    setState(() => _isSaving = true);

    final updatedNote = _currentNote.copyWith(
      title: _titleController.text,
      content: _bodyController.text,
    );

    await context.read<QuestProvider>().upsertNote(updatedNote);

    if (mounted) {
      setState(() {
        _currentNote = updatedNote;
        _isSaving = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null && mounted) {
      final name = image.name;
      final selection = _bodyController.selection;
      final text = _bodyController.text;

      final imageTag = '\n![Gambar: $name](Simulasi)\n';
      final newText = text.replaceRange(
        selection.start,
        selection.end,
        imageTag,
      );

      _bodyController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: selection.start + imageTag.length,
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gambar $name ditambahkan (Simulasi)')),
      );
    }
  }

  void _formatText(String prefix, [String? suffix]) {
    final selection = _bodyController.selection;
    final text = _bodyController.text;
    if (selection.start == -1) return;

    final selectedText = selection.textInside(text);
    final endSuffix = suffix ?? prefix;

    final newText = text.replaceRange(
      selection.start,
      selection.end,
      '$prefix$selectedText$endSuffix',
    );

    _bodyController.value = TextEditingValue(
      text: newText,
      selection: TextSelection(
        baseOffset: selection.start + prefix.length,
        extentOffset: selection.start + prefix.length + selectedText.length,
      ),
    );
  }

  void _toggleList() {
    final selection = _bodyController.selection;
    final text = _bodyController.text;
    if (selection.start == -1) return;

    int lineStart = selection.start;
    while (lineStart > 0 && text[lineStart - 1] != '\n') {
      lineStart--;
    }

    const bullet = '- ';
    final isAlreadyBullet =
        text.length >= lineStart + bullet.length &&
        text.substring(lineStart, lineStart + bullet.length) == bullet;

    String newText;
    int newOffset;

    if (isAlreadyBullet) {
      newText = text.replaceRange(lineStart, lineStart + bullet.length, '');
      newOffset = selection.start - bullet.length;
    } else {
      newText = text.replaceRange(lineStart, lineStart, bullet);
      newOffset = selection.start + bullet.length;
    }

    _bodyController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: newOffset.clamp(0, newText.length),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () async {
            final navigator = Navigator.of(context);
            await _saveNote();
            if (mounted) {
              navigator.pop();
            }
          },
        ),
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          ListenableBuilder(
            listenable: _bodyUndoController,
            builder: (context, child) {
              return IconButton(
                icon: const Icon(Icons.undo, color: Colors.black87),
                onPressed: _bodyUndoController.value.canUndo
                    ? () => _bodyUndoController.undo()
                    : null,
              );
            },
          ),
          ListenableBuilder(
            listenable: _bodyUndoController,
            builder: (context, child) {
              return IconButton(
                icon: const Icon(Icons.redo, color: Colors.black87),
                onPressed: _bodyUndoController.value.canRedo
                    ? () => _bodyUndoController.redo()
                    : null,
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  undoController: _titleUndoController,
                  style: GoogleFonts.lora(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Judul',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.black26),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: TextField(
                    controller: _bodyController,
                    undoController: _bodyUndoController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: GoogleFonts.lora(
                      fontSize: 18,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Catat sesuatu...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.black26),
                    ),
                  ),
                ),
                const SizedBox(height: 100), // Space for floating toolbar
              ],
            ),
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(color: Colors.black12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.text_fields, color: Colors.black54),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Mode Teks Normal')),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.format_bold, color: Colors.black54),
                    onPressed: () => _formatText('**'),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.format_italic,
                      color: Colors.black54,
                    ),
                    onPressed: () => _formatText('_'),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.format_list_bulleted,
                      color: Colors.black54,
                    ),
                    onPressed: _toggleList,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.image_outlined,
                      color: Colors.black54,
                    ),
                    onPressed: _pickImage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
