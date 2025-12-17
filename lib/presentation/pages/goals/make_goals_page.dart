import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:dompetku/presentation/widgets/date_picker_calender.dart';

class MakeGoalsPage extends StatefulWidget {
  const MakeGoalsPage({super.key});

  @override
  State<MakeGoalsPage> createState() => _MakeGoalsPageState();
}
//menangkap inputan user
class _MakeGoalsPageState extends State<MakeGoalsPage> {
  final _formKey = GlobalKey<FormState>();

  final nameC = TextEditingController();
  final categoryC = TextEditingController();
  final targetC = TextEditingController();

  final startC = TextEditingController();
  final endC = TextEditingController();

  bool saving = false;

  Color get primary => const Color(0xFF07BEB8);
//default hari sekarang
  @override
  void initState() {
    super.initState();
    startC.text = _fmt(DateTime.now());
    endC.text = _fmt(DateTime.now().add(const Duration(days: 30)));
  }

  String _fmt(DateTime d) => "${d.day}-${d.month}-${d.year}";

  Future<DateTime?> _pick() async {
    return await showDialog(
      context: context,
      builder: (_) => const DatePickerCalendar(),
    );
  }
//validasi form
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final cleaned = targetC.text.replaceAll(RegExp(r'[^0-9]'), '');
    final target = int.tryParse(cleaned) ?? 0;
    if (target <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Target amount tidak valid")),
      );
      return;
    }

    setState(() => saving = true);

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("goals")
          .add({
        "name": nameC.text.trim(),
        "category": categoryC.text.trim().isEmpty ? "-" : categoryC.text.trim(),
        "targetAmount": target,
        "startDate": startC.text.trim(),
        "endDate": endC.text.trim(),
        "createdAt": FieldValue.serverTimestamp(),
      });
//jika sukses
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal: $e")),
      );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primary,
      appBar: AppBar(
        backgroundColor: primary,
        title: const Text("Make Goals"),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 10),
        decoration: const BoxDecoration(
          color: Color(0xFFF5FFFE),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [
                  BoxShadow(blurRadius: 12, color: Color(0x11000000), offset: Offset(0, 6)),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _dateField("Start Date", startC, () async {
                      final d = await _pick();
                      if (d != null) setState(() => startC.text = _fmt(d));
                    }),
                    const SizedBox(height: 12),
                    _dateField("End Date", endC, () async {
                      final d = await _pick();
                      if (d != null) setState(() => endC.text = _fmt(d));
                    }),
                    const SizedBox(height: 12),
                    _field("Category", categoryC, validator: null),
                    const SizedBox(height: 12),
                    _field("Goal Name", nameC,
                        validator: (v) => (v == null || v.trim().isEmpty) ? "Wajib diisi" : null),
                    const SizedBox(height: 12),
                    _field("Target Amount", targetC,
                        keyboardType: TextInputType.number,
                        validator: (v) => (v == null || v.trim().isEmpty) ? "Wajib diisi" : null),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 52,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        onPressed: saving ? null : _save,
                        child: saving
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("Save",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
      String label,
      TextEditingController c, {
        TextInputType keyboardType = TextInputType.text,
        String? Function(String?)? validator,
      }) {
    return TextFormField(
      controller: c,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF2FFFE),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.black12),
        ),
      ),
    );
  }

  Widget _dateField(String label, TextEditingController c, Future<void> Function() onTap) {
    return TextFormField(
      controller: c,
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.calendar_month),
        filled: true,
        fillColor: const Color(0xFFF2FFFE),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.black12),
        ),
      ),
    );
  }
}
