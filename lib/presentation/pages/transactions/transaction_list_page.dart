import 'package:flutter/material.dart';
import 'package:dompetku/presentation/widgets/delete_confirmation_dialog.dart';
import 'package:dompetku/presentation/pages/transactions/add_transaction_page.dart';

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
    const Color backgroundColor = Color(0xFFf5f5f5);

    // Dummy Data Transaksi (dapat disesuaikan berdasarkan categoryName dan isIncome)
    final List<Map<String, dynamic>> transactions = isIncome
        ? [{'name': 'Gaji', 'date': '7 October 2025', 'amount': '10.000.000', 'isIncome': true}]
        : [{'name': 'Makan Siang', 'date': '7 October 2025', 'amount': '50.000', 'isIncome': false}];

    return Scaffold(
      backgroundColor: primaryColor,
      body: Column(
        children: [
          _HeaderSection(primaryColor: primaryColor, title: categoryName, isIncome: isIncome),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                children: [
                  // Filter Bulan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'October',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      IconButton(
                        onPressed: () {
                          // TODO: Implementasi date picker/filter
                        },
                        icon: const Icon(Icons.calendar_month, color: primaryColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Daftar Transaksi
                  ...transactions.map((t) => _TransactionItem(
                    name: t['name'],
                    date: t['date'],
                    amount: t['amount'],
                    isIncome: t['isIncome'],
                    primaryColor: primaryColor,
                    onDelete: () => _showDeleteConfirmation(context),
                  )).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        color: secondaryColor,
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddTransactionPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Add',
              style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  // Fungsi untuk menampilkan dialog konfirmasi
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const DeleteConfirmationDialog();
      },
    );
  }
}


// Widget Header di bagian atas
class _HeaderSection extends StatelessWidget {
  final Color primaryColor;
  final String title;
  final bool isIncome;

  const _HeaderSection({required this.primaryColor, required this.title, required this.isIncome});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 40,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: primaryColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Tombol Back & Title
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 20),
          // Total Balance
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isIncome ? Icons.account_balance_wallet : Icons.money_off,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  isIncome ? 'Total Balance' : 'Total Expense',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          const Text(
            'Rp.10.000.000',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget Item Transaksi
class _TransactionItem extends StatelessWidget {
  final String name;
  final String date;
  final String amount;
  final bool isIncome;
  final Color primaryColor;
  final VoidCallback onDelete;

  const _TransactionItem({
    required this.name,
    required this.date,
    required this.amount,
    required this.isIncome,
    required this.primaryColor,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Ikon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isIncome ? Icons.attach_money : Icons.shopping_bag,
                color: primaryColor,
              ),
            ),
            const SizedBox(width: 15),
            // Detail Transaksi
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    date,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            // Jumlah & Tombol Delete
            Text(
              (isIncome ? '+' : '-') + amount,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isIncome ? primaryColor : Colors.red,
              ),
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}