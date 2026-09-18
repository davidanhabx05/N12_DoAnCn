import 'comment.dart';

class Post {
  final String id;
  final String authorName;
  final String authorAvatarUrl;
  final String timeAgo;
  final String imageUrl;
  final String caption;
  final int likesCount;
  final bool isLiked;
  final bool isSaved;
  final int sharesCount;
  final List<Comment> comments;
  final String location;

  Post({
    required this.id,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.timeAgo,
    required this.imageUrl,
    required this.caption,
    this.likesCount = 0,
    this.isLiked = false,
    this.isSaved = false,
    this.sharesCount = 0,
    this.comments = const [],
    this.location = 'Hà Nội',
  });

  Post copyWith({
    String? id,
    String? authorName,
    String? authorAvatarUrl,
    String? timeAgo,
    String? imageUrl,
    String? caption,
    int? likesCount,
    bool? isLiked,
    bool? isSaved,
    int? sharesCount,
    List<Comment>? comments,
    String? location,
  }) {
    return Post(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      timeAgo: timeAgo ?? this.timeAgo,
      imageUrl: imageUrl ?? this.imageUrl,
      caption: caption ?? this.caption,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      sharesCount: sharesCount ?? this.sharesCount,
      comments: comments ?? this.comments,
      location: location ?? this.location,
    );
  }
}
