import 'package:uuid/uuid.dart';

enum QuestDifficulty {
  easy('Mudah'),
  medium('Menengah'),
  hard('Sulit');

  final String label;
  const QuestDifficulty(this.label);
}

class Quest {
  final String id;
  final String title;
  final String description;
  final QuestDifficulty difficulty;
  final bool isCompleted;
  final DateTime? dueDate;

  Quest({
    String? id,
    required this.title,
    this.description = '',
    required this.difficulty,
    this.isCompleted = false,
    this.dueDate,
  }) : id = id ?? const Uuid().v4();

  Quest copyWith({
    String? title,
    String? description,
    QuestDifficulty? difficulty,
    bool? isCompleted,
    DateTime? dueDate,
  }) {
    return Quest(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id':
          id, // Supabase allows client-generated IDs or we can let DB generate if we omit this on insert, but keeping consistency is good.
      // However, usually we might want to omit ID on insert if DB generates it, but here we generate UUID locally.
      'title': title,
      'description': description,
      'difficulty': difficulty.name, // 'easy', 'medium', 'hard'
      'is_completed': isCompleted,
      'due_date': dueDate?.toIso8601String(),
    };
  }

  factory Quest.fromMap(Map<String, dynamic> map) {
    return Quest(
      id: map['id'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      difficulty: QuestDifficulty.values.firstWhere(
        (e) => e.name == map['difficulty'],
        orElse: () => QuestDifficulty.easy,
      ),
      isCompleted: map['is_completed'] ?? false,
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date']) : null,
    );
  }
}
