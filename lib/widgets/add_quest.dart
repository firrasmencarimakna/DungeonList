import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.quest?.title ?? '');
    _descController = TextEditingController(
      text: widget.quest?.description ?? '',
    );
    _difficulty = widget.quest?.difficulty ?? QuestDifficulty.easy;

    if (widget.quest?.dueDate != null) {
      _selectedDate = widget.quest!.dueDate;
      _selectedTime = TimeOfDay.fromDateTime(widget.quest!.dueDate!);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
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

          // Deadline Section
          Text(
            'Tenggat Waktu',
            style: withBorder(
              const TextStyle(fontWeight: FontWeight.bold),
              outlineWidth: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: Text(
                    _selectedDate == null
                        ? 'Tanggal'
                        : DateFormat('d MMM yyyy').format(_selectedDate!),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green[800],
                    side: BorderSide(color: Colors.green[800]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickTime,
                  icon: const Icon(Icons.access_time, size: 18),
                  label: Text(
                    _selectedTime == null
                        ? 'Jam'
                        : _selectedTime!.format(context),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green[800],
                    side: BorderSide(color: Colors.green[800]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
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
                DateTime? due;
                if (_selectedDate != null) {
                  due = DateTime(
                    _selectedDate!.year,
                    _selectedDate!.month,
                    _selectedDate!.day,
                    _selectedTime?.hour ?? 23,
                    _selectedTime?.minute ?? 59,
                  );
                }

                if (isEditing) {
                  context.read<QuestProvider>().editQuest(
                    widget.quest!.copyWith(
                      title: _titleController.text,
                      description: _descController.text,
                      difficulty: _difficulty,
                      dueDate: due,
                    ),
                  );
                } else {
                  context.read<QuestProvider>().addQuest(
                    Quest(
                      title: _titleController.text,
                      description: _descController.text,
                      difficulty: _difficulty,
                      dueDate: due,
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
