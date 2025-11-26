import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _currentUserName = 'Loading...';
  bool _isLoading = false;

  // Getters
  String get currentUserName => _currentUserName;
  bool get isLoading => _isLoading;

  // Utility untuk update loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchProfileData() async {
    _setLoading(true);
    final user = _auth.currentUser;
    if (user == null) {
      _currentUserName = 'Not Logged In';
      _setLoading(false);
      return;
    }

    String nameFromAuth = user.displayName ?? user.email?.split('@')[0] ?? 'User';
    String nameFromFirestore = nameFromAuth;

    try {
      // Ambil data dari Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists && userDoc.data()!.containsKey('nama')) {
        nameFromFirestore = userDoc.data()!['nama'] ?? nameFromAuth;
      }
    } catch (e) {
      debugPrint("Error fetching profile data: $e");
    }

    _currentUserName = nameFromFirestore; // Set state Provider
    _setLoading(false);
  }
  Future<String?> updateUsername(String newName) async {
    _setLoading(true);
    final user = _auth.currentUser;
    if (user == null) {
      _setLoading(false);
      return "Pengguna tidak terautentikasi.";
    }

    try {
      await user.updateDisplayName(newName);
      await _firestore.collection('users').doc(user.uid).set(
        {'nama': newName},
        SetOptions(merge: true),
      );
      await user.reload();
      _currentUserName = newName;
      _setLoading(false);
      return null; // Sukses
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return e.message ?? "Kesalahan otentikasi Firebase.";
    } on FirebaseException catch (e) {
      _setLoading(false);
      return e.message ?? "Kesalahan database Firestore.";
    } catch (e) {
      _setLoading(false);
      return "Terjadi kesalahan: ${e.toString()}";
    }
  }
}