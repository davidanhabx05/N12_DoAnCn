import 'package:flutter/material.dart';
import '../../models/post.dart';
import '../../models/comment.dart';

class FeedViewModel extends ChangeNotifier {
  final List<Post> _posts = [
    Post(
      id: '1',
      authorName: 'Ngọc Ánh',
      authorAvatarUrl: 'https://images.pexels.com/users/avatars/4109128/pexels-user-4109128.jpeg?auto=compress&cs=tinysrgb&w=200',
      timeAgo: '1 giờ trước',
      imageUrl: 'https://images.pexels.com/photos/2641886/pexels-photo-2641886.jpeg?auto=compress&cs=tinysrgb&w=1000',
      caption: 'Bát phở bò nóng hổi cho buổi sáng se lạnh 🍜 chuẩn vị Hà Nội!',
      likesCount: 156,
      sharesCount: 42,
      isLiked: true,
      location: 'Hà Nội',
      comments: [
        Comment(id: 'c1', authorName: 'Minh Tuấn', authorAvatarUrl: 'https://images.pexels.com/users/avatars/2410602/pexels-user-2410602.jpeg?auto=compress&cs=tinysrgb&w=200', content: 'Ngon quá bạn ơi!', timestamp: DateTime.now().subtract(const Duration(minutes: 45))),
        Comment(id: 'c2', authorName: 'Linh Chi', authorAvatarUrl: 'https://images.pexels.com/users/avatars/1600711/pexels-user-1600711.jpeg?auto=compress&cs=tinysrgb&w=200', content: 'Phở Thìn đúng không ta?', timestamp: DateTime.now().subtract(const Duration(minutes: 30))),
        Comment(id: 'c3', authorName: 'Hoàng Nam', authorAvatarUrl: 'https://images.pexels.com/users/avatars/1624487/pexels-user-1624487.jpeg?auto=compress&cs=tinysrgb&w=200', content: 'Nhìn mà thèm quá đi mất!', timestamp: DateTime.now().subtract(const Duration(minutes: 10))),
      ],
    ),
    Post(
      id: '2',
      authorName: 'Minh Tuấn',
      authorAvatarUrl: 'https://images.pexels.com/users/avatars/2410602/pexels-user-2410602.jpeg?auto=compress&cs=tinysrgb&w=200',
      timeAgo: '3 giờ trước',
      imageUrl: 'https://images.pexels.com/photos/4109128/pexels-photo-4109128.jpeg?auto=compress&cs=tinysrgb&w=1000',
      caption: 'Bánh mì thịt nướng giòn rụm, nước xốt đậm đà 🥖🔥',
      likesCount: 89,
      sharesCount: 12,
      isLiked: false,
      location: 'Sài Gòn',
      comments: [
        Comment(id: 'c4', authorName: 'Huyền Trang', authorAvatarUrl: 'https://images.pexels.com/users/avatars/2410602/pexels-user-2410602.jpeg?auto=compress&cs=tinysrgb&w=200', content: 'Ổ bánh mì chất lượng quá!', timestamp: DateTime.now().subtract(const Duration(hours: 1))),
        Comment(id: 'c5', authorName: 'Quốc Bảo', authorAvatarUrl: 'https://images.pexels.com/users/avatars/4109128/pexels-user-4109128.jpeg?auto=compress&cs=tinysrgb&w=200', content: 'Xin địa chỉ shop ơi!', timestamp: DateTime.now().subtract(const Duration(hours: 2))),
      ],
    ),
    Post(
      id: '3',
      authorName: 'Linh Chi',
      authorAvatarUrl: 'https://images.pexels.com/users/avatars/1600711/pexels-user-1600711.jpeg?auto=compress&cs=tinysrgb&w=200',
      timeAgo: '5 giờ trước',
      imageUrl: 'https://images.pexels.com/photos/1600711/pexels-photo-1600711.jpeg?auto=compress&cs=tinysrgb&w=1000',
      caption: 'Gỏi cuốn tôm thịt thanh mát cho ngày hè oi bức 🥗🍤',
      likesCount: 234,
      sharesCount: 15,
      isLiked: true,
      location: 'Đà Nẵng',
      comments: [
        Comment(id: 'c6', authorName: 'Đức Anh', authorAvatarUrl: 'https://images.pexels.com/users/avatars/4109130/pexels-user-4109130.jpeg?auto=compress&cs=tinysrgb&w=200', content: 'Chấm mắm nêm là đỉnh luôn!', timestamp: DateTime.now().subtract(const Duration(hours: 3))),
      ],
    ),
    Post(
      id: '4',
      authorName: 'Hoàng Nam',
      authorAvatarUrl: 'https://images.pexels.com/users/avatars/1624487/pexels-user-1624487.jpeg?auto=compress&cs=tinysrgb&w=200',
      timeAgo: '8 giờ trước',
      imageUrl: 'https://images.pexels.com/photos/1624487/pexels-photo-1624487.jpeg?auto=compress&cs=tinysrgb&w=1000',
      caption: 'Cơm tấm sườn bì chả - đặc sản Sài Gòn không thể bỏ lỡ 🍱',
      likesCount: 312,
      sharesCount: 28,
      isLiked: false,
      location: 'Hà Nội',
      comments: [
        Comment(id: 'c7', authorName: 'Yến Nhi', authorAvatarUrl: 'https://images.pexels.com/users/avatars/1143754/pexels-user-1143754.jpeg?auto=compress&cs=tinysrgb&w=200', content: 'Sườn nhìn mọng nước quá!', timestamp: DateTime.now().subtract(const Duration(hours: 5))),
      ],
    ),
    Post(
      id: '5',
      authorName: 'Huyền Trang',
      authorAvatarUrl: 'https://images.pexels.com/users/avatars/2410602/pexels-user-2410602.jpeg?auto=compress&cs=tinysrgb&w=200',
      timeAgo: '12 giờ trước',
      imageUrl: 'https://images.pexels.com/photos/2410602/pexels-photo-2410602.jpeg?auto=compress&cs=tinysrgb&w=1000',
      caption: 'Bún chả chiều thu, hương vị gây thương nhớ 🥢',
      likesCount: 187,
      isLiked: true,
      location: 'Hà Nội',
    ),
    Post(
      id: '6',
      authorName: 'Quốc Bảo',
      authorAvatarUrl: 'https://images.pexels.com/users/avatars/4109128/pexels-user-4109128.jpeg?auto=compress&cs=tinysrgb&w=200',
      timeAgo: '1 ngày trước',
      imageUrl: 'https://images.pexels.com/photos/1273765/pexels-photo-1273765.jpeg?auto=compress&cs=tinysrgb&w=1000',
      caption: 'Cuối tuần làm tí đồ nướng chill cùng bạn bè thôi nào! 🍢🍻',
      likesCount: 456,
      isLiked: false,
      location: 'Sài Gòn',
    ),
    Post(
      id: '7',
      authorName: 'Thúy Vi',
      authorAvatarUrl: 'https://images.pexels.com/users/avatars/1640777/pexels-user-1640777.jpeg?auto=compress&cs=tinysrgb&w=200',
      timeAgo: '2 ngày trước',
      imageUrl: 'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&w=1000',
      caption: 'Salad rau củ cho những ngày muốn ăn uống healthy 🥗✨',
      likesCount: 98,
      isLiked: true,
      location: 'Đà Lạt',
    ),
    Post(
      id: '8',
      authorName: 'Đức Anh',
      authorAvatarUrl: 'https://images.pexels.com/users/avatars/4109130/pexels-user-4109130.jpeg?auto=compress&cs=tinysrgb&w=200',
      timeAgo: '2 ngày trước',
      imageUrl: 'https://images.pexels.com/photos/4109130/pexels-photo-4109130.jpeg?auto=compress&cs=tinysrgb&w=1000',
      caption: 'Pizza tự làm tại nhà, trông cũng ra gì phết đấy chứ? 🍕😋',
      likesCount: 567,
      isLiked: false,
      location: 'Hà Nội',
    ),
    Post(
      id: '9',
      authorName: 'Mai Linh',
      authorAvatarUrl: 'https://images.pexels.com/users/avatars/1059943/pexels-user-1059943.jpeg?auto=compress&cs=tinysrgb&w=200',
      timeAgo: '3 ngày trước',
      imageUrl: 'https://images.pexels.com/photos/1059943/pexels-photo-1059943.jpeg?auto=compress&cs=tinysrgb&w=1000',
      caption: 'Gà nướng lu thơm phức, da giòn rụm luôn 🍗🔥',
      likesCount: 432,
      isLiked: true,
      location: 'Hải Phòng',
    ),
    Post(
      id: '10',
      authorName: 'Tuấn Kiệt',
      authorAvatarUrl: 'https://images.pexels.com/users/avatars/1624487/pexels-user-1624487.jpeg?auto=compress&cs=tinysrgb&w=200',
      timeAgo: '4 ngày trước',
      imageUrl: 'https://images.pexels.com/photos/2098085/pexels-photo-2098085.jpeg?auto=compress&cs=tinysrgb&w=1000',
      caption: 'Thèm hải sản là phải đi ăn ngay cho nóng 🦀🦐',
      likesCount: 890,
      isLiked: false,
      location: 'Vũng Tàu',
    ),
    Post(
      id: '11',
      authorName: 'Yến Nhi',
      authorAvatarUrl: 'https://images.pexels.com/users/avatars/1143754/pexels-user-1143754.jpeg?auto=compress&cs=tinysrgb&w=200',
      timeAgo: '5 ngày trước',
      imageUrl: 'https://images.pexels.com/photos/1143754/pexels-photo-1143754.jpeg?auto=compress&cs=tinysrgb&w=1000',
      caption: 'Một chiều bình yên bên tách trà và bánh ngọt 🍵🍰',
      likesCount: 124,
      isLiked: true,
      location: 'Hà Nội',
    ),
    Post(
      id: '12',
      authorName: 'Minh Quang',
      authorAvatarUrl: 'https://images.pexels.com/users/avatars/1731535/pexels-user-1731535.jpeg?auto=compress&cs=tinysrgb&w=200',
      timeAgo: '6 ngày trước',
      imageUrl: 'https://images.pexels.com/photos/1731535/pexels-photo-1731535.jpeg?auto=compress&cs=tinysrgb&w=1000',
      caption: 'Steak vừa chín tới, mọng nước cực kỳ 🥩 mlem mlem',
      likesCount: 654,
      isLiked: false,
      location: 'Sài Gòn',
    ),
    Post(
      id: '13',
      authorName: 'Bích Phương',
      authorAvatarUrl: 'https://images.pexels.com/users/avatars/6260921/pexels-user-6260921.jpeg?auto=compress&cs=tinysrgb&w=200',
      timeAgo: '1 tuần trước',
      imageUrl: 'https://images.pexels.com/photos/6260921/pexels-photo-6260921.jpeg?auto=compress&cs=tinysrgb&w=1000',
      caption: 'Lẩu thái cay nồng cho ngày mưa gió 🍲🌶️',
      likesCount: 321,
      isLiked: true,
      location: 'Hà Nội',
    ),
    Post(
      id: '14',
      authorName: 'Thành Trung',
      authorAvatarUrl: 'https://images.pexels.com/users/avatars/2641886/pexels-user-2641886.jpeg?auto=compress&cs=tinysrgb&w=200',
      timeAgo: '1 tuần trước',
      imageUrl: 'https://images.pexels.com/photos/2641886/pexels-photo-2641886.jpeg?auto=compress&cs=tinysrgb&w=1000',
      caption: 'Bún đậu mắm tôm - niềm đam mê bất tận 🌿🥓',
      likesCount: 765,
      isLiked: false,
      location: 'Hà Nội',
    ),
    Post(
      id: '15',
      authorName: 'Hải Yến',
      authorAvatarUrl: 'https://images.pexels.com/users/avatars/1907244/pexels-user-1907244.jpeg?auto=compress&cs=tinysrgb&w=200',
      timeAgo: '2 tuần trước',
      imageUrl: 'https://images.pexels.com/photos/1907244/pexels-photo-1907244.jpeg?auto=compress&cs=tinysrgb&w=1000',
      caption: 'Mì Quảng chuẩn vị miền Trung đây rồi mọi người ơi 🍜🥢',
      likesCount: 543,
      isLiked: true,
      location: 'Huế',
    ),
    Post(
      id: '16',
      authorName: 'Khánh Huyền',
      authorAvatarUrl: 'https://images.pexels.com/users/avatars/4061557/pexels-user-4061557.jpeg?auto=compress&cs=tinysrgb&w=200',
      timeAgo: '2 tuần trước',
      imageUrl: 'https://images.pexels.com/photos/4061557/pexels-photo-4061557.jpeg?auto=compress&cs=tinysrgb&w=1000',
      caption: 'Gỏi xoài tôm khô chua cay mặn ngọt đủ cả 🥗🌶️',
      likesCount: 210,
      isLiked: false,
      location: 'Sài Gòn',
    ),
    Post(
      id: '17',
      authorName: 'Nhật Minh',
      authorAvatarUrl: 'https://images.pexels.com/users/avatars/1640772/pexels-user-1640772.jpeg?auto=compress&cs=tinysrgb&w=200',
      timeAgo: '3 tuần trước',
      imageUrl: 'https://images.pexels.com/photos/1640772/pexels-photo-1640772.jpeg?auto=compress&cs=tinysrgb&w=1000',
      caption: 'Canh chua cá lóc giải nhiệt cho bữa cơm chiều 🍲🐟',
      likesCount: 345,
      isLiked: true,
      location: 'Cần Thơ',
    ),
    Post(
      id: '18',
      authorName: 'Gia Bảo',
      authorAvatarUrl: 'https://images.pexels.com/users/avatars/1143754/pexels-user-1143754.jpeg?auto=compress&cs=tinysrgb&w=200',
      timeAgo: '3 tuần trước',
      imageUrl: 'https://images.pexels.com/photos/1143754/pexels-photo-1143754.jpeg?auto=compress&cs=tinysrgb&w=1000',
      caption: 'Lẩu nấm chay thanh đạm cho ngày rằm 🍄🍵',
      likesCount: 129,
      isLiked: false,
      location: 'Huế',
    ),
    Post(
      id: '19',
      authorName: 'Minh Thư',
      authorAvatarUrl: 'https://images.pexels.com/users/avatars/2098085/pexels-user-2098085.jpeg?auto=compress&cs=tinysrgb&w=200',
      timeAgo: '1 tháng trước',
      imageUrl: 'https://images.pexels.com/photos/2098085/pexels-photo-2098085.jpeg?auto=compress&cs=tinysrgb&w=1000',
      caption: 'Mì xào giòn hải sản siêu nhiều topping luôn nha 🍝🦐',
      likesCount: 678,
      isLiked: true,
      location: 'Sài Gòn',
    ),
    Post(
      id: '20',
      authorName: 'Đăng Khoa',
      authorAvatarUrl: 'https://images.pexels.com/users/avatars/262959/pexels-user-262959.jpeg?auto=compress&cs=tinysrgb&w=200',
      timeAgo: '1 tháng trước',
      imageUrl: 'https://images.pexels.com/photos/262959/pexels-photo-262959.jpeg?auto=compress&cs=tinysrgb&w=1000',
      caption: 'Xôi xéo mỡ hành thơm nức mũi cả khu phố 🍚💛',
      likesCount: 999,
      isLiked: true,
      location: 'Hà Nội',
    ),
  ];

  String _currentFilter = 'Mới nhất';
  String get currentFilter => _currentFilter;

  List<Post> get posts {
    List<Post> result = List.from(_posts);
    if (_currentFilter == 'Xu hướng') {
      result.sort((a, b) => b.likesCount.compareTo(a.likesCount));
    } else if (_currentFilter == 'Gần bạn') {
      // Giả lập vị trí người dùng ở Hà Nội
      result = result.where((p) => p.location == 'Hà Nội').toList();
    }
    // 'Mới nhất' là mặc định theo thứ tự _posts (với addNewPost dùng insert(0))
    return result;
  }

  void setFilter(String filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  int _userPostsCount = 0;
  int get userPostsCount => _userPostsCount;

  void toggleLike(String postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      _posts[index] = post.copyWith(
        isLiked: !post.isLiked,
        likesCount: post.isLiked ? post.likesCount - 1 : post.likesCount + 1,
      );
      notifyListeners();
    }
  }

  void toggleSave(String postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      _posts[index] = post.copyWith(isSaved: !post.isSaved);
      notifyListeners();
    }
  }

  void addComment(String postId, String content) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      final newComment = Comment(
        id: DateTime.now().toString(),
        authorName: 'Bạn (Foodie)',
        authorAvatarUrl: 'https://images.pexels.com/users/avatars/1640777/pexels-user-1640777.jpeg?auto=compress&cs=tinysrgb&w=200',
        content: content,
        timestamp: DateTime.now(),
      );
      
      List<Comment> updatedComments = List.from(post.comments);
      updatedComments.add(newComment);
      
      _posts[index] = post.copyWith(comments: updatedComments);
      notifyListeners();
    }
  }

  void addNewPost(String caption, String imageUrl, {String location = 'Hà Nội'}) {
    final newPost = Post(
      id: DateTime.now().toString(),
      authorName: 'Bạn (Foodie)',
      authorAvatarUrl: 'https://images.pexels.com/users/avatars/1640777/pexels-user-1640777.jpeg?auto=compress&cs=tinysrgb&w=200',
      timeAgo: 'Vừa xong',
      imageUrl: imageUrl,
      caption: caption,
      likesCount: 0,
      isLiked: false,
      location: location,
    );
    _posts.insert(0, newPost);
    _userPostsCount++;
    notifyListeners();
  }
}
