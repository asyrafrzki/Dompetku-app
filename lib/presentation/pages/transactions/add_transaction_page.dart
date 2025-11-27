import 'package:dompetku/presentation/pages/analytics/analytics_page.dart';
import 'package:dompetku/presentation/pages/profile/edit_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dompetku/presentation/widgets/date_picker_calender.dart';

class AddTransactionPage extends StatefulWidget {
  final bool isGoals;

  const AddTransactionPage({super.key, this.isGoals = false});

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
      backgroundColor: secondaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isGoals ? 'Add Progress' : 'Income',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: ListView(
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
                final formatted =
                    "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}";
                setState(() {
                  dateController.text = formatted;
                });
              }
            },
          ),

          _InputCard(
            title: widget.isGoals ? 'Progress Amount' : 'Amount',
            hintText: 'Rp. 10.000',
            isCurrency: true,
            controller: amountController,
          ),

          _InputCard(
            title: widget.isGoals ? 'Note' : 'Description',
            hintText: widget.isGoals ? 'Add progress note' : 'Gaji',
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
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
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
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87),
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
              readOnly: icon != null,
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
              keyboardType:
              isCurrency ? TextInputType.number : TextInputType.text,
            ),
          ),
        ],
      ),
    );
  }
}
