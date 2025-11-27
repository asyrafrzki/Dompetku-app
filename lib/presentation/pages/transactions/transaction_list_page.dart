import 'package:dompetku/presentation/pages/transactions/add_transaction_page.dart';
import 'package:dompetku/presentation/widgets/date_picker_calender.dart';
import 'package:dompetku/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionListPage extends StatelessWidget {
  final String categoryName;
  final bool isIncome;

  const TransactionListPage({
    super.key,
    required this.categoryName,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF07BEB8);
    const Color secondaryColor = Color(0xFFF8FFF2);

    final provider = Provider.of<TransactionProvider>(context);
    final all = provider.transactions;

    List<Map<String, dynamic>> filtered = [];

    final bool isGoalsPage = categoryName == "Goals";
    final bool isIncomePage = categoryName == "Income" || isIncome == true;

    // ==================================
    // FILTER TRANSAKSI
    // ==================================
    if (isGoalsPage) {
      filtered =
          all.where((t) => t['type'] == 'goal_progress').toList();
    } else if (isIncomePage) {
      filtered = all.where((t) => t['type'] == 'income').toList();
    } else {
      filtered =
          all.where((t) => t['categoryName'] == categoryName).toList();
    }

    // sort by timestamp
    filtered.sort((a, b) {
      final ta = a['timestamp'];
      final tb = b['timestamp'];
      if (ta == null || tb == null) return 0;
      return (tb as Timestamp)
          .toDate()
          .compareTo((ta as Timestamp).toDate());
    });

    return Scaffold(
      backgroundColor: primaryColor,
      body: Column(
        children: [
          _HeaderSection(
            primaryColor: primaryColor,
            title: categoryName,
            isIncome: isIncome,
          ),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: ListView(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                children: [
                  if (!isGoalsPage)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'History',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: () async {
                            await showDialog(
                              context: context,
                              builder: (_) => const DatePickerCalendar(),
                            );
                          },
                          icon: const Icon(Icons.calendar_month,
                              color: primaryColor),
                        ),
                      ],
                    ),

                  const SizedBox(height: 10),

                  if (filtered.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Text(
                          "Belum ada transaksi",
                          style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),

                  ...filtered.map(
                        (t) {
                      final String id = t['id'] ?? '';
                      final String name = (t['description'] ??
                          t['categoryName'] ??
                          '-')
                          .toString();
                      final String date = (t['date'] ?? '-').toString();
                      final double amount =
                      (t['amount'] ?? 0).toDouble();
                      final bool income = t['type'] == 'income';

                      return _TransactionItem(
                        id: id,
                        name: name,
                        date: date,
                        amount: amount,
                        isIncome: income,
                        primaryColor: primaryColor,
                        onDelete: () => _confirmDelete(context, id),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // ==================================
      // TOMBOL ADD — LANGSUNG TERIMA CATEGORY
      // ==================================
      bottomNavigationBar: Container(
        padding:
        const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        color: secondaryColor,
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTransactionPage(
                    isGoals: isGoalsPage,
                    selectedCategoryName: categoryName, // <<< penting
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
            ),
            child: Text(
              isGoalsPage ? "Add Progress" : 'Add',
              style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("ID transaksi tidak ditemukan.")));
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Hapus transaksi"),
          content:
          const Text("Yakin ingin menghapus transaksi ini?"),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Batal")),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  final user = FirebaseAuth.instance.currentUser;
                  await FirebaseFirestore.instance
                      .collection("users")
                      .doc(user!.uid)
                      .collection("transactions")
                      .doc(id)
                      .delete();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Transaksi dihapus.")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text("Gagal hapus: $e")),
                  );
                }
              },
              child: const Text("Hapus",
                  style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

// =============================================
// HEADER
// =============================================
class _HeaderSection extends StatelessWidget {
  final Color primaryColor;
  final String title;
  final bool isIncome;

  const _HeaderSection({
    required this.primaryColor,
    required this.title,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);

    const Color secondaryColor = Color(0xFFF8FFF2);

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 40,
        left: 20,
        right: 20,
      ),
      color: primaryColor,
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context)),
              Expanded(
                child: Center(
                  child: Text(
                    title,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 20),

          // Goals tidak punya total uang
          title == "Goals"
              ? Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.circular(20)),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Progress History",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text("Riwayat progress goals ditampilkan di bawah."),
              ],
            ),
          )
              : Text(
            provider.formatCurrency(
                provider.totalForCategory(title, isIncome)),
            style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// =============================================
// ITEM TRANSAKSI
// =============================================
class _TransactionItem extends StatelessWidget {
  final String id;
  final String name;
  final String date;
  final double amount;
  final bool isIncome;
  final Color primaryColor;
  final VoidCallback onDelete;

  const _TransactionItem({
    required this.id,
    required this.name,
    required this.date,
    required this.amount,
    required this.isIncome,
    required this.primaryColor,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final provider =
    Provider.of<TransactionProvider>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(
                  isIncome
                      ? Icons.attach_money
                      : Icons.shopping_bag,
                  color: primaryColor),
            ),
            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(date,
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),

            Text(
              (isIncome ? "+" : "-") +
                  provider.formatCurrency(amount),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isIncome ? primaryColor : Colors.red,
              ),
            ),

            IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete, color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
