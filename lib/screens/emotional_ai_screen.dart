import 'package:flutter/material.dart';
import 'package:whacka_app/services/openai_service.dart';

class EmotionalAIChatScreen extends StatefulWidget {
  const EmotionalAIChatScreen({super.key});

  @override
  State<EmotionalAIChatScreen> createState() => _EmotionalAIChatScreenState();
}

class _EmotionalAIChatScreenState extends State<EmotionalAIChatScreen> {
  final _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      'role': 'assistant',
      'text': 'مرحباً، أنا مساعدك العاطفي. كيف حالك اليوم؟',
    },
  ];
  String? selectedEmotion;
  bool isLoading = false;

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      isLoading = true;
    });
    _messageController.clear();

    final service = OpenAIService();
    final reply = selectedEmotion != null
        ? await service.getResponseByEmotion(selectedEmotion!, text)
        : await service.getEmotionalResponse(text);

    setState(() {
      _messages.add({'role': 'assistant', 'text': reply});
      isLoading = false;
      selectedEmotion = null;
    });
  }

  Widget _emotionChip(String emoji, String label) {
    final active = selectedEmotion == label;
    return ChoiceChip(
      label: Text('$emoji $label'),
      selected: active,
      onSelected: (_) => setState(() => selectedEmotion = active ? null : label),
      backgroundColor: const Color(0xFF2A2A2A),
      selectedColor: const Color(0xFFFFB020),
      labelStyle: TextStyle(
        color: active ? Colors.black : Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('الذكاء العاطفي'),
        backgroundColor: const Color(0xFF1D1D1D),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _emotionChip('😢', 'حزين'),
                _emotionChip('😨', 'خائف'),
                _emotionChip('😊', 'سعيد'),
                _emotionChip('😴', 'متعب'),
                _emotionChip('😤', 'غاضب'),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['role'] == 'user';

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFFFFB020) : const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      message['text'] ?? '',
                      style: TextStyle(
                        color: isUser ? Colors.black : Colors.white,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: CircularProgressIndicator(color: Color(0xFFFFB020)),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'اكتب ما تشعر به...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF2A2A2A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: isLoading ? null : _sendMessage,
                  backgroundColor: const Color(0xFFFFB020),
                  child: const Icon(Icons.send, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
