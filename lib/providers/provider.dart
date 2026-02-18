import 'dart:io';
import 'package:flutter/material.dart';
import '../models/quest.dart';
import '../utils/notifications.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class QuestProvider with ChangeNotifier {
  List<Quest> _quests = [];
  String _username = 'Petualang';
  String? _avatarUrl;
  String _searchQuery = '';
  final NotificationService _notificationService = NotificationService();
  final _supabase = Supabase.instance.client;

  List<Quest> get quests {
    if (_searchQuery.isEmpty) {
      return List.unmodifiable(_quests);
    }
    return List.unmodifiable(
      _quests.where(
        (quest) =>
            quest.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            quest.description.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ),
      ),
    );
  }

  String get username => _username;
  String? get avatarUrl => _avatarUrl;
  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> fetchProfile() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final data = await _supabase
          .from('profiles')
          .select('full_name, avatar_url')
          .eq('id', userId)
          .single();

      _username = data['full_name'] ?? 'Petualang';
      _avatarUrl = data['avatar_url'];
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    }
  }

  Future<void> updateUsername(String newName) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Optimistic update
      _username = newName;
      notifyListeners();

      await _supabase
          .from('profiles')
          .update({'full_name': newName})
          .eq('id', userId);
    } catch (e) {
      debugPrint('Error updating profile: $e');
    }
  }

  Future<void> updateProfilePicture(File imageFile) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Upload image to Supabase Storage
      final fileExt = imageFile.path.split('.').last;
      final filePath = '$userId/avatar.$fileExt';

      await _supabase.storage
          .from('avatars')
          .upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(upsert: true),
          );

      // Get public URL
      final publicUrl = _supabase.storage
          .from('avatars')
          .getPublicUrl(filePath);

      // Optimistic update
      _avatarUrl = publicUrl;
      notifyListeners();

      // Update database
      await _supabase
          .from('profiles')
          .update({'avatar_url': publicUrl})
          .eq('id', userId);
    } catch (e) {
      debugPrint('Error updating profile picture: $e');
      // Revert optimistic update on error
      await fetchProfile();
      rethrow;
    }
  }

  Future<void> fetchQuests() async {
    try {
      final data = await _supabase
          .from('quests')
          .select()
          .order('created_at', ascending: false);

      _quests = (data as List).map((e) => Quest.fromMap(e)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching quests: $e');
    }
  }

  Future<void> addQuest(Quest quest) async {
    try {
      // Optimistic update
      _quests.insert(0, quest);
      notifyListeners();

      await _supabase.from('quests').insert(quest.toMap());

      if (quest.dueDate != null) {
        _notificationService.scheduleNotification(
          quest.id.hashCode,
          'Misi Menanti!',
          'Waktunya menyelesaikan: ${quest.title}',
          quest.dueDate!,
        );
      }
    } catch (e) {
      debugPrint('Error adding quest: $e');
      // Rollback on error would be ideal here
    }
  }

  Future<void> editQuest(Quest updatedQuest) async {
    try {
      final index = _quests.indexWhere((q) => q.id == updatedQuest.id);
      if (index != -1) {
        // Optimistic update
        _quests[index] = updatedQuest;
        notifyListeners();

        await _supabase
            .from('quests')
            .update(updatedQuest.toMap())
            .eq('id', updatedQuest.id);

        _notificationService.cancelNotification(updatedQuest.id.hashCode);
        if (updatedQuest.dueDate != null && !updatedQuest.isCompleted) {
          _notificationService.scheduleNotification(
            updatedQuest.id.hashCode,
            'Misi Menanti!',
            'Waktunya menyelesaikan: ${updatedQuest.title}',
            updatedQuest.dueDate!,
          );
        }
      }
    } catch (e) {
      debugPrint('Error editing quest: $e');
    }
  }

  Future<void> toggleCompleteQuest(String id) async {
    try {
      final index = _quests.indexWhere((q) => q.id == id);
      if (index != -1) {
        final quest = _quests[index];
        final newStatus = !quest.isCompleted;

        // Optimistic update
        _quests[index] = quest.copyWith(isCompleted: newStatus);
        notifyListeners();

        await _supabase
            .from('quests')
            .update({'is_completed': newStatus})
            .eq('id', id);

        if (newStatus) {
          _notificationService.cancelNotification(quest.id.hashCode);
        } else {
          if (quest.dueDate != null) {
            _notificationService.scheduleNotification(
              quest.id.hashCode,
              'Misi Menanti!',
              'Waktunya menyelesaikan: ${quest.title}',
              quest.dueDate!,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error toggling quest: $e');
    }
  }

  Future<void> deleteQuest(String id) async {
    try {
      // Optimistic update
      _quests.removeWhere((q) => q.id == id);
      notifyListeners();

      await _supabase.from('quests').delete().eq('id', id);
      _notificationService.cancelNotification(id.hashCode);
    } catch (e) {
      debugPrint('Error deleting quest: $e');
    }
  }
}
