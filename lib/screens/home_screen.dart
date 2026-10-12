import 'package:flutter/material.dart';
import 'package:whacka_app/models/note.dart';
import 'package:whacka_app/screens/record_screen.dart';
import 'package:whacka_app/services/firebase_service.dart';
import 'package:whacka_app/widgets/note_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _searchController = TextEditingController();

  List<Note> allNotes = [];
  List<Note> filteredNotes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _searchController.addListener(_filterNotes);
  }

  Future<void> _loadNotes() async {
    setState(() => isLoading = true);
    final notes = await _firebaseService.getNotes();
    setState(() {
      allNotes = notes;
      filteredNotes = notes;
      isLoading = false;
    });
  }

  void _filterNotes() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredNotes = allNotes;
      } else {
        filteredNotes = allNotes.where((note) {
          return note.title.toLowerCase().contains(query) ||
              note.content.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  Future<void> _deleteNote(String noteId) async {
    await _firebaseService.deleteNote(noteId);
    await _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Whacka'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1D1D1D),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'بحث في المذكرات...',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF2A2A2A),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredNotes.isEmpty
                    ? const Center(
                        child: Text(
                          'لا توجد مذكرات بعد',
                          style: TextStyle(color: Colors.grey, fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredNotes.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final note = filteredNotes[index];
                          return NoteCard(
                            note: note,
                            onDelete: () => _deleteNote(note.id),
                            onTap: () {},
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFFB020),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RecordScreen()),
          );
          await _loadNotes();
        },
        child: const Icon(Icons.mic, color: Colors.black),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
