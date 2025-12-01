import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:dompetku/presentation/widgets/date_picker_calender.dart';
import 'package:dompetku/providers/transaction_provider.dart';

// --- DEFINISI WARNA ---
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

    // FILTER TRANSAKSI (Income / Expense)
    // TAMBAHAN: Filter berdasarkan tanggal jika ada yang dipilih
    final filteredTransactions = provider.transactions.where((t) {
      // Filter tipe (Income/Expense)
      bool typeMatch = false;
      if (selectedTab == 0) {
        typeMatch = t["type"] == "income";
      } else {
        // Tipe tidak 'income' dianggap 'expense' atau lainnya
        typeMatch = t["type"] != "income";
      }

      if (!typeMatch) return false;

      // Filter tanggal
      if (selectedDate == null) return true;

      // Asumsi data transaksi memiliki key 'date' string (cth: "01/12/2025")
      // atau 'timestamp' (Timestamp/DateTime) yang bisa dikonversi.
      // Karena item transaksi menggunakan 'date', kita akan pakai itu.
      final String transactionDateStr = t['date'] ?? '';
      if (transactionDateStr.isEmpty) return false;

      try {
        // Asumsi format 'dd/MM/yyyy' atau yang serupa,
        // Ini adalah contoh sederhana, mungkin perlu parsing yang lebih kuat
        final parts = transactionDateStr.split('/');
        if (parts.length != 3) return false;
        final int day = int.parse(parts[0]);
        final int month = int.parse(parts[1]);
        final int year = int.parse(parts[2]);

        return day == selectedDate!.day &&
            month == selectedDate!.month &&
            year == selectedDate!.year;
      } catch (_) {
        return false;
      }
    }).toList();

    // Urutkan transaksi berdasarkan tanggal, terbaru di atas
    filteredTransactions.sort((a, b) {
      // Jika ada 'timestamp' (seperti di kode pertama), itu lebih baik untuk sorting
      // Karena kita tidak melihat key 'timestamp' di sini, kita lewati sorting.
      // Jika Anda punya 'timestamp' (seperti Timestamp dari Firebase), ganti baris ini:
      /*
      final ta = a['timestamp'];
      final tb = b['timestamp'];
      if (ta == null || tb == null) return 0;
      return (tb as Timestamp).toDate().compareTo((ta as Timestamp).toDate());
      */
      return 0; // Tidak diurutkan jika hanya punya key 'date' string
    });


    final double statusBarHeight = MediaQuery.of(context).padding.top;
    const double tabHeight = 70;
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
          // ================= HEADER BIRU =================
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

                    // ===== TOTAL BALANCE DARI FIREBASE =====
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

          // ================= BODY PUTIH =================
          Positioned.fill(
            top: bodyWhiteTopPosition,
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
                      // Teks History
                      Text(
                        'History',
                        style: GoogleFonts.poppins(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      // Icon Kalender
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
                            "Tanggal Filter: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Tombol clear filter tanggal
                          GestureDetector(
                            onTap: () => setState(() => selectedDate = null),
                            child: const Icon(Icons.close,
                                size: 18, color: Colors.red),
                          )
                        ],
                      ),
                    ),

                  // ============= LIST TRANSAKSI =============
                  Expanded(
                    child: filteredTransactions.isEmpty
                        ? Center(
                      child: Text(
                        "Belum ada transaksi di tab ini${selectedDate != null ? ' pada tanggal ini' : ''}",
                        style: GoogleFonts.poppins(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600),
                      ),
                    )
                        : ListView.builder(
                      itemCount: filteredTransactions.length,
                      itemBuilder: (context, index) {
                        final t = filteredTransactions[index];
                        return _transactionItem(t, provider);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ================= TAB FLOATING =================
          Positioned(
            top: statusBarHeight + tabTopPosition,
            left: 20,
            right: 20,
            child: Row(
              children: [
                Expanded(
                    child: _buildTab(
                        0, "Income", Icons.arrow_outward_rounded)),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildTab(
                        1, "Expense", Icons.south_west_rounded)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ====================================================
  // ITEM TRANSAKSI (MODIFIED WITH ICON AND DATE)
  // ====================================================
  Widget _transactionItem(
      Map<String, dynamic> t, TransactionProvider provider) {
    final bool isIncome = t["type"] == "income";
    final double amount = (t["amount"] ?? 0).toDouble();
    final String description = t["description"] ?? "-";
    // Asumsi key 'date' ada di data, seperti yang dipakai di kode pertama.
    final String date = t["date"] ?? '-';

    // Pilihan ikon sederhana (mengikuti kode pertama)
    final IconData icon = isIncome ? Icons.attach_money : Icons.shopping_bag;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
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
          // CONTAINER ICON
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: kPrimaryColor),
          ),
          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // NAMA / DESKRIPSI
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // TANGGAL
                Text(date,
                    style: GoogleFonts.poppins(
                        color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),

          // JUMLAH
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

  // ====================================================
  // TAB
  // ====================================================
  Widget _buildTab(int index, String title, IconData icon) {
    bool active = selectedTab == index;

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