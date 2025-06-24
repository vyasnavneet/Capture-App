import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notes_provider.dart';
import '../widgets/note_card.dart';
import 'note_editor_screen.dart';

class ArchivedNotesScreen extends StatelessWidget {
  const ArchivedNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notesProvider = Provider.of<NotesProvider>(context);
    final archivedNotes =
        notesProvider.notes.where((note) => note.isArchived).toList();

    return Scaffold(
      appBar: AppBar(title: Text('Archived Notes')),
      body: ListView.builder(
        itemCount: archivedNotes.length,
        itemBuilder: (context, index) {
          return NoteCard(
            note: archivedNotes[index],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => NoteEditorScreen(note: archivedNotes[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
