import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:math' as math; // <-- Tambahkan impor ini jika BarChartWidget membutuhkannya

// Import widget-widget yang diekstrak (Pastikan jalur ini benar)
import 'package:dompetku/presentation/widgets/custom_page_header.dart';
import 'package:dompetku/presentation/widgets/income_expense_summary.dart';
import 'package:dompetku/presentation/widgets/bar_chart_widget.dart';
import 'package:dompetku/presentation/widgets/time_frame_button.dart';

// Jika TimeFrameButton digunakan secara langsung, tambahkan import di sini:
// import 'package:dompetku/presentation/widgets/time_frame_button.dart';

// Definisi Warna Global (Jika tidak ada file constants.dart)
const Color primaryColor = Color(0xFF07BEB8);
const Color secondaryColor = Color(0xFFF8FFF2); // Warna Body Putih/Krem


class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  final double totalExpense = 520.00;
  final double income = 10000.00;
  int _selectedTimeFrame = 0;

  // Data State dan Chart Data (disimpan di state halaman)
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final List<Map<String, dynamic>> chartData = [
    {'day': 'Mon', 'income': 10.0, 'expense': 5.0},
    {'day': 'Tue', 'income': 3.0, 'expense': 7.0},
    {'day': 'Wed', 'income': 12.0, 'expense': 10.0},
    {'day': 'Thu', 'income': 5.0, 'expense': 4.0},
    {'day': 'Fri', 'income': 15.0, 'expense': 8.0},
    {'day': 'Sat', 'income': 2.0, 'expense': 1.0},
    {'day': 'Sun', 'income': 13.0, 'expense': 6.0},
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  void _selectTimeFrame(int index) {
    setState(() {
      _selectedTimeFrame = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header menggunakan widget yang diekstrak
            CustomPageHeader(
              title: "Analysis",
              onBack: () => Navigator.pop(context),
            ),

            const SizedBox(height: 30),

            // Time Frame Selector menggunakan widget yang diekstrak
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TimeFrameButton(
                    text: "Daily",
                    selected: _selectedTimeFrame == 0,
                    onTap: () => _selectTimeFrame(0),
                  ),
                  const SizedBox(width: 10),
                  TimeFrameButton(
                    text: "Weekly",
                    selected: _selectedTimeFrame == 1,
                    onTap: () => _selectTimeFrame(1),
                  ),
                  const SizedBox(width: 10),
                  TimeFrameButton(
                    text: "Monthly",
                    selected: _selectedTimeFrame == 2,
                    onTap: () => _selectTimeFrame(2),
                  ),
                ],
              ),
            ),



            const SizedBox(height: 30),

            // Card Utama Analisis
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Income & Expenses",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Bar Chart menggunakan widget yang diekstrak
                    SizedBox(
                      height: 200,
                      child: BarChartWidget(data: chartData),
                    ),
                    const SizedBox(height: 40),

                    // Ringkasan Pendapatan/Pengeluaran menggunakan widget yang diekstrak
                    IncomeExpenseSummary(
                      income: income,
                      expense: totalExpense,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Logika dialog kalender (dibiarkan di sini karena menggunakan state)
  void _showCalendarDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        // Placeholder dialog kalender
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Calendar Dialog", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                // Menggunakan isSameDay di sini yang mungkin menjadi sumber error
                TableCalendar(
                  focusedDay: _focusedDay,
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  // isSameDay adalah fungsi utilitas dari package:table_calendar
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selected, focused) {
                    setState(() {
                      _selectedDay = selected;
                      _focusedDay = focused;
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}