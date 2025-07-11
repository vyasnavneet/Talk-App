import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? getCurrentUser() => _auth.currentUser;

  Future<UserCredential> signUpWithEmailPassword(
    String email,
    String password,
    String uname,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      await _firestore.collection("Users").doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'uname': uname,
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<UserCredential> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<void> signOut() async => await _auth.signOut();

  Future<String> getUsername() async {
    User? user = getCurrentUser();
    if (user == null) throw Exception("No user is currently signed in.");

    try {
      DocumentSnapshot doc = await _firestore
          .collection('Users')
          .doc(user.uid)
          .get();
      if (!doc.exists) throw Exception("User document does not exist.");
      return doc['uname'] as String? ?? '';
    } on FirebaseException catch (e) {
      throw Exception("Failed to fetch username: ${e.message}");
    }
  }

  Future<void> changeUsername(String newUsername) async {
    User? user = getCurrentUser();
    if (user == null) throw Exception("No user is currently signed in.");

    try {
      await _firestore.collection('Users').doc(user.uid).update({
        'uname': newUsername,
      });
    } on FirebaseException catch (e) {
      throw Exception("Failed to update username: ${e.message}");
    }
  }

  Future<void> deleteAccount() async {
    User? user = getCurrentUser();
    if (user == null) return;

    String userId = user.uid;
    final groupsSnapshot = await _firestore
        .collection('groups')
        .where('memberIds', arrayContains: userId)
        .get();

    for (var groupDoc in groupsSnapshot.docs) {
      await _firestore.collection('groups').doc(groupDoc.id).update({
        'memberIds': FieldValue.arrayRemove([userId]),
      });

      final messagesSnapshot = await _firestore
          .collection('groups')
          .doc(groupDoc.id)
          .collection('messages')
          .where('senderID', isEqualTo: userId)
          .get();

      for (var messageDoc in messagesSnapshot.docs) {
        await messageDoc.reference.delete();
      }

      await _firestore
          .collection('Users')
          .doc(userId)
          .collection('Groups')
          .doc(groupDoc.id)
          .delete();
    }

    await deleteProfileImage();
    await _firestore.collection('Users').doc(userId).delete();
    await user.delete();
  }

  Future<String> uploadProfileImage(File imageFile) async {
    User? user = getCurrentUser();
    if (user == null) throw Exception("No user signed in.");

    try {
      final ref = FirebaseStorage.instance.ref().child(
        'profile_images/${user.uid}.jpg',
      );
      await ref.putFile(imageFile);
      String url = await ref.getDownloadURL();

      await _firestore.collection('Users').doc(user.uid).update({
        'profileImage': url,
      });

      return url;
    } catch (e) {
      throw Exception("Failed to upload profile image: $e");
    }
  }

  Future<void> updateProfilePhotoUrl(String url) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updatePhotoURL(url);
      await user.reload();
    }
  }

  Future<String?> getProfileImageURL() async {
    User? user = getCurrentUser();
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('Users').doc(user.uid).get();
      return doc['profileImage'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteProfileImage() async {
    User? user = getCurrentUser();
    if (user == null) throw Exception("No user is currently signed in.");

    final ref = FirebaseStorage.instance.ref().child(
      'profile_images/${user.uid}.jpg',
    );
    try {
      await ref.delete();
    } catch (_) {}

    await _firestore.collection('Users').doc(user.uid).update({
      'profileImage': FieldValue.delete(),
    });
  }
}
