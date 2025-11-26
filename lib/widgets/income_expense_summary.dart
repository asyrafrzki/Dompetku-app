import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IncomeExpenseSummary extends StatelessWidget {
  final double income;
  final double expense;
  final Color primaryColor = const Color(0xFF07BEB8);
  final Color expenseColor = const Color(0xFF2563EB); // Biru untuk expense

  const IncomeExpenseSummary({
    super.key,
    required this.income,
    required this.expense,
  });

  Widget _buildSummaryItem({
    required String label,
    required double amount,
    required Color color,
  }) {
    // Format mata uang
    final String formattedAmount = "Rp. ${amount.toStringAsFixed(3)}";

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.expand_less, // Ikon sesuai desain
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 18),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          formattedAmount,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            label: "Income",
            amount: income,
            color: primaryColor,
          ),
          _buildSummaryItem(
            label: "Expense",
            amount: expense,
            color: expenseColor,
          ),
        ],
      ),
    );
  }
}