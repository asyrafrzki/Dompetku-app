import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomPageHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const CustomPageHeader({
    super.key,
    required this.title,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF07BEB8);

    return Container(
      width: double.infinity,
      // Padding disesuaikan
      padding: const EdgeInsets.fromLTRB(28, 60, 28, 40),
      decoration: const BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(53),
          bottomRight: Radius.circular(53),
        ),
      ),
      child: Stack(
        children: [



          // Judul Halaman
          Center(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 26,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Ikon notifikasi dihilangkan
        ],
      ),
    );
  }
}