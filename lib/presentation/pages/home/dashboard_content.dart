import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dompetku/presentation/pages/notification/notification_page.dart';
import 'package:dompetku/presentation/widgets/income_expense_card.dart';
import 'package:dompetku/presentation/widgets/time_frame_button.dart';

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  int _selectedTab = 0;

  String _getTabText(int index) {
    switch (index) {
      case 0: return "Daily";
      case 1: return "Weekly";
      case 2: return "Monthly";
      default: return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    // Simulasi data user karena tidak ada main.dart
    final User? user = FirebaseAuth.instance.currentUser;
    final String userName = user?.displayName ?? user?.email ?? "User";

    return Column(
      children: [
        // ===================== HEADER ========================= //
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(28, 60, 28, 40),
          decoration: const BoxDecoration(
            color: Color(0xFF07BEB8),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(45),
              bottomRight: Radius.circular(45),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row (Nama dan Notif button)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Hi, $userName",
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // Notif button
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const NotificationPage()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFC4FFF9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.notifications_none, size: 28),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 25),

              // ===================== WIDGET INCOME EXPENSE CARD (Perbaikan Error) ===================== //
              // Menggantikan panggilan ke _incomeBox yang error
              const IncomeExpenseCard(),
            ],
          ),
        ),

        // =================== BODY SCROLL ====================== //
        Expanded(
          child: Container(
            color: const Color(0xFFF8FFF2),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ... (Goal Box) ...

                  const SizedBox(height: 45),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Transactions",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // =================== WIDGET TIME FRAME SELECTOR ====================== //
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF07BEB8),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Menggunakan widget TimeFrameButton yang diekstrak
                        TimeFrameButton(
                          text: "Daily",
                          selected: _selectedTab == 0,
                          onTap: () => setState(() => _selectedTab = 0),
                        ),
                        TimeFrameButton(
                          text: "Weekly",
                          selected: _selectedTab == 1,
                          onTap: () => setState(() => _selectedTab = 1),
                        ),
                        TimeFrameButton(
                          text: "Monthly",
                          selected: _selectedTab == 2,
                          onTap: () => setState(() => _selectedTab = 2),
                        ),
                      ],
                    ),
                  ),


                  const SizedBox(height: 50),

                  // ... (No Transactions Yet Box) ...
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}