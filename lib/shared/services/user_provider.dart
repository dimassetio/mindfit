import 'package:flutter/widgets.dart';
import 'package:health_tracker/data/models/user_model.dart';
import 'package:health_tracker/data/repositories/firebase_auth.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  final FirebaseAuthRepo _authRepo = FirebaseAuthRepo();

  User get getUser => _user!;

  Future<void> refreshUser() async {
    try {
      User? user = await _authRepo.getUserDetails();
      if (user is User) {
        _user = user;
        notifyListeners();
      }
    } catch (e) {
      print("User data belum ada di Firestore: $e");
      // Bisa pilih: diamkan saja, atau kasih user kosong, atau re-try nanti.
    }
  }
}
