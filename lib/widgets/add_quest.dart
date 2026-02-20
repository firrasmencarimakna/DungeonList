import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quest.dart';
import '../providers/provider.dart';
import '../utils/style.dart';
import '../utils/pixel_ui.dart';

class AddQuestSheet extends StatefulWidget {
  final Quest? quest; // If provided, we are in Edit Mode

  const AddQuestSheet({super.key, this.quest});

  @override
  State<AddQuestSheet> createState() => _AddQuestSheetState();
}

class _AddQuestSheetState extends State<AddQuestSheet> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late QuestDifficulty _difficulty;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.quest?.title ?? '');
    _descController = TextEditingController(
      text: widget.quest?.description ?? '',
    );
    _difficulty = widget.quest?.difficulty ?? QuestDifficulty.easy;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.quest != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isEditing ? 'Ubah Misi' : 'Tambah Misi',
            style: withBorder(
              Theme.of(context).textTheme.headlineMedium ?? const TextStyle(),
              outlineWidth: 1.0,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Judul',
              labelStyle: TextStyle(color: Colors.green[800]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.green[700]!, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descController,
            decoration: InputDecoration(
              labelText: 'Deskripsi',
              labelStyle: TextStyle(color: Colors.green[600]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.green[500]!, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Prioritas',
            style: withBorder(
              const TextStyle(fontWeight: FontWeight.bold),
              outlineWidth: 0.5,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: QuestDifficulty.values.map((d) {
              return ChoiceChip(
                selectedColor: Colors.green[200],
                label: Text(
                  d.label,
                  style: withBorder(
                    const TextStyle(fontSize: 12),
                    outlineWidth: 0.3,
                  ),
                ),
                selected: _difficulty == d,
                onSelected: (selected) {
                  if (selected) setState(() => _difficulty = d);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          PixelButton(
            onPressed: () {
              if (_titleController.text.isNotEmpty) {
                if (isEditing) {
                  context.read<QuestProvider>().editQuest(
                    widget.quest!.copyWith(
                      title: _titleController.text,
                      description: _descController.text,
                      difficulty: _difficulty,
                    ),
                  );
                } else {
                  context.read<QuestProvider>().addQuest(
                    Quest(
                      title: _titleController.text,
                      description: _descController.text,
                      difficulty: _difficulty,
                    ),
                  );
                }
                Navigator.pop(context);
              }
            },
            label: Center(
              child: Text(
                isEditing ? 'SIMPAN' : 'TAMBAH',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
