import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dompetku/presentation/pages/analytics/analytics_page.dart';
import 'package:dompetku/presentation/pages/transactions/transaction_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

final List<Widget> _pages = [
  const DashboardContent(),
  const AnalyticsPage(),
  const TransactionsPage(), 
  Center(child: Text("Categories Page")),
  Center(child: Text("Profile Page")),
];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF0EA5E9),
        unselectedItemColor: Colors.grey[400],
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Analytics"),
          BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: "Transactions"),
          BottomNavigationBarItem(icon: Icon(Icons.layers), label: "Categories"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

// 🔹 Dashboard Content dipisah biar rapih
class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String userName = user?.displayName ?? user?.email ?? "User";

    // Dummy data
    double totalBalance = 7783.00;
    double totalExpense = -1187.40;
    double progressValue = 0.45;
    double savingsGoal = 5000.00;
    double savingsCurrent = 1500.00;
    double savingsProgress = savingsCurrent / savingsGoal;

    final List<Map<String, dynamic>> transactions = const [
      {
        "title": "Salary",
        "date": "18:27 - April 30",
        "category": "Monthly",
        "amount": 4000.00,
        "isExpense": false,
        "icon": Icons.attach_money,
        "iconColor": Colors.white,
        "circleColor": Color(0xFF0EA5E9),
      },
      {
        "title": "Groceries",
        "date": "17:00 - April 24",
        "category": "Pantry",
        "amount": -100.00,
        "isExpense": true,
        "icon": Icons.shopping_bag,
        "iconColor": Colors.white,
        "circleColor": Color(0xFF38BDF8),
      },
      {
        "title": "Rent",
        "date": "08:30 - April 15",
        "category": "Rent",
        "amount": -674.40,
        "isExpense": true,
        "icon": Icons.key,
        "iconColor": Colors.white,
        "circleColor": Color(0xFF0284C7),
      },
    ];

    return Column(
      children: [
        // 🔹 Header
        Container(
          padding: const EdgeInsets.fromLTRB(28, 60, 28, 20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF38BDF8), Color(0xFF0EA5E9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Header user
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hi, Welcome Back",
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        userName,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none,
                        color: Colors.white, size: 30),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // 🔹 Kartu Ringkasan
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildBalanceCard(
                              "Total Balance", totalBalance, false),
                          _buildBalanceCard(
                              "Total Expense", totalExpense, true),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progressValue,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF0EA5E9)),
                          minHeight: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${(progressValue * 100).toStringAsFixed(0)}% of Your Expenses, Keep it up!",
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // 🔹 Konten scrollable
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Bagian "Savings On Goals"
                _buildSavingsCard(
                    savingsCurrent, savingsGoal, savingsProgress),
                const SizedBox(height: 30),
                // Daftar Transaksi
                Text(
                  "Transactions",
                  style: GoogleFonts.poppins(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTab("Daily", false),
                    _buildTab("Weekly", false),
                    _buildTab("Monthly", true),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTransactionList(transactions),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 🔹 Widget untuk Kartu Ringkasan
  Widget _buildBalanceCard(String title, double amount, bool isExpense) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          "${isExpense ? '-' : ''}Rp${amount.abs().toStringAsFixed(2)}",
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isExpense ? Colors.red : Colors.green,
          ),
        ),
      ],
    );
  }

  // 🔹 Widget untuk Savings Card
  Widget _buildSavingsCard(double current, double goal, double progress) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF06B6D4), Color(0xFF2563EB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: const Icon(Icons.savings,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Savings Goal",
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(
                      "Rp${current.toStringAsFixed(2)} / Rp${goal.toStringAsFixed(2)}",
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 60,
              width: 60,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 6,
                    backgroundColor: Colors.white24,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  Center(
                    child: Text(
                      "${(progress * 100).toStringAsFixed(0)}%",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Widget untuk Daftar Transaksi
  Widget _buildTransactionList(List<Map<String, dynamic>> transactions) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: transaction["circleColor"],
            child: Icon(transaction["icon"] as IconData,
                color: transaction["iconColor"]),
          ),
          title: Text(
            transaction["title"],
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            "${transaction["date"]} • ${transaction["category"]}",
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
          trailing: Text(
            "${transaction["isExpense"] ? '-' : ''}Rp${transaction["amount"].abs().toStringAsFixed(2)}",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: transaction["isExpense"] ? Colors.red : Colors.green,
            ),
          ),
        );
      },
    );
  }

  // 🔹 Widget untuk tab transaksi
  Widget _buildTab(String text, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF0EA5E9) : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: selected ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
