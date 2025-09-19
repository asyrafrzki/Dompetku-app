import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({Key? key}) : super(key: key);

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final double totalBalance = 7783.00;
  final double totalExpense = 1187.40;
  final double target = 20000.00;

  final List<Map<String, dynamic>> dummyTransactions = const [
    {
      "title": "Salary",
      "date": "18:27 - April 30",
      "category": "Monthly",
      "amount": 4000.00,
      "isExpense": false,
      "icon": Icons.work,
    },
    {
      "title": "Groceries",
      "date": "17:00 - April 24",
      "category": "Pantry",
      "amount": -100.00,
      "isExpense": true,
      "icon": Icons.shopping_bag,
    },
    {
      "title": "Rent",
      "date": "08:30 - April 15",
      "category": "Rent",
      "amount": -674.40,
      "isExpense": true,
      "icon": Icons.home,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D47A1), 
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                  Text(
                    "Transaction",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const Icon(Icons.notifications_none,
                      color: Colors.white, size: 28),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white30, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "Total Balance",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1565C0),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "\$${totalBalance.toStringAsFixed(2)}",
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0D47A1),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _buildInfoBox(
                      "Total Balance", "\$${totalBalance.toStringAsFixed(2)}", Colors.white),
                ),
                Container(
                  height: 35,
                  width: 2,
                  color: Colors.white.withOpacity(0.4),
                ),
                Expanded(
                  child: _buildInfoBox("Total Expense",
                      "-\$${totalExpense.toStringAsFixed(2)}", Colors.white),
                ),
              ],
            ),

            const SizedBox(height: 20),
            
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: ListView(
                  children: [
                    Text(
                      "April",
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ...dummyTransactions
                        .map((tx) => _buildTransactionItem(tx))
                        .toList(),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: color.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> tx) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF1565C0), 
          child: Icon(tx["icon"], color: Colors.white),
        ),
        title: Text(
          tx["title"],
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          "${tx["date"]} • ${tx["category"]}",
          style: GoogleFonts.poppins(color: Colors.grey),
        ),
        trailing: Text(
          "${tx["isExpense"] ? '-' : '+'}\$${tx["amount"].abs().toStringAsFixed(2)}",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: tx["isExpense"] ? Colors.red : Colors.green,
          ),
        ),
      ),
    );
  }
}