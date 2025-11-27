import 'package:dompetku/presentation/pages/analytics/analytics_page.dart';
import 'package:flutter/material.dart';
import 'package:dompetku/presentation/widgets/delete_confirmation_dialog.dart';
import 'package:dompetku/presentation/pages/transactions/add_transaction_page.dart';
import 'package:dompetku/presentation/widgets/date_picker_calender.dart';
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

    // Dummy Data
    final List<Map<String, dynamic>> transactions = isIncome
        ? [
      {
        'name': 'Gaji',
        'date': '7 October 2025',
        'amount': '10.000.000',
        'isIncome': true
      }
    ]
        : [
      {
        'name': 'Makan Siang',
        'date': '7 October 2025',
        'amount': '50.000',
        'isIncome': false
      }
    ];

    // Dummy Goals (khusus kategori Goals)
    final List<Map<String, dynamic>> goals = [
      {
        'title': 'New Phone',
        'target': 5000000,
        'current': 1500000,
        'date': 'Dec 2025'
      },
      {
        'title': 'Gaming PC',
        'target': 12000000,
        'current': 3000000,
        'date': 'Jan 2026'
      },
    ];

    final bool isGoalsPage = categoryName == "Goals";

    return Scaffold(
      backgroundColor: primaryColor,
      body: Column(
        children: [
          _HeaderSection(
            primaryColor: primaryColor,
            title: categoryName,
            isIncome: isIncome,
          ),

          // ============================
          //      MODE KHUSUS GOALS
          // ============================
          // ============================
//      MODE KHUSUS GOALS
// ============================
          if (isGoalsPage)
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: secondaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: ListView(
                  children: [
                    const SizedBox(height: 5),

                    const Text(
                      "Progress History",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),

                    // LIST PROGRESS (sama seperti kategori biasa)
                    _TransactionItem(
                      name: "Top Up Salary",
                      date: "5 October 2025",
                      amount: "200.000",
                      isIncome: true,
                      primaryColor: primaryColor,
                      onDelete: () => _showDeleteConfirmation(context),
                    ),

                    _TransactionItem(
                      name: "Bonus",
                      date: "1 October 2025",
                      amount: "500.000",
                      isIncome: true,
                      primaryColor: primaryColor,
                      onDelete: () => _showDeleteConfirmation(context),
                    ),
                  ],
                ),
              ),
            ),


          // ============================
          //    MODE KATEGORI BIASA
          // ============================
          if (!isGoalsPage)
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
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'October',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                        IconButton(
                          onPressed: () async {
                            final selectedDate = await showDialog(
                              context: context,
                              builder: (_) => const DatePickerCalendar(),
                            );

                            if (selectedDate != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Selected: ${selectedDate.day}-${selectedDate.month}-${selectedDate.year}"),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.calendar_month, color: primaryColor),
                        ),

                      ],
                    ),
                    const SizedBox(height: 10),

                    ...transactions
                        .map(
                          (t) => _TransactionItem(
                        name: t['name'],
                        date: t['date'],
                        amount: t['amount'],
                        isIncome: t['isIncome'],
                        primaryColor: primaryColor,
                        onDelete: () => _showDeleteConfirmation(context),
                      ),
                    )
                        .toList(),
                  ],
                ),
              ),
            ),
        ],
      ),

      // Tombol Add tetap muncul untuk semua kategori
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
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
                    )),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
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

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const DeleteConfirmationDialog();
      },
    );
  }
}
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
                onPressed: () => Navigator.pop(context),
              ),
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
          title == "Goals"
              ? Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "New Phone",
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // Progress bar
                LinearProgressIndicator(
                  value: 1500000 / 5000000,
                  color: primaryColor,
                  backgroundColor: primaryColor.withOpacity(0.2),
                  minHeight: 10,
                ),

                const SizedBox(height: 10),
                Text(
                  "Rp 1.500.000 / Rp 5.000.000",
                  style: TextStyle(
                      color: primaryColor, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Deadline: Dec 2025",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          )

          // Jika kategori lain → tetap angka saldo
              : const Text(
            'Rp.10.000.000',
            style: TextStyle(
                fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
          ),

        ],
      ),
    );
  }
}

// ============================
//       LIST ITEM BIASA
// ============================
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(date,
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
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

// ============================
//       ITEM GOALS BARU
// ============================
class GoalItem extends StatelessWidget {
  final String title;
  final int target;
  final int current;
  final String date;
  final Color primaryColor;

  const GoalItem({
    super.key,
    required this.title,
    required this.target,
    required this.current,
    required this.date,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    double progress = current / target;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          // Circular progress
          SizedBox(
            width: 70,
            height: 70,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 7,
                  color: primaryColor,
                  backgroundColor: primaryColor.withOpacity(0.2),
                ),
                Text(
                  "${(progress * 100).toInt()}%",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),

          const SizedBox(width: 20),

          // Text info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Text(
                  "Deadline: $date",
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Text(
                  "Rp $current / Rp $target",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: primaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
