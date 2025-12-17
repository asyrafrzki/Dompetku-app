import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// --- DEFINISI WARNA ---
const Color kPrimaryColor = Color(0xFF07BEB8);
const Color kLightBackgroundColor = Color(0xFFF8FFF2);

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  // Mendapatkan stream transaksi dari Firestore
  Stream<QuerySnapshot> _getTransactionStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    // Mengambil 20 transaksi terbaru
    return FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("transactions")
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
                28, MediaQuery.of(context).padding.top + 10, 28, 20),
            color: kPrimaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    Icons.arrow_back,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Notification",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Icon(
                  Icons.notifications_none,
                  size: 28,
                  color: Colors.white,
                ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
              decoration: const BoxDecoration(
                color: kLightBackgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(45),
                  topRight: Radius.circular(45),
                ),
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: _getTransactionStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child:
                        CircularProgressIndicator(color: kPrimaryColor));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  final transactions = snapshot.data?.docs ?? [];

                  if (transactions.isEmpty) {
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 25),
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.circular(53),
                        ),
                        child: Text(
                          "NO TRANSACTION HISTORY YET",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  }

                  // Menampilkan daftar notifikasi (transaksi terbaru)
                  return ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final data =
                      transactions[index].data() as Map<String, dynamic>;
                      return _NotificationItem(
                        data: data,
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final Map<String, dynamic> data;

  const _NotificationItem({required this.data});

  String _formatCurrency(double amount) {
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
    final String categoryName = data['categoryName'] ?? '-';
    final Timestamp timestamp = data['timestamp'] as Timestamp;
    final DateTime date = timestamp.toDate();

    final String title;
    final String message;
    final Color color;
    final IconData icon;

    final String formattedAmount = _formatCurrency(amount);
    final String formattedTime = DateFormat('HH:mm').format(date);
    final String formattedDate = DateFormat('dd MMM').format(date);

    if (isIncome) {
      title = "Income Berhasil Ditambahkan";
      message = "Kamu mendapatkan $formattedAmount dari kategori **$categoryName**.";
      color = kPrimaryColor;
      icon = Icons.attach_money;
    } else {
      title = "Pengeluaran Tercatat";
      message = "Telah dicatat pengeluaran $formattedAmount untuk **$categoryName**.";
      color = Colors.red;
      icon = Icons.shopping_bag;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Notifikasi
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),

                // Message
                Text(
                  message,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),

                // Waktu dan Tanggal
                Text(
                  "$formattedTime - $formattedDate",
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}