import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/note.dart';
import 'package:uuid/uuid.dart';

class NotesProvider with ChangeNotifier {
  List<Note> _notes = [];
  final Uuid _uuid = const Uuid();

  List<Note> get notes => _notes;

  NotesProvider() {
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? notesString = prefs.getString('notes');

    if (notesString != null && notesString.isNotEmpty) {
      List<dynamic> notesJson = json.decode(notesString);
      _notes = notesJson.map((noteJson) => Note.fromJson(noteJson)).toList();
    } else {
      await _addDefaultNote();
    }
    notifyListeners();
  }

  Future<void> _addDefaultNote() async {
    final now = DateTime.now();
    final defaultNote = Note(
      id: _uuid.v4(),
      title: '👋 Welcome to Capture!',
      content:
          'Hey, Let\'s start organizing thoughts and ideas here together. \n\n'
          'Tap on this note to edit it. \n\n'
          'Use the + button to add new notes. \n\n'
          'Here are some extra features to help you, \n'
          '   - By clicking "⋮" you will get option menu \n'
          '   - To change view click on grid symbol \n'
          '   - Long-press to reorder notes in list view \n'
          '   - You can also see archive notes by pressing the archive symbol \n'
          '   - Visit settings to change the app\'s theme and also export or import your notes. \n',
      color: Colors.transparent.value.toString(),
      isArchived: false,
      createdAt: now,
      updatedAt: now,
    );
    _notes.add(defaultNote);
    await _saveNotes();
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String notesString = json.encode(
      _notes.map((note) => note.toJson()).toList(),
    );
    await prefs.setString('notes', notesString);
  }

  void addNote(Note note) {
    _notes.add(note);
    _saveNotes();
    notifyListeners();
  }

  void updateNote(Note updatedNote) {
    final index = _notes.indexWhere((note) => note.id == updatedNote.id);
    if (index != -1) {
      _notes[index] = updatedNote;
      _saveNotes();
      notifyListeners();
    }
  }

  void deleteNote(String id) {
    _notes.removeWhere((note) => note.id == id);
    _saveNotes();
    notifyListeners();
  }

  void archiveNote(String id) {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      _notes[index].isArchived = true;
      _saveNotes();
      notifyListeners();
    }
  }

  void unarchiveNote(String id) {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      _notes[index].isArchived = false;
      _saveNotes();
      notifyListeners();
    }
  }

  void reorderNotes(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final Note item = _notes.removeAt(oldIndex);
    _notes.insert(newIndex, item);
    _saveNotes();
    notifyListeners();
  }

  void updateNoteColor(String noteId, String newColor) {
    final noteIndex = _notes.indexWhere((note) => note.id == noteId);
    if (noteIndex >= 0) {
      _notes[noteIndex].color = newColor;
      notifyListeners();
    }
    _saveNotes();
  }
}
