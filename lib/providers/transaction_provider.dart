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
  // FORMAT CURRENCY
  // ===============================
  String formatCurrency(double number) {
    final formatter = NumberFormat.currency(
      locale: "id_ID",
      symbol: "Rp ",
      decimalDigits: 0,
    );
    return formatter.format(number);
  }

  // ===============================
  // TOTAL BALANCE
  // ===============================
  double get totalBalance {
    double sum = 0;
    for (var t in transactions) {
      double amount = (t['amount'] ?? 0).toDouble();
      if (t['type'] == 'income') {
        sum += amount;
      } else {
        sum -= amount;
      }
    }
    return sum;
  }

  // ===============================
  // TOTAL INCOME
  // ===============================
  double get totalIncome {
    double sum = 0;
    for (var t in transactions) {
      if (t['type'] == 'income') {
        sum += (t['amount'] ?? 0).toDouble();
      }
    }
    return sum;
  }

  // ===============================
  // TOTAL EXPENSE BY CATEGORY
  // ===============================
  double totalExpenseForCategory(String category) {
    double sum = 0;
    for (var t in transactions) {
      if (t['categoryName'] == category && t['type'] != 'income') {
        sum += (t['amount'] ?? 0).toDouble();
      }
    }
    return sum;
  }

  // ===============================
  // TOTAL INCOME BY CATEGORY
  // ===============================
  double totalIncomeForCategory(String category) {
    double sum = 0;
    for (var t in transactions) {
      if (t['categoryName'] == category && t['type'] == 'income') {
        sum += (t['amount'] ?? 0).toDouble();
      }
    }
    return sum;
  }

  // ===============================
  // UNIVERSAL: TOTAL BY CATEGORY
  // dipakai UI kamu: provider.totalForCategory(title, isIncome)
  // ===============================
  double totalForCategory(String category, bool isIncome) {
    if (isIncome) {
      return totalIncomeForCategory(category);
    } else {
      return totalExpenseForCategory(category);
    }
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

    if (goalId != null) data['goalId'] = goalId;

    try {
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
