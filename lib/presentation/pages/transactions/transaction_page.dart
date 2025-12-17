import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // <<< PASTIKAN INI DIIMPOR
// Asumsi path ini benar. Jika tidak, sesuaikan.
import 'package:dompetku/presentation/widgets/date_picker_calender.dart';
// Asumsi path ini benar. Jika tidak, sesuaikan.
import 'package:dompetku/providers/transaction_provider.dart';

//warna
const Color kPrimaryColor = Color(0xFF07BEB8);
const Color kLightBackgroundColor = Color(0xFFF8FFF2);
const Color kActiveButtonColor = Color(0xFF1565C0);

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({Key? key}) : super(key: key);

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  int selectedTab = 0; // 0 = income, 1 = expense
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final filteredTransactions = provider.transactions.where((t) {
      bool typeMatch =
      selectedTab == 0 ? t["type"] == "income" : t["type"] != "income";

      if (!typeMatch) return false;
      if (selectedDate == null) return true;
      final String dateStr = t["date"] ?? "";
      if (dateStr.isEmpty) return false;

      try {

        // menggunakan DateFormat untuk mem-parsing string tanggal dari Firestore.
        final DateFormat firestoreDateFormat = DateFormat('dd-MM-yyyy');
        final DateTime transactionDate = firestoreDateFormat.parse(dateStr);

        // Bandingkan hanya komponen hari, bulan, dan tahun.
        return (selectedDate!.day == transactionDate.day &&
            selectedDate!.month == transactionDate.month &&
            selectedDate!.year == transactionDate.year);

      } catch (e) {
        // Jika parsing gagal (misalnya, format di Firestore tidak konsisten),
        return false;
      }
    }).toList();

    final double statusBarHeight = MediaQuery.of(context).padding.top;

    if (isLandscape) {
      return Scaffold(
        backgroundColor: kLightBackgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                  color: kPrimaryColor,
                  child: Column(
                    children: [
                      Text(
                        "Transaction",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // TOTAL BALANCE
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            provider.formatCurrency(provider.totalBalance),
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(child: _buildTab(0, "Income", Icons.arrow_outward_rounded)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTab(1, "Expense", Icons.south_west_rounded)),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                  decoration: const BoxDecoration(
                    color: kLightBackgroundColor,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'History',
                            style: GoogleFonts.poppins(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final result = await showDialog(
                                context: context,
                                builder: (_) => const DatePickerCalendar(),
                              );

                              if (result != null && result is DateTime) {
                                setState(() => selectedDate = result);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.calendar_month,
                                color: kActiveButtonColor,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      if (selectedDate != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Tanggal: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                              style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () =>
                                  setState(() => selectedDate = null),
                              child: const Icon(
                                Icons.close,
                                size: 18,
                                color: Colors.red,
                              ),
                            )
                          ],
                        ),

                      const SizedBox(height: 20),

                      if (filteredTransactions.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 40.0),
                            child: Text(
                              "Belum ada transaksi di tab ini${selectedDate != null ? ' pada tanggal ini' : ''}",
                              style: GoogleFonts.poppins(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredTransactions.length,
                          itemBuilder: (context, index) {
                            return _transactionItem(
                                filteredTransactions[index], provider);
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final double tabHeight = 70;
    const double tabTopPosition = 180;
    const double verticalGap = 60;

    final double bodyWhiteTopPosition =
        statusBarHeight + tabTopPosition + tabHeight + verticalGap - 30;

    final double headerBottomPadding =
        tabTopPosition + (tabHeight / 2) - 20;

    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                    20, statusBarHeight + 20, 20, headerBottomPadding),
                color: kPrimaryColor,
                child: Column(
                  children: [
                    Text(
                      "Transaction",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          provider.formatCurrency(provider.totalBalance),
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: Container(color: kLightBackgroundColor)),
            ],
          ),
          Positioned.fill(
            top: bodyWhiteTopPosition,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: kLightBackgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'History',
                          style: GoogleFonts.poppins(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        GestureDetector(
                          onTap: () async {
                            final result = await showDialog(
                              context: context,
                              builder: (_) => const DatePickerCalendar(),
                            );

                            if (result != null && result is DateTime) {
                              setState(() => selectedDate = result);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.calendar_month,
                              color: kActiveButtonColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    if (selectedDate != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Tanggal: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => setState(() => selectedDate = null),
                              child: const Icon(Icons.close,
                                  size: 18, color: Colors.red),
                            )
                          ],
                        ),
                      ),
                    filteredTransactions.isEmpty
                        ? Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                        child: Text(
                          "Belum ada transaksi di tab ini${selectedDate != null ? ' pada tanggal ini' : ''}",
                          style: GoogleFonts.poppins(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    )
                        : ListView.builder(
                      itemCount: filteredTransactions.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final t = filteredTransactions[index];
                        return _transactionItem(t, provider);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: statusBarHeight + tabTopPosition,
            left: 20,
            right: 20,
            child: Row(
              children: [
                Expanded(child: _buildTab(0, "Income", Icons.arrow_outward)),
                const SizedBox(width: 12),
                Expanded(child: _buildTab(1, "Expense", Icons.south_west)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _transactionItem(Map<String, dynamic> t, TransactionProvider provider) {
    final isIncome = t["type"] == "income";
    final double amount = (t["amount"] is int)
        ? (t["amount"] as int).toDouble()
        : (t["amount"] ?? 0.0).toDouble();

    final String description = t["description"] ?? "-";
    final String date = t["date"] ?? "-";
    String displayDate = date;
    try {
      final parsedDate = DateFormat('dd-MM-yyyy').parse(date);
      displayDate = DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (_) {
    }

    final IconData icon =
    isIncome ? Icons.attach_money : Icons.shopping_bag_outlined;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kLightBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: kLightBackgroundColor,
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: kPrimaryColor),
          ),
          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  displayDate,
                  style: GoogleFonts.poppins(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Text(
            (isIncome ? "+" : "-") + provider.formatCurrency(amount),
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isIncome ? kPrimaryColor : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String title, IconData icon) {
    final active = selectedTab == index;

    return GestureDetector(
      onTap: () => setState(() => selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: active ? kActiveButtonColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: active ? Colors.white : kActiveButtonColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: active ? Colors.white : kActiveButtonColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}