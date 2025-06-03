import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:note_app/features/note_details/noteDetailsScreen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late CollectionReference _notesCollection;
  bool _isLoading = true;
  String _errorMessage = '';
  List<Map<String, dynamic>> _notes = [];

  @override
  void initState() {
    super.initState();
    _notesCollection = _firestore.collection('notes');
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('User not authenticated');
      }

      final docRef = _notesCollection.doc(user.email);
      final doc = await docRef.get();

      if (!doc.exists) {
        await docRef.set({'notes': []});
        setState(() {
          _notes = [];
          _isLoading = false;
        });
        return;
      }

      final data = doc.data() as Map<String, dynamic>;

      if (data['notes'] is Map) {
        final notesMap = data['notes'] as Map<String, dynamic>;
        final notesList = notesMap.values.toList();
        await docRef.update({'notes': notesList});
        setState(() {
          _notes = notesList.cast<Map<String, dynamic>>();
          _isLoading = false;
        });
      } else {
        final notes = data['notes'] as List<dynamic>? ?? [];
        setState(() {
          _notes = notes.cast<Map<String, dynamic>>();
          _isLoading = false;
        });
      }
    } on FirebaseException catch (e) {
      setState(() {
        _isLoading = false;
        if (e.code == 'permission-denied') {
          _errorMessage = 'You don\'t have permission to access notes';
        } else {
          _errorMessage = 'Error loading notes: ${e.message}';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Notes'),
      //   actions: [
      //     IconButton(icon: const Icon(Icons.refresh), onPressed: _loadNotes),
      //   ],
      // ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newNote = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NoteDetailsScreen()),
          );
          if (newNote != null) _addNoteToFirestore(newNote);
        },

        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadNotes, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _addNewNote,
              child: Image.asset(
                'assets/empty_state.png',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No notes available',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addNewNote,
              child: const Text('Create Your First Note'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _notes.length,
      itemBuilder: (context, index) {
        final note = _notes[index];
        return Dismissible(
          key: Key('${note['title']}_$index'),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) => _deleteNote(index),
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Note'),
                content: const Text(
                  'Are you sure you want to delete this note?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(note['title'] ?? 'No title'),
              subtitle: Text(note['content'] ?? ''),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteNote(index),
              ),
              onTap: () => _editNote(index),
            ),
          ),
        );
      },
    );
  }

  Future<void> _addNewNote() async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) return;

    final titleController = TextEditingController();
    final contentController = TextEditingController();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: 5,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a title')),
                  );
                  return;
                }
                Navigator.of(context).pop({
                  'title': titleController.text,
                  'content': contentController.text,
                });
              },
              child: const Text('Add Note'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      final newNote = {
        'title': result['title'] ?? '',
        'content': result['content'] ?? '',
        'createdAt': DateTime.now().toIso8601String(),
      };

      setState(() {
        _notes.add(newNote);
      });

      try {
        await _notesCollection.doc(user.email).update({
          'notes': FieldValue.arrayUnion([newNote]),
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to add note: $e';
          _notes.removeLast();
        });
      }
    }
  }

  Future<void> _editNote(int index) async {
    final editedNote = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteDetailsScreen(existingNote: _notes[index]),
      ),
    );

    if (editedNote != null) {
      _updateNoteInFirestore(index, editedNote);
    }
  }

  Future<void> _deleteNote(int index) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) return;

    final deletedNote = _notes[index];
    final wasLastNote = _notes.length == 1;

    setState(() {
      _notes.removeAt(index);
    });

    try {
      await _notesCollection.doc(user.email).update({
        'notes': FieldValue.arrayRemove([deletedNote]),
      });

      if (wasLastNote) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All notes have been deleted'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } on FirebaseException catch (e) {
      setState(() {
        _notes.insert(index, deletedNote);
        if (e.code == 'permission-denied') {
          _errorMessage = 'You don\'t have permission to delete notes';
        } else {
          _errorMessage = 'Error deleting note: ${e.message}';
        }
      });
    } catch (e) {
      setState(() {
        _notes.insert(index, deletedNote);
        _errorMessage = 'Failed to delete note: $e';
      });
    }
  }

  Future<void> _addNoteToFirestore(Map<String, dynamic> note) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) return;

    setState(() => _notes.add(note));
    try {
      await _notesCollection.doc(user.email).update({
        'notes': FieldValue.arrayUnion([note]),
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to add note: $e';
        _notes.removeLast();
      });
    }
  }

  Future<void> _updateNoteInFirestore(
    int index,
    Map<String, dynamic> note,
  ) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) return;

    final oldNote = _notes[index];
    setState(() => _notes[index] = note);

    try {
      await _notesCollection.doc(user.email).update({'notes': _notes});
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to update note: $e';
        _notes[index] = oldNote;
      });
    }
  }
}
