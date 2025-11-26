import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dompetku/presentation/widgets/date_picker_calender.dart';

// --- DEFINISI WARNA ---
const Color kPrimaryColor = Color(0xFF07BEB8);
const Color kLightBackgroundColor = Color(0xFFF8FFF2);
const Color kActiveButtonColor = Color(0xFF1565C0);

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({Key? key}) : super(key: key);

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  int selectedTab = 0;
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    const double tabHeight = 70;
    const double tabTopPosition = 180;
    const double verticalGap = 60;
    final double bodyWhiteTopPosition =
        statusBarHeight + tabTopPosition + tabHeight + verticalGap - 30;
    final double headerBottomPadding =
        tabTopPosition + (tabHeight / 2) - 20;

    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                    20, statusBarHeight + 20, 20, headerBottomPadding),
                color: kPrimaryColor,
                child: Column(
                  children: [
                    Text(
                      "Transaction",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          "Total Balance",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: Container(color: kLightBackgroundColor)),
            ],
          ),

          // ===== BODY PUTIH =====
          Positioned.fill(
            top: bodyWhiteTopPosition,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: kLightBackgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () async {
                        final result = await showDialog(
                          context: context,
                          builder: (_) => const DatePickerCalendar(),
                        );

                        if (result != null && result is DateTime) {
                          setState(() => selectedDate = result);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.calendar_month,
                          color: kActiveButtonColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  if (selectedDate != null)
                    Text(
                      "Selected: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ===== TAB FLOATING =====
          Positioned(
            top: statusBarHeight + tabTopPosition,
            left: 20,
            right: 20,
            child: Row(
              children: [
                Expanded(child: _buildTab(0, "Income", Icons.arrow_outward_rounded)),
                const SizedBox(width: 12),
                Expanded(child: _buildTab(1, "Expense", Icons.south_west_rounded)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String title, IconData icon) {
    bool active = selectedTab == index;

    return GestureDetector(
      onTap: () => setState(() => selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: active ? kActiveButtonColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: active ? Colors.white : kActiveButtonColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: active ? Colors.white : kActiveButtonColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}