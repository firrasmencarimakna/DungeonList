import 'dart:io';
import 'package:flutter/material.dart';
import '../models/quest.dart';
import '../models/note.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class QuestProvider with ChangeNotifier {
  List<Quest> _quests = [];
  List<Note> _notes = [];
  String _username = 'Petualang';
  String? _avatarUrl;
  String _searchQuery = '';
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

  List<Note> get notes => List.unmodifiable(_notes);
  String get username => _username;
  String? get avatarUrl => _avatarUrl;
  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> fetchProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('fetchProfile: User is null');
        return;
      }

      debugPrint('fetchProfile: Fetching for userId: ${user.id}');

      // Coba ambil profil
      final data = await _supabase
          .from('profiles')
          .select('name, avatar')
          .eq('id', user.id)
          .maybeSingle();

      debugPrint('fetchProfile: Received data: $data');

      if (data == null) {
        debugPrint('fetchProfile: Data is null, attempting upsert');
        // User baru (misal dari Google Sign-In), buat profil otomatis
        final displayName =
            user.userMetadata?['full_name'] ??
            user.userMetadata?['name'] ??
            user.email?.split('@').first ??
            'Petualang';
        final googleAvatar =
            user.userMetadata?['avatar_url'] ?? user.userMetadata?['picture'];

        debugPrint('fetchProfile: Upserting with name: $displayName');

        await _supabase.from('profiles').upsert({
          'id': user.id,
          'name': displayName,
          'avatar': googleAvatar,
        });

        _username = displayName;
        _avatarUrl = googleAvatar;
      } else {
        _username = data['name'] ?? 'Petualang';
        final rawUrl = data['avatar'] as String?;
        _avatarUrl = rawUrl != null
            ? '$rawUrl?t=${DateTime.now().millisecondsSinceEpoch}'
            : null;
        debugPrint('fetchProfile: Set username to $_username');
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      _quests = [];
      _notes = [];
      _username = 'Petualang';
      _avatarUrl = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error signing out: $e');
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
          .update({'name': newName})
          .eq('id', userId);
    } catch (e) {
      debugPrint('Error updating username: $e');
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

      // Update database dengan kolom yang benar
      await _supabase
          .from('profiles')
          .update({'avatar': publicUrl})
          .eq('id', userId);

      // Update local state dengan cache-buster agar gambar langsung refresh
      _avatarUrl = '$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}';
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating profile picture: $e');
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
    } catch (e) {
      debugPrint('Error adding quest: $e');
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
    } catch (e) {
      debugPrint('Error deleting quest: $e');
    }
  }

  // --- Note Operations ---

  Future<void> fetchNotes() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final data = await _supabase
          .from('notes')
          .select()
          .order('updated_at', ascending: false);

      _notes = (data as List).map((e) => Note.fromMap(e)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching notes: $e');
    }
  }

  Future<void> upsertNote(Note note) async {
    try {
      final index = _notes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        _notes[index] = note;
      } else {
        _notes.insert(0, note);
      }
      notifyListeners();

      await _supabase.from('notes').upsert(note.toMap());
    } catch (e) {
      debugPrint('Error upserting note: $e');
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      _notes.removeWhere((n) => n.id == id);
      notifyListeners();

      await _supabase.from('notes').delete().eq('id', id);
    } catch (e) {
      debugPrint('Error deleting note: $e');
    }
  }
}
