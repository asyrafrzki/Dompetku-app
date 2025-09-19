import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:math' as math;

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  final double totalExpense = 1187.40;
  final double income = 4120.00;

  final List<Map<String, dynamic>> transactions = [
    {
      "title": "Groceries",
      "date": "17:00 - April 24",
      "category": "Pantry",
      "amount": -100.00,
      "isExpense": true,
      "icon": Icons.shopping_bag,
      "color": const Color(0xFF06B6D4),
    },
    {
      "title": "Others",
      "date": "17:00 - April 24",
      "category": "Payments",
      "amount": 120.00,
      "isExpense": false,
      "icon": Icons.widgets,
      "color": const Color(0xFF2563EB),
    },
    {
      "title": "Salary",
      "date": "09:00 - April 23",
      "category": "Income",
      "amount": 2500.00,
      "isExpense": false,
      "icon": Icons.attach_money,
      "color": Colors.green,
    },
  ];

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0EA5E9),
        title: Text(
          "Analytics",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: const Color(0xFF0EA5E9),
              padding: const EdgeInsets.only(bottom: 20),
            ),
            Container(
              color: const Color(0xFFF5F7FA),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTimeFrameButton("Daily", true),
                  _buildTimeFrameButton("Weekly", false),
                  _buildTimeFrameButton("Monthly", false),
                  _buildTimeFrameButton("Year", false),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Income & Expenses",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.search, color: Colors.grey),
                            const SizedBox(width: 10),
                            IconButton(
                              icon: const Icon(Icons.calendar_month, color: Colors.grey),
                              onPressed: () {
                                _showCalendarDialog(context);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 180,
                      child: LineChart(
                        data: const [
                          {'day': 'Mon', 'income': 100.0, 'expense': 50.0},
                          {'day': 'Tue', 'income': 200.0, 'expense': 120.0},
                          {'day': 'Wed', 'income': 150.0, 'expense': 80.0},
                          {'day': 'Thu', 'income': 300.0, 'expense': 150.0},
                          {'day': 'Fri', 'income': 250.0, 'expense': 110.0},
                          {'day': 'Sat', 'income': 400.0, 'expense': 200.0},
                          {'day': 'Sun', 'income': 350.0, 'expense': 180.0},
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildBottomNavItem(
                            icon: Icons.arrow_downward,
                            label: "Income",
                            amount: income,
                            isIncome: true,
                          ),
                          _buildBottomNavItem(
                            icon: Icons.arrow_upward,
                            label: "Expense",
                            amount: totalExpense,
                            isIncome: false,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ...transactions.map((tx) {
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: tx["color"],
                    child: Icon(tx["icon"], color: Colors.white),
                  ),
                  title: Text(
                    tx["title"],
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    "${tx["date"]} • ${tx["category"]}",
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                  trailing: Text(
                    "${tx["isExpense"] ? '-' : '+'}\$${tx["amount"].abs().toStringAsFixed(2)}",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: tx["isExpense"] ? Colors.red : Colors.green,
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
      // Removed the redundant BottomAppBar
    );
  }

  Widget _buildTimeFrameButton(String text, bool isSelected) {
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0EA5E9) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            color: isSelected ? Colors.white : Colors.black54,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required double amount,
    required bool isIncome,
  }) {
    return SizedBox(
      height: 70,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isIncome ? Colors.green : Colors.red,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          Text(
            "\$${amount.toStringAsFixed(2)}",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isIncome ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  void _showCalendarDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TableCalendar(
                  focusedDay: _focusedDay,
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selected, focused) {
                    setState(() {
                      _selectedDay = selected;
                      _focusedDay = focused;
                    });
                  },
                  headerStyle: HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false,
                    titleTextStyle: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.orangeAccent.shade200,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: Color(0xFF0EA5E9),
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Transactions for ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: tx["color"],
                          child: Icon(tx["icon"], color: Colors.white),
                        ),
                        title: Text(tx["title"]),
                        subtitle: Text(tx["category"]),
                        trailing: Text(
                          "${tx["isExpense"] ? '-' : ''}\$${tx["amount"].abs().toStringAsFixed(2)}",
                          style: TextStyle(
                            color: tx["isExpense"] ? Colors.red : Colors.green,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class LineChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const LineChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    double maxIncome = 0.0;
    double maxExpense = 0.0;

    for (var item in data) {
      if (item['income'] > maxIncome) {
        maxIncome = item['income'];
      }
      if (item['expense'] > maxExpense) {
        maxExpense = item['expense'];
      }
    }

    final double maxVal = math.max(maxIncome, maxExpense) * 1.2;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;

        final List<Offset> incomePoints = [];
        final List<Offset> expensePoints = [];
        final double pointDistance = width / (data.length - 1);

        for (int i = 0; i < data.length; i++) {
          final double income = data[i]['income'];
          final double expense = data[i]['expense'];
          final double x = i * pointDistance;
          final double yIncome = height - (income / maxVal) * height;
          final double yExpense = height - (expense / maxVal) * height;

          incomePoints.add(Offset(x, yIncome));
          expensePoints.add(Offset(x, yExpense));
        }

        return Stack(
          children: [
            CustomPaint(
              painter: _LineChartPainter(
                incomePoints: incomePoints,
                expensePoints: expensePoints,
              ),
              child: Container(),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: data.map((item) {
                  return Text(item['day'], style: GoogleFonts.poppins(fontSize: 12));
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<Offset> incomePoints;
  final List<Offset> expensePoints;

  _LineChartPainter({required this.incomePoints, required this.expensePoints});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint incomePaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final Paint expensePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    if (incomePoints.length > 1) {
      final Path incomePath = Path()..moveTo(incomePoints[0].dx, incomePoints[0].dy);
      for (int i = 1; i < incomePoints.length; i++) {
        incomePath.lineTo(incomePoints[i].dx, incomePoints[i].dy);
      }
      canvas.drawPath(incomePath, incomePaint);
    }

    if (expensePoints.length > 1) {
      final Path expensePath = Path()..moveTo(expensePoints[0].dx, expensePoints[0].dy);
      for (int i = 1; i < expensePoints.length; i++) {
        expensePath.lineTo(expensePoints[i].dx, expensePoints[i].dy);
      }
      canvas.drawPath(expensePath, expensePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}