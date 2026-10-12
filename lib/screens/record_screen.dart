import 'package:flutter/material.dart';
import 'package:whacka_app/models/note.dart';
import 'package:whacka_app/services/firebase_service.dart';
import 'package:whacka_app/services/speech_service.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final SpeechService _speechService = SpeechService();
  final FirebaseService _firebaseService = FirebaseService();

  String selectedCategory = 'عام';
  bool isRecording = false;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _speechService.onResult = (text) {
      setState(() {
        _contentController.text = text;
      });
    };
    _speechService.onError = (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    };
  }

  Future<void> _toggleRecording() async {
    if (isRecording) {
      final text = await _speechService.stopListening();
      setState(() {
        isRecording = false;
        _contentController.text = text;
      });
      return;
    }

    final ready = await _speechService.initialize();
    if (!ready) return;

    await _speechService.startListening();
    setState(() => isRecording = true);
  }

  Future<void> _saveNote() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل نصاً أو سجل مذكرة أولاً.')),
      );
      return;
    }

    setState(() => isSaving = true);

    final note = Note(
      id: '',
      userId: _firebaseService.currentUserId,
      title: _titleController.text.trim().isEmpty
          ? content.substring(0, content.length > 25 ? 25 : content.length)
          : _titleController.text.trim(),
      content: content,
      category: selectedCategory,
      createdAt: DateTime.now(),
      isFavorite: false,
    );

    try {
      await _firebaseService.saveNote(note);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء الحفظ: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D1D1D),
        title: const Text('مذكرة جديدة'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'عنوان المذكرة',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF2A2A2A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<String>(
                value: selectedCategory,
                isExpanded: true,
                underline: const SizedBox(),
                dropdownColor: const Color(0xFF2A2A2A),
                style: const TextStyle(color: Colors.white),
                items: const [
                  DropdownMenuItem(value: 'عام', child: Text('عام')),
                  DropdownMenuItem(value: 'عمل', child: Text('عمل')),
                  DropdownMenuItem(value: 'شخصي', child: Text('شخصي')),
                  DropdownMenuItem(value: 'تعليم', child: Text('تعليم')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedCategory = value);
                  }
                },
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: GestureDetector(
                onTap: _toggleRecording,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: isRecording ? Colors.red : const Color(0xFFFFB020),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isRecording ? Colors.red : const Color(0xFFFFB020))
                            .withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                  child: Icon(
                    isRecording ? Icons.stop : Icons.mic,
                    size: 52,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Center(
              child: Text(
                'اضغط لبدء أو إيقاف التسجيل',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'النص المحول',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              maxLines: 8,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'سيظهر النص هنا...',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF2A2A2A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSaving ? null : _saveNote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB020),
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'حفظ المذكرة',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
