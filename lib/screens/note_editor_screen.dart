import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';
import 'package:uuid/uuid.dart';
import '../widgets/color_picker_dialog.dart';
import 'package:share_plus/share_plus.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;
  final String? initialContent;

  const NoteEditorScreen({super.key, this.note, this.initialContent});

  @override
  NoteEditorScreenState createState() => NoteEditorScreenState();
}

class NoteEditorScreenState extends State<NoteEditorScreen> {
  static const platform = MethodChannel('com.yourcompany.notes/sharing');
  final FocusNode _focusNode = FocusNode();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  Color _selectedColor = Colors.transparent;

  bool _noteHandledByAction = false;
  bool _shouldBeArchivedOnSave = false;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _selectedColor = Color(int.parse(widget.note!.color));
      _shouldBeArchivedOnSave = widget.note!.isArchived;
    } else if (widget.initialContent != null) {
      _contentController.text = widget.initialContent!;
      _focusNode.requestFocus();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });

    _listenForSharedText();
  }

  @override
  Widget build(BuildContext context) {
    final notesProvider = Provider.of<NotesProvider>(context);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && !_noteHandledByAction) {
          _saveNote(notesProvider);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.note == null ? 'New Note' : 'Edit Note'),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              offset: const Offset(0, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 8.0,
              color: Theme.of(context).cardColor,
              onSelected: (value) {
                _handleMenuSelection(value, notesProvider);
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<String>(
                    value: 'color',
                    child: Row(
                      children: const [
                        Icon(Icons.color_lens, color: Colors.purple),
                        SizedBox(width: 8),
                        Text('Pick a Color'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),

                  PopupMenuItem<String>(
                    value:
                        widget.note?.isArchived == true
                            ? 'unarchive'
                            : 'archive',
                    child: Row(
                      children: [
                        Icon(
                          widget.note?.isArchived == true
                              ? Icons.unarchive
                              : Icons.archive,
                          color: Colors.blueAccent,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.note?.isArchived == true
                              ? 'Unarchive'
                              : 'Archive',
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),

                  PopupMenuItem<String>(
                    value: 'share',
                    child: Row(
                      children: const [
                        Icon(Icons.share, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Share'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),

                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: const [
                        Icon(Icons.delete, color: Colors.redAccent),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _titleController,
                        style: const TextStyle(fontSize: 24),
                        decoration: const InputDecoration(
                          hintText: 'Title',
                          hintStyle: TextStyle(fontSize: 24),
                          border: InputBorder.none,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Expanded(
                        child: TextField(
                          controller: _contentController,
                          focusNode: _focusNode,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          decoration: const InputDecoration(
                            hintText: 'What\'s on your mind?',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _saveNote(NotesProvider notesProvider) {
    final String title = _titleController.text.trim();
    final String content = _contentController.text.trim();

    if (widget.note == null) {
      if (title.isEmpty && content.isEmpty) return;
      final newNote = Note(
        id: const Uuid().v4(),
        title: title,
        content: content,
        color: _selectedColor.toARGB32().toString(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isArchived: _shouldBeArchivedOnSave,
      );
      notesProvider.addNote(newNote);
    } else {
      final updatedNote = Note(
        id: widget.note!.id,
        title: title,
        content: content,
        color: _selectedColor.toARGB32().toString(),
        createdAt: widget.note!.createdAt,
        updatedAt: DateTime.now(),
        isArchived: _shouldBeArchivedOnSave,
      );
      notesProvider.updateNote(updatedNote);
    }
  }

  void _handleMenuSelection(String value, NotesProvider notesProvider) {
    switch (value) {
      case 'color':
        if (widget.note != null) {
          _showColorOptions(context, widget.note!.id);
        } else {
          _showColorOptions(context, '');
        }
        break;
      case 'share':
        _shareNote(context);
        break;
      case 'archive':
        if (widget.note == null) {
          final String title = _titleController.text.trim();
          final String content = _contentController.text.trim();

          if (title.isEmpty && content.isEmpty) {
            _noteHandledByAction = true;
            Navigator.of(context).pop();
            return;
          }

          _shouldBeArchivedOnSave = true;
        } else {
          notesProvider.archiveNote(widget.note!.id);
          _shouldBeArchivedOnSave = true;
        }
        Navigator.of(context).pop();
        break;
      case 'unarchive':
        if (widget.note != null) {
          notesProvider.unarchiveNote(widget.note!.id);
          _shouldBeArchivedOnSave = false;
          Navigator.of(context).pop();
        }
        break;
      case 'delete':
        if (widget.note == null) {
          _titleController.clear();
          _contentController.clear();
          _noteHandledByAction = true;
          Navigator.of(context).pop();
        } else {
          _showDeleteConfirmationDialog(context);
        }
        break;
    }
  }

  void _shareNote(BuildContext context) {
    final String noteContent =
        '${_titleController.text}\n\n${_contentController.text}';
    SharePlus.instance.share(
      ShareParams(text: noteContent, subject: 'Check out this note!'),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    final String noteTittle = _titleController.text.trim();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Note'),
          content: RichText(
            text: TextSpan(
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 16,
              ),
              children: [
                const TextSpan(text: 'Are you sure you want to delete '),
                TextSpan(
                  text: noteTittle.isNotEmpty ? '"$noteTittle"' : 'No title',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                const TextSpan(text: ' note?'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<NotesProvider>(
                  context,
                  listen: false,
                ).deleteNote(widget.note!.id);
                _noteHandledByAction = true;
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showColorOptions(BuildContext context, String noteId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ColorPickerDialog(
          selectedColor: _selectedColor,
          onColorSelected: (Color newColor) {
            setState(() {
              _selectedColor = newColor;
            });
            String colorHex = newColor
                .toARGB32()
                .toRadixString(16)
                .padLeft(8, '0');

            colorHex = '0x$colorHex';

            if (noteId.isNotEmpty) {
              Provider.of<NotesProvider>(
                context,
                listen: false,
              ).updateNoteColor(noteId, colorHex);
            }
          },
        );
      },
    );
  }

  void _listenForSharedText() async {
    try {
      final String? sharedText = await platform.invokeMethod('getSharedText');
      if (sharedText != null && sharedText.isNotEmpty && mounted) {
        setState(() {
          _contentController.text = sharedText;
        });
        await platform.invokeMethod('clearSharedText');
      }
    } on PlatformException catch (e) {
      debugPrint("Error getting shared text: ${e.message}");
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
