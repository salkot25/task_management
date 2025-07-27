import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/note.dart';

/// NotesProvider terhubung ke Firestore (users/{uid}/notes)
class NotesProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Note> _notes = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String? _selectedCategory;
  StreamSubscription? _notesSubscription;

  // Getters
  List<Note> get notes => _filteredNotes();
  List<Note> get allNotes => _notes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;

  // Categories
  List<String> get categories {
    final categories = <String>{};
    for (final note in _notes) {
      if (note.category != null && note.category!.isNotEmpty) {
        categories.add(note.category!);
      }
    }
    return categories.toList()..sort();
  }

  // Statistics
  int get totalNotes => _notes.length;
  int get pinnedNotes => _notes.where((note) => note.isPinned).length;
  int get categorizedNotes =>
      _notes.where((note) => note.category != null).length;

  /// Initialize notes provider and start listening to Firestore
  Future<void> init() async {
    await listenToNotes();
  }

  /// Listen to notes collection in Firestore (real-time)
  Future<void> listenToNotes() async {
    _setLoading(true);
    _clearError();
    _notesSubscription?.cancel();
    final user = _auth.currentUser;
    if (user == null) {
      _setError('User belum login');
      _setLoading(false);
      return;
    }
    try {
      _notesSubscription = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notes')
          .orderBy('updatedAt', descending: true)
          .snapshots()
          .listen(
            (snapshot) {
              _notes = snapshot.docs.map((doc) {
                final data = doc.data();
                return Note.fromJson(data);
              }).toList();
              _setLoading(false);
              notifyListeners();
            },
            onError: (e) {
              _setError('Gagal memuat catatan: $e');
              _setLoading(false);
            },
          );
    } catch (e) {
      _setError('Gagal memuat catatan: $e');
      _setLoading(false);
    }
  }

  /// Add a new note to Firestore
  Future<void> addNote(Note note) async {
    _clearError();
    final user = _auth.currentUser;
    if (user == null) {
      _setError('User belum login');
      throw Exception('User belum login');
    }
    try {
      final docRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notes')
          .doc(note.id);
      await docRef.set(note.toJson());
    } catch (e) {
      _setError('Gagal menambah catatan: $e');
      rethrow;
    }
  }

  /// Update an existing note in Firestore
  Future<void> updateNote(String id, Note updatedNote) async {
    _clearError();
    final user = _auth.currentUser;
    if (user == null) {
      _setError('User belum login');
      throw Exception('User belum login');
    }
    try {
      final docRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notes')
          .doc(id);
      await docRef.update(updatedNote.toJson());
    } catch (e) {
      _setError('Gagal memperbarui catatan: $e');
      rethrow;
    }
  }

  /// Delete a note from Firestore
  Future<void> deleteNote(String id) async {
    _clearError();
    final user = _auth.currentUser;
    if (user == null) {
      _setError('User belum login');
      throw Exception('User belum login');
    }
    try {
      final docRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notes')
          .doc(id);
      await docRef.delete();
    } catch (e) {
      _setError('Gagal menghapus catatan: $e');
      rethrow;
    }
  }

  /// Toggle pin status of a note in Firestore
  Future<void> togglePin(String id) async {
    _clearError();
    final user = _auth.currentUser;
    if (user == null) {
      _setError('User belum login');
      throw Exception('User belum login');
    }
    try {
      final note = getNoteById(id);
      if (note == null) throw Exception('Note tidak ditemukan');
      final docRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notes')
          .doc(id);
      await docRef.update({
        'isPinned': !note.isPinned,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      _setError('Gagal mengubah status pin: $e');
      rethrow;
    }
  }

  /// Set search query (local filter)
  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }

  /// Set selected category filter (local filter)
  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Clear all filters (local)
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    notifyListeners();
  }

  /// Get filtered notes based on search and category (local filter)
  List<Note> _filteredNotes() {
    var filteredNotes = List<Note>.from(_notes);
    if (_searchQuery.isNotEmpty) {
      filteredNotes = filteredNotes.where((note) {
        return note.title.toLowerCase().contains(_searchQuery) ||
            note.content.toLowerCase().contains(_searchQuery) ||
            note.tags.any((tag) => tag.toLowerCase().contains(_searchQuery));
      }).toList();
    }
    if (_selectedCategory != null) {
      filteredNotes = filteredNotes.where((note) {
        return note.category == _selectedCategory;
      }).toList();
    }
    return filteredNotes;
  }

  // Tidak perlu _sortNotes, sudah diorderBy Firestore

  /// Get note by ID (local cache)
  Note? getNoteById(String id) {
    try {
      return _notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get notes by category (local cache)
  List<Note> getNotesByCategory(String category) {
    return _notes.where((note) => note.category == category).toList();
  }

  /// Get pinned notes (local cache)
  List<Note> getPinnedNotes() {
    return _notes.where((note) => note.isPinned).toList();
  }

  /// Get recent notes (last 7 days, local cache)
  List<Note> getRecentNotes() {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _notes.where((note) => note.updatedAt.isAfter(weekAgo)).toList();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  /// Clear all notes in Firestore (for testing or reset)
  Future<void> clearAllNotes() async {
    final user = _auth.currentUser;
    if (user == null) {
      _setError('User belum login');
      throw Exception('User belum login');
    }
    try {
      final batch = _firestore.batch();
      final notesRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notes');
      final snapshot = await notesRef.get();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      _setError('Gagal menghapus semua catatan: $e');
      rethrow;
    }
  }

  /// Export notes to JSON string (local cache)
  String exportNotes() {
    final notesData = _notes.map((note) => note.toJson()).toList();
    return notesData.toString();
  }

  /// Import notes from JSON string (langsung ke Firestore)
  Future<void> importNotes(List<Note> notes) async {
    final user = _auth.currentUser;
    if (user == null) {
      _setError('User belum login');
      throw Exception('User belum login');
    }
    try {
      final batch = _firestore.batch();
      final notesRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notes');
      for (final note in notes) {
        final docRef = notesRef.doc(note.id);
        batch.set(docRef, note.toJson());
      }
      await batch.commit();
    } catch (e) {
      _setError('Gagal mengimpor catatan: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _notesSubscription?.cancel();
    super.dispose();
  }
}
