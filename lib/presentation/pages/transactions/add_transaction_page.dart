import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dompetku/providers/transaction_provider.dart';
import 'package:dompetku/presentation/widgets/date_picker_calender.dart';

class AddTransactionPage extends StatefulWidget {
  final bool isGoals;
  final String? goalId; // WAJIB kalau isGoals=true
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
  final _formKey = GlobalKey<FormState>();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  Map<String, dynamic>? selectedCategory;

  final List<Map<String, dynamic>> categories = [
    {'name': 'Food', 'icon': Icons.restaurant_menu, 'isIncome': false, 'isGoals': false},
    {'name': 'Transport', 'icon': Icons.directions_bus, 'isIncome': false, 'isGoals': false},
    {'name': 'Medicine', 'icon': Icons.local_pharmacy, 'isIncome': false, 'isGoals': false},
    {'name': 'Groceries', 'icon': Icons.shopping_bag, 'isIncome': false, 'isGoals': false},
    {'name': 'Income', 'icon': Icons.monetization_on, 'isIncome': true, 'isGoals': false},
    {'name': 'Others', 'icon': Icons.more_horiz, 'isIncome': false, 'isGoals': false},
  ];

  Color get primary => const Color(0xFF07BEB8);

  @override
  void initState() {
    super.initState();
    dateController.text = _formatDate(DateTime.now());

    // goals harus punya goalId (biar gak ada add goals disini)
    if (widget.isGoals && (widget.goalId == null || widget.goalId!.isEmpty)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pilih goals dulu dari halaman Goals.")),
        );
      });
      return;
    }

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
      selectedCategory = categories.last;
    }
  }

  String _formatDate(DateTime date) => "${date.day}-${date.month}-${date.year}";

  Future<DateTime?> _pickDateDialog() async {
    final selected = await showDialog(
      context: context,
      builder: (_) => const DatePickerCalendar(),
    );
    return selected;
  }

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
              Expanded(child: Text("$title\n$message", style: GoogleFonts.poppins(color: Colors.white))),
            ],
          ),
        ),
      ),
    );
  }

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
          }).toList(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Future<void> _save() async {
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
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) Navigator.pop(context);
      });
    } else {
      _showSnackBar("Gagal", errorMessage, Colors.red, Icons.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = Provider.of<TransactionProvider>(context).isSaving;

    return Scaffold(
      backgroundColor: const Color(0xFFF5FFFE),
      appBar: AppBar(
        title: Text(widget.isGoals ? "Add Goals Progress" : "Add Transaction"),
        backgroundColor: primary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text("Date", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
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
                final selected = await _pickDateDialog();
                if (selected != null) setState(() => dateController.text = _formatDate(selected));
              },
            ),

            const SizedBox(height: 18),

            if (!widget.isGoals) ...[
              Text("Category", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
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
                      Expanded(child: Text(selectedCategory!["name"], style: GoogleFonts.poppins(fontSize: 16))),
                      const Icon(Icons.keyboard_arrow_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
            ],

            Text("Amount", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextFormField(
              controller: amountController,
              keyboardType: TextInputType.number,
              validator: (v) => (v == null || v.trim().isEmpty) ? "Wajib diisi" : null,
              decoration: InputDecoration(
                hintText: "Rp 10.000",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 18),

            Text("Description", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextFormField(
              controller: descriptionController,
              validator: (v) => (v == null || v.trim().isEmpty) ? "Wajib diisi" : null,
              decoration: InputDecoration(
                hintText: "Catatan...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text("Save", style: GoogleFonts.poppins(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
