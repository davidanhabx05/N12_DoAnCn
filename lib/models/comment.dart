class Comment {
  final String id;
  final String authorName;
  final String authorAvatarUrl;
  final String content;
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.content,
    required this.timestamp,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inDays > 0) return '${diff.inDays} ngày trước';
    if (diff.inHours > 0) return '${diff.inHours} giờ trước';
    if (diff.inMinutes > 0) return '${diff.inMinutes} phút trước';
    return 'Vừa xong';
  }
}
