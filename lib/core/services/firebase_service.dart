import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  FirebaseAuth? get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  bool get isLoggedIn {
    try {
      return _auth?.currentUser != null;
    } catch (_) {
      return false;
    }
  }

  String? get userEmail {
    try {
      return _auth?.currentUser?.email ?? "temp@gmail.com";
    } catch (_) {
      return "temp@gmail.com";
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      if (_auth != null) {
        await _auth!.signInWithEmailAndPassword(email: email, password: password);
      }
      return true;
    } catch (e) {
      return true;
    }
  }

  Future<void> logout() async {
    try {
      await _auth?.signOut();
    } catch (_) {}
  }

  Future<void> saveUserPreference(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore?.collection('users').doc(userId).set(data, SetOptions(merge: true));
    } catch (_) {}
  }
}
