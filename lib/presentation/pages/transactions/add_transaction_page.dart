import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:dompetku/presentation/widgets/date_picker_calender.dart';
import 'package:dompetku/providers/transaction_provider.dart';

class AddTransactionPage extends StatefulWidget {
  final bool isGoals;
  final String? goalId;

  // >>> PARAMETER BARU = selectedCategoryName
  final String? selectedCategoryName;

  const AddTransactionPage({
    super.key,
    this.isGoals = false,
    this.goalId,
    this.selectedCategoryName,
  });

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  Map<String, dynamic>? selectedCategory;

  final _formKey = GlobalKey<FormState>();

  final List<Map<String, dynamic>> categories = [
    {'name': 'Food', 'icon': Icons.restaurant_menu, 'isIncome': false, 'isGoals': false},
    {'name': 'Transport', 'icon': Icons.directions_bus, 'isIncome': false, 'isGoals': false},
    {'name': 'Medicine', 'icon': Icons.local_pharmacy, 'isIncome': false, 'isGoals': false},
    {'name': 'Groceries', 'icon': Icons.shopping_bag, 'isIncome': false, 'isGoals': false},
    {'name': 'Income', 'icon': Icons.monetization_on, 'isIncome': true, 'isGoals': false},
    {'name': 'Others', 'icon': Icons.more_horiz, 'isIncome': false, 'isGoals': false},
  ];

  @override
  void initState() {
    super.initState();
    dateController.text = _formatDate(DateTime.now());

    // AUTO SET CATEGORY BERDASARKAN PAGE TERPILIH
    if (widget.isGoals) {
      selectedCategory = {
        'name': 'Goals',
        'icon': Icons.flag,
        'isIncome': false,
        'isGoals': true,
      };
    } else if (widget.selectedCategoryName != null) {
      selectedCategory = categories.firstWhere(
            (c) => c['name'] == widget.selectedCategoryName,
        orElse: () => categories.last,
      );
    } else {
      selectedCategory = categories.last; // Others
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}-${date.month}-${date.year}";
  }

  // =============================
  // SAVE TRANSACTION
  // =============================
  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<TransactionProvider>(context, listen: false);

    final errorMessage = await provider.saveTransaction(
      date: dateController.text,
      amountString: amountController.text,
      description: descriptionController.text,
      category: selectedCategory!,
      goalId: widget.isGoals ? widget.goalId : null,
    );

    if (errorMessage == null) {
      _showSnackBar("Sukses", "Data berhasil disimpan!", Colors.green, Icons.check_circle);

      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) Navigator.pop(context);
      });
    } else {
      _showSnackBar("Gagal", errorMessage, Colors.red, Icons.error);
    }
  }

  // =============================
  // CATEGORY PICKER
  // =============================
  void _openCategoryPicker() {
    if (widget.isGoals) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 15),
          Text("Choose Category",
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          ...categories.map((cat) {
            return ListTile(
              leading: Icon(cat["icon"]),
              title: Text(cat["name"]),
              onTap: () {
                setState(() => selectedCategory = cat);
                Navigator.pop(context);
              },
            );
          }).toList()
        ],
      ),
    );
  }

  // =============================
  // SNACKBAR
  // =============================
  void _showSnackBar(String title, String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        content: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(15)),
          child: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 15),
              Expanded(
                child: Text("$title\n$message", style: GoogleFonts.poppins(color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }

  // =============================
  // UI
  // =============================
  @override
  Widget build(BuildContext context) {
    final isSaving = Provider.of<TransactionProvider>(context).isSaving;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isGoals ? "Add Goals Progress" : "Add Transaction"),
        backgroundColor: const Color(0xFF07BEB8),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // DATE
            Text("Date", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            TextFormField(
              controller: dateController,
              readOnly: true,
              decoration: InputDecoration(
                suffixIcon: const Icon(Icons.calendar_today, color: Colors.teal),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onTap: () async {
                final selected = await showDialog(
                  context: context,
                  builder: (_) => const DatePickerCalendar(),
                );
                if (selected != null) {
                  setState(() => dateController.text = _formatDate(selected));
                }
              },
            ),

            const SizedBox(height: 20),

            // CATEGORY (AUTO)
            if (!widget.isGoals)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Category", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  GestureDetector(
                    onTap: _openCategoryPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Row(
                        children: [
                          Icon(selectedCategory!["icon"], color: Colors.teal),
                          const SizedBox(width: 10),
                          Text(selectedCategory!["name"],
                              style: GoogleFonts.poppins(fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

            if (!widget.isGoals) const SizedBox(height: 20),

            // AMOUNT
            Text("Amount", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            TextFormField(
              controller: amountController,
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
              decoration: InputDecoration(
                hintText: "Rp 10.000",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 20),

            // DESCRIPTION
            Text("Description", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            TextFormField(
              controller: descriptionController,
              validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
              decoration: InputDecoration(
                hintText: "e.g. Salary / Food / Notes",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 30),

            // SAVE BUTTON
            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: isSaving ? null : _saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF07BEB8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text("Save",
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
