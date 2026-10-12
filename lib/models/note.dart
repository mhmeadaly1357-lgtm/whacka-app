class Note {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String category;
  final DateTime createdAt;
  final bool isFavorite;
  final String? audioUrl;

  Note({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.category,
    required this.createdAt,
    this.isFavorite = false,
    this.audioUrl,
  });

  factory Note.fromMap(Map<String, dynamic> data, String id) {
    return Note(
      id: id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? 'بدون عنوان',
      content: data['content'] ?? '',
      category: data['category'] ?? 'عام',
      createdAt: data['created_at'] != null
          ? (data['created_at'] as dynamic).toDate()
          : DateTime.now(),
      isFavorite: data['is_favorite'] ?? false,
      audioUrl: data['audio_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'content': content,
      'category': category,
      'created_at': createdAt,
      'is_favorite': isFavorite,
      'audio_url': audioUrl,
    };
  }
}
