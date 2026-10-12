import 'package:flutter/material.dart';
import 'package:whacka_app/models/note.dart';
import 'package:whacka_app/screens/emotional_ai_screen.dart';
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
    final safePadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF17120F),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF17120F),
              Color(0xFF211914),
              Color(0xFF120F0E),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.menu, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2B2B2B),
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.add, color: Colors.white, size: 26),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'whacka.app/?pro',
                                  hintStyle: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(Icons.home_outlined, color: Colors.white),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2D2925), Color(0xFF1B1716)],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: const Color(0xFF5E4333), width: 1.2),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 74,
                              height: 74,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [Color(0xFF92E6D8), Color(0xFF2B6F6F)],
                                ),
                              ),
                              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'ملاحظات الذكاء',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'سجل أفكارك الصوتية وأفصح عنها بسرعة',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const RecordScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFB020),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.arrow_forward, color: Colors.black, size: 28),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const EmotionalAIChatScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2B2B2B),
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(color: const Color(0xFFFFB020), width: 1.5),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'بحث بالكلمات',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const EmotionalAIChatScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2B2B2B),
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'بحث في مذكراتك',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'اكتب كلمة أو نصًّا في مذكرتك...',
                            hintStyle: TextStyle(color: Colors.white70),
                            prefixIcon: Icon(Icons.search, color: Color(0xFFFFB020)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      if (isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 30),
                          child: CircularProgressIndicator(color: Color(0xFFFFB020)),
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'مذكرتي',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ...filteredNotes.map((note) => NoteCard(
                                  note: note,
                                  onDelete: () => _deleteNote(note.id),
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(note.title)),
                                    );
                                  },
                                )),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              Container(
                height: 90 + safePadding,
                padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + safePadding),
                decoration: const BoxDecoration(
                  color: Color(0xFF17120F),
                  border: Border(top: BorderSide(color: Color(0xFF3A2F2A), width: 1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _bottomItem(Icons.home_outlined, 'الرئيسية', true),
                    _bottomItem(Icons.favorite_border, 'المشاعر', false),
                    _floatingMicButton(),
                    _bottomItem(Icons.chat_bubble_outline, 'الدعم', false),
                    _bottomItem(Icons.person_outline, 'الملف', false),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomItem(IconData icon, String label, bool active) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: active ? const Color(0xFFFFB020) : Colors.white70, size: 26),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: active ? const Color(0xFFFFB020) : Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _floatingMicButton() {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RecordScreen()),
        );
        await _loadNotes();
      },
      child: Container(
        width: 72,
        height: 72,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(0xFFFFB020), Color(0xFFC77B00)],
          ),
          boxShadow: [
            BoxShadow(color: Color(0xFFFFB020), blurRadius: 16, spreadRadius: 2),
          ],
        ),
        child: const Icon(Icons.mic, size: 34, color: Colors.black),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
