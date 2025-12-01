import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'package:dompetku/presentation/pages/notification/notification_page.dart';
import 'package:dompetku/presentation/widgets/time_frame_button.dart';

// --- DEFINISI WARNA ---
const Color kPrimaryColor = Color(0xFF07BEB8);
const Color kLightBackgroundColor = Color(0xFFF8FFF2);

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  int _selectedTab = 0;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // Variabel untuk menyimpan Total Income dan Expense yang difilter
  double _totalIncomeFiltered = 0.0;
  double _totalExpenseFiltered = 0.0;

  // ====================================================
  // 1. LOGIKA WAKTU
  // ====================================================

  Map<String, DateTime> _getTimeFrame() {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate;

    switch (_selectedTab) {
      case 0: // Daily
        startDate = DateTime(now.year, now.month, now.day);
        endDate = startDate.add(const Duration(days: 1));
        break;
      case 1: // Weekly (Senin - Minggu)
        final daysToSubtract = now.weekday - 1;
        startDate = DateTime(now.year, now.month, now.day).subtract(Duration(days: daysToSubtract));
        endDate = startDate.add(const Duration(days: 7));
        break;
      case 2: // Monthly
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 1);
        break;
      default:
        startDate = DateTime(now.year, 1, 1);
        endDate = DateTime(now.year + 1, 1, 1);
    }
    return {'start': startDate, 'end': endDate};
  }

  // ====================================================
  // 2. LOGIKA DATABASE FIREBASE
  // ====================================================

  Stream<QuerySnapshot> _getTransactionStream() {
    if (_currentUser == null) {
      return const Stream.empty();
    }

    final timeFrame = _getTimeFrame();
    final startTimestamp = timeFrame['start'];
    final endTimestamp = timeFrame['end'];

    return FirebaseFirestore.instance
        .collection("users")
        .doc(_currentUser!.uid)
        .collection("transactions")
        .where('timestamp', isGreaterThanOrEqualTo: startTimestamp)
        .where('timestamp', isLessThan: endTimestamp)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // ====================================================
  // 3. WIDGET UTAMA
  // ====================================================

  @override
  Widget build(BuildContext context) {
    final String userName = _currentUser?.displayName ?? _currentUser?.email ?? "User";
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    final bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    // Tinggi Bottom Navigation Bar (asumsi 56.0) + padding bottom safe area
    const double bottomNavBarDefaultHeight = 56.0;
    final double bottomSafePadding = MediaQuery.of(context).padding.bottom;

    // =========================================================
    // WIDGET KONTEN PUTIH (dipisahkan agar mudah digunakan)
    // =========================================================
    Widget whiteContent(double bottomPadding) {
      return Container(
        color: kLightBackgroundColor,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, 20, 24, bottomPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 45),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Transactions",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // TAB (Daily, Weekly, Monthly)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TimeFrameButton(
                      text: "Daily",
                      selected: _selectedTab == 0,
                      onTap: () {
                        setState(() {
                          _selectedTab = 0;
                        });
                      },
                    ),
                    TimeFrameButton(
                      text: "Weekly",
                      selected: _selectedTab == 1,
                      onTap: () {
                        setState(() {
                          _selectedTab = 1;
                        });
                      },
                    ),
                    TimeFrameButton(
                      text: "Monthly",
                      selected: _selectedTab == 2,
                      onTap: () {
                        setState(() {
                          _selectedTab = 2;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // LIST TRANSAKSI
              StreamBuilder<QuerySnapshot>(
                stream: _getTransactionStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  final transactions = snapshot.data?.docs ?? [];

                  // LOGIKA PENGHITUNGAN TOTAL BARU
                  double currentIncome = 0.0;
                  double currentExpense = 0.0;

                  for (var doc in transactions) {
                    final data = doc.data() as Map<String, dynamic>;
                    final double amount = (data['amount'] ?? 0).toDouble();
                    final String type = data['type'] ?? '';

                    if (type == 'income') {
                      currentIncome += amount;
                    } else {
                      currentExpense += amount;
                    }
                  }

                  // Update state Total Income/Expense
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_totalIncomeFiltered != currentIncome || _totalExpenseFiltered != currentExpense) {
                      setState(() {
                        _totalIncomeFiltered = currentIncome;
                        _totalExpenseFiltered = currentExpense;
                      });
                    }
                  });

                  if (transactions.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Text("Belum ada transaksi di periode ini."),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final data = transactions[index].data() as Map<String, dynamic>;
                      return _TransactionListItem(
                        data: data,
                        primaryColor: kPrimaryColor,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      );
    }

    // =========================================================
    // WIDGET HEADER BIRU (dipisahkan agar mudah digunakan)
    // =========================================================
    Widget blueHeader(double topPadding, double bottomPadding) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(28, topPadding, 28, bottomPadding),
        decoration: const BoxDecoration(
          color: kPrimaryColor,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(45),
            bottomRight: Radius.circular(45),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Hi, $userName",
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NotificationPage()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFC4FFF9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.notifications_none, size: 28),
                  ),
                )
              ],
            ),
            const SizedBox(height: 25),
            _IncomeExpenseCard(
              totalIncome: _totalIncomeFiltered,
              totalExpense: _totalExpenseFiltered,
            ),
          ],
        ),
      );
    }


    // =========================================================
    // 4. PEMILIHAN LAYOUT BERDASARKAN ORIENTASI
    // =========================================================

    if (isLandscape) {
      // === LAYOUT LANDSCAPE: SingleChildScrollView menyeluruh ===
      return SingleChildScrollView(
        child: Column(
          children: [
            // Perbaikan 2 (Landscape): Top Padding hanya 5. Lebih rapat ke atas.
            blueHeader(5, 0),

            // Jarak Vertikal yang nyaman antara Header dan konten putih (bisa 0 jika ingin mepet)
            const SizedBox(height: 20),

            // Konten Putih dengan padding bawah ekstra
            whiteContent(bottomNavBarDefaultHeight + bottomSafePadding + 20),
          ],
        ),
      );
    }

    // === LAYOUT PORTRAIT (FINAL) ===
    // Perbaikan 1 (Portrait): Hapus SafeArea di sini agar Header Biru mengisi penuh area status bar
    return Column(
      children: [
        // Top Padding: statusBarHeight + 10 (Agar Header Biru menutupi seluruh status bar dan ada padding ke bawah)
        // Bottom Padding: 25 (Dikurangi dari 40 agar kartu Income/Expense naik sedikit)
        blueHeader(statusBarHeight + 10, 25),

        Expanded(
            child: whiteContent(100)
        ),
      ],
    );
  }
}

// ====================================================
// WIDGET ITEM TRANSAKSI
// ====================================================
class _TransactionListItem extends StatelessWidget {
  final Map<String, dynamic> data;
  final Color primaryColor;

  const _TransactionListItem({required this.data, required this.primaryColor});

  String formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final bool isIncome = data['type'] == 'income';
    final double amount = (data['amount'] ?? 0).toDouble();
    final String description = data['description'] ?? data['categoryName'] ?? '-';
    final Timestamp timestamp = data['timestamp'] as Timestamp;
    final DateTime date = timestamp.toDate();

    final String formattedAmount = formatCurrency(amount);
    final String formattedDate = DateFormat('dd MMM').format(date);
    final IconData icon = isIncome ? Icons.attach_money : Icons.shopping_bag;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
              child: Icon(icon, color: primaryColor),
            ),
            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(description,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, fontSize: 16)),
                  Text(formattedDate,
                      style: GoogleFonts.poppins(
                          color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),

            Text(
              (isIncome ? "+" : "-") + formattedAmount,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isIncome ? primaryColor : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ====================================================
// WIDGET INCOME EXPENSE CARD (CUSTOM)
// ====================================================

class _IncomeExpenseCard extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;

  const _IncomeExpenseCard({
    required this.totalIncome,
    required this.totalExpense,
  });

  String formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Income
          _buildPill(
            icon: Icons.arrow_upward,
            label: "Income",
            amount: formatCurrency(totalIncome),
            color: kPrimaryColor,
          ),
          // Separator
          Container(
            height: 50,
            width: 1,
            color: Colors.grey[300],
          ),
          // Expense
          _buildPill(
            icon: Icons.arrow_downward,
            label: "Expense",
            amount: formatCurrency(totalExpense),
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildPill({
    required IconData icon,
    required String label,
    required String amount,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          amount,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}