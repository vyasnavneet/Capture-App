import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keep/screens/archived_notes_screen.dart';
import 'package:keep/screens/settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../widgets/note_card.dart';
import '../providers/notes_provider.dart';
import 'note_editor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.changeTheme});
  final void Function() changeTheme;

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  String? firstSharedText;
  String _searchQuery = '';
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  bool _isGridView = true;
  final double searchBarHeight = 70.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _handleSharedText();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    Future.delayed(const Duration(milliseconds: 100), () {
      final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
      if (bottomInset == 0.0) {
        if (_searchFocusNode.hasFocus) {
          _searchFocusNode.unfocus();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final notesProvider = Provider.of<NotesProvider>(context);
    final filteredNotes =
        notesProvider.notes
            .where((note) => !note.isArchived)
            .where(
              (note) =>
                  note.title.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ||
                  note.content.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ),
            )
            .toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          myAppBar(context),
          if (_searchQuery.isEmpty)
            _isGridView
                ? SliverPadding(
                  padding: const EdgeInsets.all(8.0),
                  sliver: SliverMasonryGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0,
                    childCount: filteredNotes.length,
                    itemBuilder: (context, index) {
                      return NoteCard(
                        note: filteredNotes[index],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => NoteEditorScreen(
                                    note: filteredNotes[index],
                                  ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                )
                : SliverToBoxAdapter(
                  child: ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(8.0),
                    itemCount: filteredNotes.length,
                    itemBuilder: (context, index) {
                      final note = filteredNotes[index];
                      return NoteCard(
                        key: ValueKey(note.id),
                        note: note,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => NoteEditorScreen(note: note),
                            ),
                          );
                        },
                      );
                    },
                    onReorder: (oldIndex, newIndex) {
                      notesProvider.reorderNotes(oldIndex, newIndex);
                    },
                  ),
                )
          else
            SliverPadding(
              padding: const EdgeInsets.all(8.0),
              sliver: SliverMasonryGrid.count(
                crossAxisCount: _isGridView ? 2 : 1,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
                childCount: filteredNotes.length,
                itemBuilder: (context, index) {
                  return NoteCard(
                    note: filteredNotes[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  NoteEditorScreen(note: filteredNotes[index]),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NoteEditorScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget myAppBar(BuildContext context) {
    return SliverAppBar(
      elevation: 4.0,
      floating: true,
      pinned: false,
      snap: true,
      toolbarHeight: 60.0,
      title: const Text('Notes'),
      actions: [
        IconButton(
          icon: Icon(
            _isGridView ? Icons.grid_view_outlined : Icons.list_outlined,
          ),
          tooltip: _isGridView ? 'Switch to List View' : 'Switch to Grid View',
          onPressed: () {
            setState(() {
              _isGridView = !_isGridView;
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.archive_outlined),
          tooltip: 'Archived Notes',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ArchivedNotesScreen(),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Settings',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => SettingsScreen(loadTheme: widget.changeTheme),
              ),
            );
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(searchBarHeight),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(30.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Search your notes',
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 20.0,
                ),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _searchFocusNode.unfocus();
                          },
                        )
                        : null,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSharedText() async {
    try {
      final String? sharedText = await const MethodChannel(
        'com.yourcompany.notes/sharing',
      ).invokeMethod('getSharedText');

      if (sharedText != null && sharedText.isNotEmpty) {
        if (mounted) {
          setState(() {
            firstSharedText = sharedText;
          });

          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) => NoteEditorScreen(initialContent: sharedText),
            ),
          );
        }
      }
    } on PlatformException catch (e) {
      debugPrint("Error getting shared text: ${e.message}");
    }
  }
}
