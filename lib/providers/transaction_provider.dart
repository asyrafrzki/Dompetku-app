import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TransactionProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  void _setSaving(bool value) {
    _isSaving = value;
    notifyListeners();
  }

  List<Map<String, dynamic>> transactions = [];

  TransactionProvider() {
    loadTransactions();
  }

  void loadTransactions() {
    final user = _auth.currentUser;
    if (user == null) return;
//ambil data dari firestore
    _firestore
        .collection("users")
        .doc(user.uid)
        .collection("transactions")
        .orderBy("timestamp", descending: true)
        .snapshots()
        .listen((snapshot) {
      transactions = snapshot.docs
          .map((doc) => {
        "id": doc.id,
        ...doc.data() as Map<String, dynamic>,
      })
          .where((t) => t["type"] != "goal_progress" && t["isGoals"] != true) //bukan goals
          .toList();

      notifyListeners();
    });
  }

  String formatCurrency(double number) {
    final formatter = NumberFormat.currency(
      locale: "id_ID",
      symbol: "Rp ",
      decimalDigits: 0,
    );
    return formatter.format(number);
  }

  double get totalBalance {
    double sum = 0;
    for (var t in transactions) {
      final double amount = (t['amount'] ?? 0).toDouble();
      if (t['type'] == 'income') {
        sum += amount;
      } else {
        sum -= amount;
      }
    }
    return sum;
  }

  double get totalIncome {
    double sum = 0;
    for (var t in transactions) {
      if (t['type'] == 'income') {
        sum += (t['amount'] ?? 0).toDouble();
      }
    }
    return sum;
  }

  double totalExpenseForCategory(String category) {
    double sum = 0;
    for (var t in transactions) {
      if (t['categoryName'] == category && t['type'] != 'income') {
        sum += (t['amount'] ?? 0).toDouble();
      }
    }
    return sum;
  }

  double totalIncomeForCategory(String category) {
    double sum = 0;
    for (var t in transactions) {
      if (t['categoryName'] == category && t['type'] == 'income') {
        sum += (t['amount'] ?? 0).toDouble();
      }
    }
    return sum;
  }

  double totalForCategory(String category, bool isIncome) {
    return isIncome
        ? totalIncomeForCategory(category)
        : totalExpenseForCategory(category);
  }

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
    final cleaned = amountString.replaceAll(RegExp(r'[^0-9]'), '');
    final double amount = double.tryParse(cleaned) ?? 0;

    if (amount <= 0) {
      _setSaving(false);
      return "Amount tidak valid.";
    }

    final bool isGoals = category["isGoals"] == true;
    final bool isIncome = category["isIncome"] == true;
    String transactionType = "expense";
    if (isGoals) {
      transactionType = "goal_progress";
    } else if (isIncome) {
      transactionType = "income";
    }

    final data = {
      'userId': user.uid,
      'date': date,
      'amount': amount,
      'description': description.trim(),
      'categoryName': category["name"],
      'isIncome': isIncome,
      'isGoals': isGoals,
      'type': transactionType,
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      if (isGoals) {
        if (goalId == null || goalId.trim().isEmpty) {
          _setSaving(false);
          return "goalId wajib diisi untuk progress goals.";
        }

        await _firestore
            .collection("users")
            .doc(user.uid)
            .collection("goals")
            .doc(goalId)
            .collection("progress")
            .add({
          ...data,
          "type": "goal_progress",
        });

        _setSaving(false);
        return null;
      }
      await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("transactions")
          .add(data);

      _setSaving(false);
      return null;
    } catch (e) {
      _setSaving(false);
      return "Terjadi kesalahan: $e";
    }
  }
}
