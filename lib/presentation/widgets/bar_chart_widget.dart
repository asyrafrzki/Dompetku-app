import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class BarChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const BarChartWidget({super.key, required this.data});

  static const Color primaryColor = Color(0xFF07BEB8);
  static const Color expenseColor = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    //cek data kosong
    final bool hasData = data.any(
          (e) => (e['income'] ?? 0) > 0 || (e['expense'] ?? 0) > 0,
    );

    if (!hasData) {
      return _emptyState();
    }

    double maxIncome = 0.0;
    double maxExpense = 0.0;

    for (final item in data) {
      maxIncome = math.max(maxIncome, (item['income'] ?? 0).toDouble());
      maxExpense = math.max(maxExpense, (item['expense'] ?? 0).toDouble());
    }

    final double rawMax = math.max(maxIncome, maxExpense);
    final double maxVal = rawMax == 0 ? 1 : rawMax * 1.2;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double height = constraints.maxHeight;
        const double barWidth = 10;

        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _YAxisPainter(
                  maxVal: maxVal,
                  height: height,
                  lines: 4,
                ),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((item) {
                final double income =
                (item['income'] ?? 0).toDouble();
                final double expense =
                (item['expense'] ?? 0).toDouble();

                final double incomeHeight =
                ((income / maxVal) * height * 0.8)
                    .clamp(0.0, height);

                final double expenseHeight =
                ((expense / maxVal) * height * 0.8)
                    .clamp(0.0, height);

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: barWidth,
                          height: incomeHeight,
                          margin: const EdgeInsets.only(right: 3),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
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
                    const SizedBox(height: 6),
                    Text(
                      item['day'] ?? '',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart,
              size: 42, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(
            "No data available",
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _YAxisPainter extends CustomPainter {
  final double maxVal;
  final double height;
  final int lines;

  _YAxisPainter({
    required this.maxVal,
    required this.height,
    required this.lines,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    final double step = height / (lines + 1);
    final double valueStep = maxVal / (lines + 1);

    for (int i = 0; i <= lines; i++) {
      final double y = height - (i * step);

      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );

      final double value = valueStep * i;
      final String label = _formatValue(value);

      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(minWidth: 0, maxWidth: 50);

      textPainter.paint(canvas, Offset(-22, y - 6));
    }
  }

  String _formatValue(double value) {
    if (value < 1) return "0";
    if (value < 1000) return value.round().toString();
    return "${(value / 1000).round()}k";
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
