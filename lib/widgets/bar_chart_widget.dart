import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class BarChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final Color primaryColor = const Color(0xFF07BEB8);
  final Color expenseColor = const Color(0xFF2563EB);

  const BarChartWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    double maxIncome = 0.0;
    double maxExpense = 0.0;

    for (var item in data) {
      if (item['income'] > maxIncome) maxIncome = item['income'];
      if (item['expense'] > maxExpense) maxExpense = item['expense'];
    }

    final double maxVal = math.max(maxIncome, maxExpense) * 1.2;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double height = constraints.maxHeight;
        final double barWidth = 10;

        return Stack(
          children: [
            // Y-Axis Labels and Lines
            Positioned.fill(
              child: CustomPaint(
                painter: _YAxisPainter(maxVal: maxVal, height: height, lines: 4),
              ),
            ),
            // Bar Visualization
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((item) {
                final double incomeHeight = (item['income'] / maxVal) * height * 0.8;
                final double expenseHeight = (item['expense'] / maxVal) * height * 0.8;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Bar Pendapatan (Primary Color)
                        Container(
                          width: barWidth,
                          height: incomeHeight,
                          margin: const EdgeInsets.only(right: 3),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        // Bar Pengeluaran (Expense Color)
                        Container(
                          width: barWidth,
                          height: expenseHeight,
                          decoration: BoxDecoration(
                            color: expenseColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5), // Jarak ke label hari
                    Text(item['day'], style: GoogleFonts.poppins(fontSize: 12)),
                  ],
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}

// Y-Axis Painter untuk garis horizontal dan label Y
class _YAxisPainter extends CustomPainter {
  final double maxVal;
  final double height;
  final int lines;

  _YAxisPainter({required this.maxVal, required this.height, required this.lines});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    final double step = height / (lines + 1);
    final double valueStep = maxVal / (lines + 1);

    for (int i = 0; i <= lines; i++) {
      final double y = height - (i * step);

      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);

      final double value = valueStep * i;
      String label;
      if (value < 1) {
        label = "0";
      } else if (value < 1000) {
        label = "${value.round()}k";
      } else {
        label = "${(value / 1000).round()}k";
      }

      TextPainter(
        text: TextSpan(text: label, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
        textDirection: TextDirection.ltr,
      )..layout(minWidth: 0, maxWidth: 50)
        ..paint(canvas, Offset(-20, y - 5));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}