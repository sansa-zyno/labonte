import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static Future<String?> signInEmailAndPass(String email, String password) async {
    try {
      UserCredential authResult = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = authResult.user;
      if (user != null) {
        return user.uid;
      } else {
        return null;
      }
    } on FirebaseAuthException catch (signInError) {
      throw signInError.code;
    }
  }

  static Future<String?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential authResult = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = authResult.user;
      if (user != null) {
        return user.uid;
      } else {
        return null;
      }
    } on FirebaseAuthException catch (signUpError) {
      throw signUpError.code;
    }
  }

  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      //print(e.toString());
    }
  }

  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      //print(e.toString());
    }
  }
}
