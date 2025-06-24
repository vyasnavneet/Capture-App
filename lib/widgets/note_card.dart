import 'package:flutter/material.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/color_picker_dialog.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({super.key, required this.note, required this.onTap});
  final Note note;
  final VoidCallback onTap;

  isDarkMode(BuildContext context) {
    if (Color(int.parse(note.color)) != Colors.transparent) {
      return false;
    }
    return Theme.of(context).brightness == Brightness.dark;
  }

  @override
  Widget build(BuildContext context) {
    print(isDarkMode(context));

    final Color contentTextColor =
        isDarkMode(context) ? Colors.white : Colors.black;

    final Color linkColor =
        isDarkMode(context) ? Colors.blue.shade200 : Colors.blue.shade800;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.0),
                border: Border.all(
                  color:
                      //Theme.of(context).brightness != Brightness.dark
                      Color(int.parse(note.color)) == Colors.transparent &&
                              Theme.of(context).brightness != Brightness.dark
                          ? Colors.black.withValues(alpha: 0.7)
                          : Colors.white.withValues(alpha: 0.4),
                  width: 0.5,
                ),
                color: Color(int.parse(note.color)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (note.title.trim().isNotEmpty)
                    Text(
                      note.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: contentTextColor,
                      ),
                    ),
                  if (note.title.trim().isNotEmpty) const SizedBox(height: 8.0),

                  Linkify(
                    onOpen: (link) async {
                      if (await canLaunchUrl(Uri.parse(link.url))) {
                        await launchUrl(Uri.parse(link.url));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Could not open ${link.url}')),
                        );
                      }
                    },
                    text: note.content,
                    maxLines: 14,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: contentTextColor),
                    linkStyle: TextStyle(
                      color: linkColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const SizedBox(height: 5.0),
                ],
              ),
            ),

            Positioned(
              top: -5,
              right: -12,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Material(
                  color: Colors.transparent,
                  child: PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.more_vert,
                      color: contentTextColor,
                      size: 20,
                    ),
                    offset: const Offset(0, 35),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),

                    elevation: 8.0,

                    color: Theme.of(context).cardColor,

                    onSelected: (value) => _handleMenuSelection(value, context),
                    itemBuilder:
                        (BuildContext context) => [
                          PopupMenuItem(
                            value: 'color',
                            child: ListTile(
                              leading: const Icon(
                                Icons.color_lens,
                                color: Colors.purple,
                              ),
                              title: const Text('Pick a Color'),
                            ),
                          ),

                          PopupMenuItem(
                            value: 'share',
                            child: ListTile(
                              leading: const Icon(
                                Icons.share,
                                color: Colors.green,
                              ),
                              title: const Text('Share'),
                            ),
                          ),

                          PopupMenuItem(
                            value: 'archive',
                            child: ListTile(
                              leading: Icon(
                                note.isArchived
                                    ? Icons.unarchive
                                    : Icons.archive,
                                color: Colors.blueAccent,
                              ),
                              title: Text(
                                note.isArchived ? 'Unarchive' : 'Archive',
                              ),
                            ),
                          ),

                          PopupMenuItem(
                            value: 'delete',
                            child: ListTile(
                              leading: const Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                              title: const Text('Delete'),
                            ),
                          ),
                        ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuSelection(String value, BuildContext context) {
    switch (value) {
      case 'color':
        _showColorPickerDialog(context);
        break;
      case 'share':
        _shareNote(context);
        break;
      case 'archive':
        if (note.isArchived) {
          Provider.of<NotesProvider>(
            context,
            listen: false,
          ).unarchiveNote(note.id);
        } else {
          Provider.of<NotesProvider>(
            context,
            listen: false,
          ).archiveNote(note.id);
        }
        break;
      case 'delete':
        _showDeleteConfirmationDialog(context);
        break;
    }
  }

  void _showColorPickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ColorPickerDialog(
          selectedColor: Color(int.parse(note.color)),
          onColorSelected: (newColor) {
            String colorHex = newColor
                .toARGB32()
                .toRadixString(16)
                .padLeft(8, '0');
            colorHex = '0x$colorHex';
            Provider.of<NotesProvider>(
              context,
              listen: false,
            ).updateNoteColor(note.id, colorHex);
          },
        );
      },
    );
  }

  void _shareNote(BuildContext context) {
    final String noteContent = '${note.title}\n\n${note.content}';
    SharePlus.instance.share(
      ShareParams(text: noteContent, subject: 'Check out this note!'),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    final String noteTittle = note.title.trim();
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
                ).deleteNote(note.id);
                Navigator.of(context).pop();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
