import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:dompetku/presentation/widgets/custom_page_header.dart';
import 'package:dompetku/presentation/widgets/income_expense_summary.dart';
import 'package:dompetku/presentation/widgets/bar_chart_widget.dart';
import 'package:dompetku/presentation/widgets/time_frame_button.dart';

const Color primaryColor = Color(0xFF07BEB8);
const Color secondaryColor = Color(0xFFF8FFF2);

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  int _selectedTimeFrame = 0; // 0=Daily, 1=Weekly, 2=Monthly
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
//set default tanggal sekarang
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

  /// Menghitung tanggal awal dan akhir untuk query database
  Map<String, DateTime> _getTimeFrame() {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate;

    switch (_selectedTimeFrame) {
      case 0: // Daily
        return _getTimeFrameForWeekly();

      case 1: // Weekly
        return _getTimeFrameForWeekly();

      case 2: // Monthly
        startDate = DateTime(now.year, now.month, 1);
        // Akhir bulan
        endDate = DateTime(now.year, now.month + 1, 1).subtract(const Duration(milliseconds: 1));
        break;
      default:
      // Fallback: Weekly
        return _getTimeFrameForWeekly();
    }
    return {'start': startDate, 'end': endDate};
  }

  Map<String, DateTime> _getTimeFrameForWeekly() {
    final now = DateTime.now();
    // Cari hari Senin di minggu ini
    final daysToSubtract = now.weekday - 1;
    final startDate = DateTime(now.year, now.month, now.day).subtract(Duration(days: daysToSubtract));
    // Akhir hari Minggu
    final endDate = startDate.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
    return {'start': startDate, 'end': endDate};
  }

  Stream<QuerySnapshot> _getTransactionStream() {
    if (_currentUser == null) {
      return const Stream.empty();
    }

    final timeFrame = _getTimeFrame();
    final startTimestamp = timeFrame['start'];
    final endTimestamp = timeFrame['end'];

    return FirebaseFirestore.instance
        .collection("users")
        .doc(_currentUser!.uid)
        .collection("transactions")
        .where('timestamp', isGreaterThanOrEqualTo: startTimestamp)
        .where('timestamp', isLessThanOrEqualTo: endTimestamp)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  List<Map<String, dynamic>> _aggregateChartData(List<QueryDocumentSnapshot> transactions) {
    final Map<String, double> incomeMap = {};
    final Map<String, double> expenseMap = {};
    final List<Map<String, dynamic>> result = [];

    // Tentukan format key untuk agregasi (Day Name/Month Name)
    String getGroupingKey(DateTime date) {
      if (_selectedTimeFrame == 2) { // Monthly
        return DateFormat('MMM').format(date);
      }
      // Weekly/Daily -> Grouping by Day Name
      return DateFormat('E').format(date);
    }

    // Hitung total per group
    for (var doc in transactions) {
      final data = doc.data() as Map<String, dynamic>;
      final double amount = (data['amount'] ?? 0).toDouble();
      final String type = data['type'] ?? '';
      final Timestamp? ts = data['timestamp'] as Timestamp?;

      if (ts == null) continue;

      final key = getGroupingKey(ts.toDate());

      if (type == 'income') {
        incomeMap[key] = (incomeMap[key] ?? 0) + amount;
      } else {
        expenseMap[key] = (expenseMap[key] ?? 0) + amount;
      }
    }

    // Urutan default untuk Weekly Chart (Senin-Minggu)
    final List<String> defaultWeeklyOrder = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    // Gabungkan dan susun data ke format Chart
    final Set<String> allKeys = {...incomeMap.keys, ...expenseMap.keys};

    if (_selectedTimeFrame != 2) {
      // Untuk Weekly/Daily, gunakan urutan hari default (7 hari)
      for (var day in defaultWeeklyOrder) {
        result.add({
          'day': day,
          'income': incomeMap[day] ?? 0.0,
          'expense': expenseMap[day] ?? 0.0,
        });
      }
    } else {
      // Untuk Monthly, gunakan semua bulan yang memiliki data
      for (var monthKey in allKeys) {
        result.add({
          'day': monthKey,
          'income': incomeMap[monthKey] ?? 0.0,
          'expense': expenseMap[monthKey] ?? 0.0,
        });
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      body: StreamBuilder<QuerySnapshot>(
        stream: _getTransactionStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final transactions = snapshot.data?.docs ?? [];
          double currentIncome = 0.0;
          double currentExpense = 0.0;

          // total income
          for (var doc in transactions) {
            final data = doc.data() as Map<String, dynamic>;
            final double amount = (data['amount'] ?? 0).toDouble();
            final String type = data['type'] ?? '';

            if (type == 'income') {
              currentIncome += amount;
            } else {
              currentExpense += amount;
            }
          }

          //chart
          final List<Map<String, dynamic>> aggregatedChartData =
          _aggregateChartData(transactions);


          return SingleChildScrollView(
            child: Column(
              children: [
                CustomPageHeader(
                  title: "Analysis",
                  onBack: () => Navigator.pop(context),
                ),

                const SizedBox(height: 30),

                // Tombol Time Frame
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
                        SizedBox(
                          height: 200,
                          child: BarChartWidget(data: aggregatedChartData),
                        ),
                        const SizedBox(height: 40),
                        IncomeExpenseSummary(
                          income: currentIncome,
                          expense: currentExpense,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showCalendarDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Calendar Dialog", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                TableCalendar(
                  focusedDay: _focusedDay,
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
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