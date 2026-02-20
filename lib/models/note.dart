import 'package:uuid/uuid.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    String? id,
    this.title = '',
    this.content = '',
    required this.userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Note copyWith({String? title, String? content, DateTime? updatedAt}) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      userId: userId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      userId: map['user_id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }
}
