import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dompetku/presentation/widgets/date_picker_calender.dart';


class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF07BEB8);
    const Color backgroundColor = Color(0xFFf5f5f5);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Income',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(50)),
            ),
            child: const _TotalBalanceDisplay(),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _InputCard(
                  title: 'Date',
                  hintText: 'Pick Date',
                  icon: Icons.calendar_today,
                  controller: dateController,
                  onTapIcon: () async {
                    final selectedDate = await showDialog(
                      context: context,
                      builder: (_) => const DatePickerCalendar(),
                    );

                    if (selectedDate != null) {
                      final formatted = "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}";
                      setState(() {
                        dateController.text = formatted;
                      });
                    }
                  },
                ),

                _InputCard(
                  title: 'Amount',
                  hintText: 'Rp. 10.000.000',
                  isCurrency: true,
                  controller: amountController,
                ),

                _InputCard(
                  title: 'Description',
                  hintText: 'Gaji',
                  controller: descriptionController,
                ),

                const SizedBox(height: 30),

                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalBalanceDisplay extends StatelessWidget {
  const _TotalBalanceDisplay();

  @override
  Widget build(BuildContext context) {
    const Color expenseColor = Color(0xFFFF003A);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Row(
              children: [
                Icon(Icons.account_balance_wallet, color: Colors.white, size: 14),
                SizedBox(width: 4),
                Text(
                  'Total Balance',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
            Text(
              'Rp.10.000.000',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(width: 20),
        Container(height: 40, width: 2, color: Colors.white30),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Row(
              children: [
                Icon(Icons.money_off, color: expenseColor, size: 14),
                SizedBox(width: 4),
                Text(
                  'Total Expense',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
            Text(
              'Rp. 520.000',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: expenseColor),
            ),
          ],
        ),
      ],
    );
  }
}

class _InputCard extends StatelessWidget {
  final String title;
  final String hintText;
  final IconData? icon;
  final VoidCallback? onTapIcon;
  final bool isCurrency;
  final TextEditingController? controller;

  const _InputCard({
    required this.title,
    required this.hintText,
    this.icon,
    this.onTapIcon,
    this.isCurrency = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    const Color cardColor = Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              readOnly: icon != null ? true : false,
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                suffixIcon: icon != null
                    ? IconButton(
                  icon: Icon(icon, color: Color(0xFF07BEB8)),
                  onPressed: onTapIcon,
                )
                    : null,
              ),
              keyboardType: isCurrency ? TextInputType.number : TextInputType.text,
            ),
          ),
        ],
      ),
    );
  }
}