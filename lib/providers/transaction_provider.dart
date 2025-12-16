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
  // LIST TRANSACTIONS (REALTIME) - KHUSUS TRANSAKSI (BUKAN GOAL PROGRESS)
  // ===============================
  List<Map<String, dynamic>> transactions = [];

  TransactionProvider() {
    loadTransactions();
  }

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
      // FILTER: buang goal_progress dari list transaksi
      transactions = snapshot.docs
          .map((doc) => {
        "id": doc.id,
        ...doc.data() as Map<String, dynamic>,
      })
          .where((t) => t["type"] != "goal_progress" && t["isGoals"] != true)
          .toList();

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
  // TOTAL BALANCE (HANYA TRANSAKSI)
  // ===============================
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

  // ===============================
  // TOTAL INCOME (HANYA TRANSAKSI)
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

  // UNIVERSAL TOTAL BY CATEGORY
  double totalForCategory(String category, bool isIncome) {
    return isIncome
        ? totalIncomeForCategory(category)
        : totalExpenseForCategory(category);
  }

  // ===============================
  // SAVE (TRANSACTION / GOAL PROGRESS)
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

    // Parsing amount: aman buat "10.000", "10,000", "10000"
    final cleaned = amountString.replaceAll(RegExp(r'[^0-9]'), '');
    final double amount = double.tryParse(cleaned) ?? 0;

    if (amount <= 0) {
      _setSaving(false);
      return "Amount tidak valid.";
    }

    final bool isGoals = category["isGoals"] == true;
    final bool isIncome = category["isIncome"] == true;

    // Tentukan type
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
      // =========================
      // CASE 1: GOAL PROGRESS -> SIMPAN KE goals/{goalId}/progress
      // =========================
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
          // ga perlu isIncome/isGoals kalau kamu mau lebih clean, tapi boleh tetap simpan
          ...data,
          "type": "goal_progress",
        });

        _setSaving(false);
        return null;
      }

      // =========================
      // CASE 2: TRANSAKSI BIASA -> SIMPAN KE transactions
      // =========================
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
