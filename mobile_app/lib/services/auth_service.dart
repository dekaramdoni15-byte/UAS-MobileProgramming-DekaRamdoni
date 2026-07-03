import 'package:firebase_auth/firebase_auth.dart';

// Materi: Firebase Authentication (Pertemuan 10)
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream untuk memantau status login user (dipakai di main.dart)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // LOGIN
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // null = sukses, tidak ada error
    } on FirebaseAuthException catch (e) {
      return _mapErrorMessage(e.code);
    }
  }

  // REGISTER
  Future<String?> register(String nama, String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Simpan nama sebagai displayName
      await credential.user?.updateDisplayName(nama);
      await credential.user?.reload();
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapErrorMessage(e.code);
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }

  String _mapErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Email tidak terdaftar';
      case 'wrong-password':
        return 'Password salah';
      case 'email-already-in-use':
        return 'Email sudah terdaftar';
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'weak-password':
        return 'Password terlalu lemah (minimal 6 karakter)';
      default:
        return 'Terjadi kesalahan: $code';
    }
  }
}
