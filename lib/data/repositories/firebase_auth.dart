import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:health_tracker/data/repositories/storage.dart';
import 'package:health_tracker/data/repositories/user_repository.dart';
import 'package:health_tracker/data/models/user_model.dart' as model;
import 'package:health_tracker/shared/constants/consts_variables.dart';

class FirebaseAuthRepo implements UserRepository {
  FirebaseAuthRepo();

  final _firebaseAuth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<model.User> getUserDetails() async {
    User currentUser = _firebaseAuth.currentUser!;

    DocumentSnapshot documentSnapshot =
        await _firestore.collection('users').doc(currentUser.uid).get();
    // If documentSnapshot does not exist, create a new user
    if (!documentSnapshot.exists) {
      // Create a new user model with the available data
      if (currentUser.displayName == null) {
        await currentUser.updateDisplayName("User Name");
      }
      model.User newUser = model.User(
        username: currentUser.displayName ??
            'User Name', // You can adjust this if necessary
        uid: currentUser.uid,
        sex: Sex
            .male, // You should adjust based on available data or default value
        photoUrl: currentUser.photoURL ??
            'https://i.stack.imgur.com/l60Hf.png', // Default profile image
        email: currentUser.email ?? 'No Email',
        bio: '',
        bookmarkedRecipes: [],
        followers: [],
        following: [],
        isDarkMode: true,
      );

      // Set the new user data into Firestore
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .set(newUser.toJson());

      // Return the newly created user
      return newUser;
    } else {
      // If the document exists, return the existing user data
      return model.User.fromSnap(documentSnapshot);
    }
    return model.User.fromSnap(documentSnapshot);
  }

  @override
  Future<UserCredential?> login(
      {required String email, required String password}) async {
    try {
      var creds = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return creds;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        throw 'Wrong password provided for that user.';
      }
      return null;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<void> register({
    required String username,
    required String email,
    required String password,
    required Sex sex,
    Uint8List? file,
  }) async {
    try {
      print("CREATE USER FIREBASE!");
      UserCredential cred = await _firebaseAuth
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      )
          .then((cred) async {
        if (cred.user == null) {
          throw Exception('Failed to create user.');
        }

        print("CHANGE USERNAME!");
        await cred.user!
            .updateDisplayName(username); // <<< tambah await di sini

        print("SET PHOTOURL ${file != null}");
        String photoUrl = file != null
            ? await FireStorage()
                .uploadImageToStorage('profilePics', file, false)
            : 'https://i.stack.imgur.com/l60Hf.png';

        print("CREATED UID: ${cred.user!.uid}");

        model.User user = model.User(
          username: username,
          uid: cred.user!.uid,
          sex: sex,
          photoUrl: photoUrl,
          email: email,
          bio: '',
          bookmarkedRecipes: [],
          followers: [],
          following: [],
          isDarkMode: true,
        );

        print("USER TO JSON: ${user.toJson()}");

        await _firestore
            .collection('users')
            .doc(cred.user!.uid)
            .set(user.toJson());
        print('User document successfully created!');
        return cred;
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        throw 'The account already exists for that email.';
      } else {
        throw 'Please check your email address.';
      }
    } catch (e, stacktrace) {
      print('Unexpected error during registration: $e');
      print(stacktrace);
      rethrow; // biar error asli tetap naik
    }
  }

  Future<void> googleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      await _firebaseAuth.signInWithCredential(credential);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> signinanonym() async {
    try {
      await _firebaseAuth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      throw Exception(e.toString());
    }
  }
}
