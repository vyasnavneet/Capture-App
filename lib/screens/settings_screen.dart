import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../providers/notes_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/note.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.loadTheme});
  final void Function() loadTheme;

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  final TextEditingController _importTextController = TextEditingController();

  static const String _noteDelimiter = '\n---\n';

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  @override
  void dispose() {
    _importTextController.dispose();
    super.dispose();
  }

  void _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  void _toggleTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = !_isDarkMode;
      prefs.setBool('isDarkMode', _isDarkMode);
      widget.loadTheme();
    });
  }

  void _exportNotes() async {
    final notesProvider = Provider.of<NotesProvider>(context, listen: false);
    final allNotes = notesProvider.notes;

    if (allNotes.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No notes to export!')));
      return;
    }

    final StringBuffer exportedText = StringBuffer();
    for (int i = 0; i < allNotes.length; i++) {
      final note = allNotes[i];
      if (note.title.trim().isNotEmpty) {
        exportedText.writeln('Title: ${note.title}');
      }
      if (note.content.trim().isNotEmpty) {
        exportedText.writeln('Content: ${note.content}');
      }

      if (note.title.trim().isNotEmpty || note.content.trim().isNotEmpty) {
        if (i < allNotes.length - 1) {
          exportedText.writeln(_noteDelimiter);
        }
      }
    }

    try {
      await Share.share(exportedText.toString(), subject: 'My Exported Notes');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to share notes: $e')));
    }
  }

  void _importNotes() {
    _importTextController.clear();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Paste Notes to Import'),
          content: SingleChildScrollView(
            child: TextField(
              controller: _importTextController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintStyle: TextStyle(
                  color:
                      Theme.of(context).brightness != Brightness.dark
                          ? Colors.black.withOpacity(0.4)
                          : Colors.white.withOpacity(0.4),
                ),

                hintText: '''Paste your exported notes here.
Format:
Title: Your Note Title
Content: The body of your note. This can be multiple lines.
---
Title: Another Note
Content: This is the content of the second note.
(Use '---' on a separate line between notes)''',
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final String pastedText = _importTextController.text;
                if (pastedText.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Please paste some text to import.'),
                    ),
                  );
                  return;
                }

                final notesProvider = Provider.of<NotesProvider>(
                  dialogContext,
                  listen: false,
                );
                final List<Note> importedNotes = _parseImportedText(pastedText);

                if (importedNotes.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('No valid notes found in the pasted text.'),
                    ),
                  );
                  Navigator.of(dialogContext).pop();
                  return;
                }

                int notesAddedCount = 0;
                for (final note in importedNotes) {
                  notesProvider.addNote(note);
                  notesAddedCount++;
                }

                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Successfully imported $notesAddedCount note(s).',
                    ),
                  ),
                );
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Import'),
            ),
          ],
        );
      },
    );
  }

  List<Note> _parseImportedText(String content) {
    final List<Note> notes = [];
    final List<String> noteBlocks = content.split(_noteDelimiter);

    for (String block in noteBlocks) {
      block = block.trim();
      if (block.isEmpty) continue;

      String title = '';
      String noteContent = '';

      final List<String> lines = block.split('\n');
      bool contentParsingActive = false;

      for (String line in lines) {
        if (line.startsWith('Title:')) {
          title = line.substring('Title:'.length).trim();
          contentParsingActive = false;
        } else if (line.startsWith('Content:')) {
          noteContent = line.substring('Content:'.length).trim();
          contentParsingActive = true;
        } else if (contentParsingActive) {
          noteContent += '\n' + line.trim();
        } else if (line.trim().isNotEmpty) {
          if (title.isNotEmpty && noteContent.isEmpty) {
            noteContent = line.trim();
            contentParsingActive = true;
          } else if (title.isEmpty && noteContent.isEmpty) {
            noteContent = line.trim();
            contentParsingActive = true;
          } else {
            noteContent += '\n' + line.trim();
          }
        }
      }

      if (title.isNotEmpty || noteContent.isNotEmpty) {
        notes.add(
          Note(
            id: UniqueKey().toString(),
            title: title,
            content: noteContent,
            color: '0x00000000',
            isArchived: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
      }
    }
    return notes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: _isDarkMode,
            onChanged: (value) {
              _toggleTheme();
            },
          ),
          ListTile(
            trailing: const Icon(Icons.move_to_inbox),
            title: const Text('Import Notes'),
            onTap: _importNotes,
          ),
          ListTile(
            trailing: const Icon(Icons.outbox),
            title: const Text('Export All Notes'),
            onTap: _exportNotes,
          ),
        ],
      ),
    );
  }
}
