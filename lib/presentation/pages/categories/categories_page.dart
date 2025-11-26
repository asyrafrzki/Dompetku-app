import 'package:flutter/material.dart';
// Import halaman tujuan setelah kategori ditekan
import 'package:dompetku/presentation/pages/transactions/transaction_list_page.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Definisi Kategori
    final List<Map<String, dynamic>> categories = [
      {'name': 'Food', 'icon': Icons.restaurant_menu, 'isIncome': false},
      {'name': 'Transport', 'icon': Icons.directions_bus, 'isIncome': false},
      {'name': 'Medicine', 'icon': Icons.local_pharmacy, 'isIncome': false},
      {'name': 'Groceries', 'icon': Icons.shopping_bag, 'isIncome': false},
      {'name': 'Income', 'icon': Icons.monetization_on, 'isIncome': true},
      {'name': 'Goals', 'icon': Icons.flag, 'isIncome': false},
      {'name': 'Others', 'icon': Icons.more_horiz, 'isIncome': false},
    ];

    // Warna utama dari UI Anda
    const Color primaryColor = Color(0xFF07BEB8);
    const Color secondaryColor =  Color(0xFFF8FFF2);

    return Scaffold(
      backgroundColor: primaryColor,
      body: Column(
        children: [
          // Header dengan Teks "Categories"
          const SizedBox(height: 60),
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              bottom: 20,
            ),
            child: const Text(
              'Categories',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 90),
          Expanded(
            child: Container(
              // Container besar di bawah header
              decoration: const BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              padding: const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 20),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.9,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return _CategoryGridItem(
                    name: category['name'],
                    icon: category['icon'],
                    color: primaryColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TransactionListPage(
                            categoryName: category['name'],
                            isIncome: category['isIncome'],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget untuk setiap item kategori pada Grid
class _CategoryGridItem extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CategoryGridItem({
    required this.name,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Kotak Ikon
          Container(
            width: double.infinity,
            height: 80,
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: color,
              size: 35,
            ),
          ),
          const SizedBox(height: 5),
          // Nama Kategori
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}