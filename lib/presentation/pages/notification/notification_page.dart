import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Atur warna latar belakang Scaffold menjadi warna Putih/Krem untuk bagian atas
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFF2),
      body: Column(
        children: [
          // ===================== HEADER NOTIFICATION (RATA DI BAWAH) ========================= //
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(28, 60, 28, 20),
            decoration: const BoxDecoration(
              color: Color(0xFF07BEB8),
              // TIDAK ADA RADIUS DI SINI. Biarkan rata.
            ),
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

          // =================== BODY NOTIFICATION (MELENGKUNG KE ATAS DAN SAMPING) ====================== //
          Expanded(
            child: Container(
              width: double.infinity,
              // Tambahkan margin horizontal agar radius di kiri dan kanan terlihat
              margin: const EdgeInsets.symmetric(horizontal: 20),

              decoration: const BoxDecoration(
                color: Color(0xFFF8FFF2), // Warna latar belakang putih/krem
                borderRadius: BorderRadius.only(
                  // Pertahankan radius besar di bagian atas agar Body putih melengkung ke atas
                  topLeft: Radius.circular(53),
                  topRight: Radius.circular(53),
                  // Tambahkan juga radius di bagian bawah jika Anda ingin terlihat seperti kartu
                  bottomLeft: Radius.circular(53),
                  bottomRight: Radius.circular(53),
                ),
                // Tambahkan shadow jika ingin terlihat lebih mengambang (opsional)
                // boxShadow: [
                //   BoxShadow(
                //     color: Colors.black12,
                //     blurRadius: 10,
                //     offset: Offset(0, -5),
                //   ),
                // ],
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50, vertical: 25),
                  decoration: BoxDecoration(
                    color: const Color(0xFF07BEB8),
                    borderRadius: BorderRadius.circular(53),
                  ),
                  child: Text(
                    "NO NOTIFICATION YET",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}