import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IncomeExpenseCard extends StatelessWidget {
  const IncomeExpenseCard({super.key});

  // Fungsi pembantu untuk kotak metrik tunggal
  Widget _incomeMetricBox(String title, String value, bool isExpense) {
    // Tentukan warna (Hijau untuk Income, Merah/Custom untuk Expense)
    final Color color = isExpense ? Colors.red : Colors.green;

    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.circle, size: 12, color: color),
            const SizedBox(width: 6),
            Text(title,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.black)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _incomeMetricBox("Total Income", "0", false), // Income
          Container(width: 1, height: 40, color: Colors.grey[300]), // Pembatas
          _incomeMetricBox("Total Expense", "0", true), // Expense
        ],
      ),
    );
  }
}