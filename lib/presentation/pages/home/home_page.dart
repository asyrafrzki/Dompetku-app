import 'package:flutter/material.dart';
// Import Halaman lain yang levelnya sejajar dengan Home
import 'package:dompetku/presentation/pages/analytics/analytics_page.dart';
import 'package:dompetku/presentation/pages/transactions/transaction_page.dart';
// Import konten dashboard di folder yang sama
import 'package:dompetku/presentation/pages/home/dashboard_content.dart';
// Import widget navbar
import 'package:dompetku/presentation/widgets/custom_bottom_nav_bar.dart';
import 'package:dompetku/presentation/pages/categories/categories_page.dart';
import 'package:dompetku/presentation/pages/profile/profile_page.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardContent(),
    const AnalyticsPage(),
    const TransactionsPage(),
    const CategoriesPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}