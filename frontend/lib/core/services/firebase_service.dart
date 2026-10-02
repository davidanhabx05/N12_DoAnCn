import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

/// Firebase CHỈ dùng để đăng nhập Google. Dữ liệu người dùng lưu ở backend (PostgreSQL).
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  /// Firebase đã được khởi tạo thành công chưa (thiếu cấu hình -> false).
  bool get isAvailable {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  FirebaseAuth? get _auth {
    if (!isAvailable) return null;
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  User? get currentUser {
    try {
      return _auth?.currentUser;
    } catch (_) {
      return null;
    }
  }

  String? get userEmail => currentUser?.email;

  /// Đăng nhập Google và trả về Firebase ID token để gửi lên backend.
  /// Trả về null nếu người dùng huỷ. Ném lỗi nếu cấu hình Firebase / Google Sign-In chưa đúng.
  Future<String?> signInWithGoogleAndGetIdToken() async {
    final auth = _auth;
    if (auth == null) {
      throw StateError('Firebase chưa được khởi tạo');
    }

    User? user;
    if (kIsWeb) {
      final credential = await auth.signInWithPopup(GoogleAuthProvider());
      user = credential.user;
    } else {
      final googleUser = await GoogleSignIn(scopes: const ['email']).signIn();
      if (googleUser == null) return null; // người dùng đóng hộp thoại

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final result = await auth.signInWithCredential(credential);
      user = result.user;
    }
    if (user == null) return null;
    return user.getIdToken();
  }

  Future<void> logout() async {
    try {
      await _auth?.signOut();
    } catch (_) {}
    if (!kIsWeb) {
      try {
        await GoogleSignIn().signOut();
      } catch (_) {}
    }
  }

  /// Xoá tài khoản Firebase (dữ liệu đã được backend xoá). Nếu Firebase yêu cầu
  /// đăng nhập lại mới cho xoá thì chỉ đăng xuất.
  Future<void> deleteFirebaseUser() async {
    final user = currentUser;
    if (user == null) return;
    try {
      await user.delete();
    } catch (_) {
      await logout();
    }
  }
}
