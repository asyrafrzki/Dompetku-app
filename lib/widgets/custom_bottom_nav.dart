import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFF07BEB8), // Warna tema biru kehijauan
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(53),
          topRight: Radius.circular(53),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(5, (index) {
          List<IconData> icons = [
            Icons.home, // Home
            Icons.bar_chart, // Analytics
            Icons.swap_horiz, // Transactions
            Icons.layers, // Categories (Asumsi)
            Icons.person // Profile
          ];

          bool selected = index == selectedIndex;

          return GestureDetector(
            onTap: () => onItemTapped(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFC4FFF9) : Colors.transparent, // Warna highlight
                shape: BoxShape.circle,
              ),
              child: Icon(
                icons[index],
                size: 28,
                color: selected ? Colors.black : Colors.white,
              ),
            ),
          );
        }),
      ),
    );
  }
}