

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignOutUseCase {
  SignOutUseCase();

  Future<bool> call() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await GoogleSignIn().disconnect();
      await FirebaseAuth.instance.signOut();
      prefs.clear();
      return true;
    } on Exception catch (_) {
      return false;
    }
  }
}
