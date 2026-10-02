import 'dart:convert';
import 'dart:io' show File;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';

class ImageUtils {
  ImageUtils._();

  static const String defaultAvatar =
      'https://images.pexels.com/users/avatars/1640777/pexels-user-1640777.jpeg?auto=compress&cs=tinysrgb&w=200';

  /// Trả về ImageProvider phù hợp cho ảnh đại diện:
  /// - URL http(s)  -> ảnh mạng có cache
  /// - data:image/* -> ảnh base64 (chạy được cả Web lẫn Mobile, lưu được)
  /// - đường dẫn file -> ảnh trong máy (chỉ Mobile/Desktop)
  static ImageProvider avatarProvider(String source) {
    if (source.startsWith('data:image')) {
      final comma = source.indexOf(',');
      if (comma != -1) {
        try {
          return MemoryImage(base64Decode(source.substring(comma + 1)));
        } catch (_) {}
      }
    }
    if (source.startsWith('http')) {
      return CachedNetworkImageProvider(source);
    }
    if (!kIsWeb && source.isNotEmpty) {
      return FileImage(File(source));
    }
    return CachedNetworkImageProvider(defaultAvatar);
  }

  /// Đoán MIME từ tên file.
  static String guessMimeType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.heic')) return 'image/heic';
    return 'image/jpeg';
  }
}
