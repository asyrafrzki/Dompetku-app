import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TimeFrameButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const TimeFrameButton({
    super.key,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF07BEB8); // Warna Biru Kehijauan
    const Color highlightColor = Color(0xFFC4FFF9); // Warna highlight/terpilih

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? highlightColor : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          // Border menyesuaikan warna highlight
          border: Border.all(color: selected ? highlightColor : primaryColor, width: 2),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black, // Teks tetap hitam
          ),
        ),
      ),
    );
  }
}