import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  void _setSaving(bool value) {
    _isSaving = value;
    notifyListeners();
  }

  // ===============================
  // LIST TRANSACTIONS (REALTIME)
  // ===============================
  List<Map<String, dynamic>> transactions = [];

  TransactionProvider() {
    loadTransactions();
  }

  // LOAD DATA dari Firebase
  void loadTransactions() {
    final user = _auth.currentUser;

    if (user == null) return;

    _firestore
        .collection("users")
        .doc(user.uid)
        .collection("transactions")
        .orderBy("timestamp", descending: true)
        .snapshots()
        .listen((snapshot) {
      transactions = snapshot.docs.map((doc) {
        return {
          "id": doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();

      notifyListeners();
    });
  }

  // ===============================
  // SAVE TRANSACTION
  // ===============================
  Future<String?> saveTransaction({
    required String date,
    required String amountString,
    required String description,
    required Map<String, dynamic> category,
    String? goalId,
  }) async {
    _setSaving(true);

    final user = _auth.currentUser;
    if (user == null) {
      _setSaving(false);
      return "Pengguna tidak terautentikasi.";
    }

    final double amount =
        double.tryParse(amountString.replaceAll(",", ".")) ?? 0;

    // ====== TYPE LOGIC ======
    String transactionType = "expense"; // default

    if (category["isGoals"] == true) {
      transactionType = "goal_progress";
    } else if (category["isIncome"] == true) {
      transactionType = "income";
    }

    final data = {
      'userId': user.uid,
      'date': date,
      'amount': amount,
      'description': description.trim(),
      'categoryName': category["name"],
      'isIncome': category["isIncome"],
      'isGoals': category["isGoals"],
      'type': transactionType,
      'timestamp': FieldValue.serverTimestamp(),
    };

    if (goalId != null) {
      data['goalId'] = goalId;
    }

    try {
      await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("transactions")
          .add(data);

      _setSaving(false);
      return null;
    } on FirebaseException catch (e) {
      _setSaving(false);
      return e.message;
    } catch (e) {
      _setSaving(false);
      return "Terjadi kesalahan: $e";
    }
  }
}
