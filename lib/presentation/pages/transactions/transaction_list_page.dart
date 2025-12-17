import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dompetku/providers/transaction_provider.dart';
import 'package:dompetku/presentation/pages/transactions/add_transaction_page.dart';
import 'package:dompetku/presentation/pages/goals/make_goals_page.dart';
import 'package:dompetku/presentation/widgets/delete_confirmation_dialog.dart';

class TransactionListPage extends StatelessWidget {
  final String categoryName;
  final bool isIncome;

  const TransactionListPage({
    super.key,
    required this.categoryName,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF07BEB8);
    const Color secondaryColor = Color(0xFFF5FFFE);

    final bool isGoalsPage = categoryName == "Goals";
    final provider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      backgroundColor: primaryColor,
      body: Column(
        children: [
          _HeaderSection(
            primaryColor: primaryColor,
            title: categoryName,
            isIncome: isIncome,
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                child: isGoalsPage
                    ? const GoalsBody(primaryColor: primaryColor)
                    : _TransactionsBody(
                  primaryColor: primaryColor,
                  categoryName: categoryName,
                  isIncome: isIncome,
                  provider: provider,
                ),
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: isGoalsPage
          ? null
          : Container(
        padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        color: secondaryColor,
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddTransactionPage(
                    isGoals: false,
                    selectedCategoryName: categoryName,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            ),
            child: const Text(
              "Add",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final Color primaryColor;
  final String title;
  final bool isIncome;

  const _HeaderSection({
    required this.primaryColor,
    required this.title,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    const Color secondaryColor = Color(0xFFF8FFF2);

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 28,
        left: 16,
        right: 16,
      ),
      color: primaryColor,
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 14),
          title == "Goals"
              ? Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Progress History",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text("Pilih goals untuk melihat progress."),
              ],
            ),
          )
              : Text(
            provider.formatCurrency(provider.totalForCategory(title, isIncome)),
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionsBody extends StatelessWidget {
  final Color primaryColor;
  final String categoryName;
  final bool isIncome;
  final TransactionProvider provider;

  const _TransactionsBody({
    required this.primaryColor,
    required this.categoryName,
    required this.isIncome,
    required this.provider,
  });

  Future<void> _confirmDeleteTransaction(BuildContext context, String docId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || docId.isEmpty) return;

    await showDialog(
      context: context,
      builder: (_) => DeleteConfirmationDialog(
        onDeleteConfirmed: () async {
          try {
            await FirebaseFirestore.instance
                .collection("users")
                .doc(user.uid)
                .collection("transactions")
                .doc(docId)
                .delete();
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Gagal hapus: $e")),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final all = provider.transactions;

    final bool isIncomePage = categoryName == "Income" || isIncome == true;

    List<Map<String, dynamic>> filtered;
    if (isIncomePage) {
      filtered = all.where((t) => t['type'] == 'income').toList();
    } else {
      filtered = all
          .where((t) => t['categoryName'] == categoryName && t['type'] != 'income')
          .toList();
    }

    filtered.sort((a, b) {
      final ta = a['timestamp'];
      final tb = b['timestamp'];
      if (ta == null || tb == null) return 0;
      return (tb as Timestamp).toDate().compareTo((ta as Timestamp).toDate());
    });

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          "Belum ada transaksi",
          style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600),
        ),
      );
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, i) {
        final t = filtered[i];
        final String docId = (t['id'] ?? '').toString();

        final String name = (t['description'] ?? t['categoryName'] ?? '-').toString();
        final String date = (t['date'] ?? '-').toString();
        final double amount = (t['amount'] ?? 0).toDouble();
        final bool income = t['type'] == 'income';

        return _TransactionItem(
          name: name,
          date: date,
          amount: amount,
          isIncome: income,
          primaryColor: primaryColor,
          onDelete: docId.isEmpty ? null : () => _confirmDeleteTransaction(context, docId),
        );
      },
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final String name;
  final String date;
  final double amount;
  final bool isIncome;
  final Color primaryColor;
  final VoidCallback? onDelete;

  const _TransactionItem({
    required this.name,
    required this.date,
    required this.amount,
    required this.isIncome,
    required this.primaryColor,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context, listen: false);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(blurRadius: 10, color: Color(0x11000000), offset: Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(isIncome ? Icons.attach_money : Icons.shopping_bag, color: primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ]),
          ),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                (isIncome ? "+" : "-") + provider.formatCurrency(amount),
                style: TextStyle(
                  color: isIncome ? primaryColor : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              if (onDelete != null)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class GoalsBody extends StatefulWidget {
  final Color primaryColor;
  const GoalsBody({super.key, required this.primaryColor});

  @override
  State<GoalsBody> createState() => _GoalsBodyState();
}

class _GoalsBodyState extends State<GoalsBody> {
  final user = FirebaseAuth.instance.currentUser;
  final db = FirebaseFirestore.instance;

  String? selectedGoalId;

  Future<void> _confirmDeleteProgress(
      BuildContext context, {
        required String goalId,
        required String progressId,
      }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || goalId.isEmpty || progressId.isEmpty) return;

    await showDialog(
      context: context,
      builder: (_) => DeleteConfirmationDialog(
        onDeleteConfirmed: () async {
          try {
            await FirebaseFirestore.instance
                .collection("users")
                .doc(user.uid)
                .collection("goals")
                .doc(goalId)
                .collection("progress")
                .doc(progressId)
                .delete();
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Gagal hapus progress: $e")),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) return const Center(child: Text("User belum login"));

    final goalsStream = db
        .collection("users")
        .doc(user!.uid)
        .collection("goals")
        .orderBy("createdAt", descending: true)
        .withConverter<Map<String, dynamic>>(
      fromFirestore: (s, _) => s.data() ?? {},
      toFirestore: (m, _) => m,
    )
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: goalsStream,
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());

        final goalsDocs =
        List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(snap.data!.docs);

        if (goalsDocs.isEmpty) {
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 6),
              _infoCard(
                primary: widget.primaryColor,
                title: "Belum ada goals",
                subtitle: "Buat goals dulu supaya bisa tambah progress.",
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 52,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MakeGoalsPage()),
                    );
                  },
                  child: const Text(
                    "Add Goals",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        }


        selectedGoalId ??= goalsDocs.first.id;

        final selectedDoc = goalsDocs.firstWhere(
              (d) => d.id == selectedGoalId,
          orElse: () => goalsDocs.first,
        );

        final goalData = selectedDoc.data();
        final target = (goalData["targetAmount"] ?? 0) as num;
        final goalName = (goalData["name"] ?? "Goal").toString();
        final startDate = (goalData["startDate"] ?? "-").toString();

        final progressStream = db
            .collection("users")
            .doc(user!.uid)
            .collection("goals")
            .doc(selectedDoc.id)
            .collection("progress")
            .orderBy("timestamp", descending: true)
            .withConverter<Map<String, dynamic>>(
          fromFirestore: (s, _) => s.data() ?? {},
          toFirestore: (m, _) => m,
        )
            .snapshots();
//ambil data dari firestore goals
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: progressStream,
          builder: (context, psnap) {
            if (!psnap.hasData) return const Center(child: CircularProgressIndicator()); //load jika data belum ada

            final pdocs =
            List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(psnap.data!.docs); //ambil dokumen

            num saved = 0; //bisa int bisa double
            for (final d in pdocs) {
              saved += (d.data()["amount"] ?? 0) as num;
            }

            return ListView(
              children: [
                // summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: const [
                      BoxShadow(blurRadius: 12, color: Color(0x11000000), offset: Offset(0, 6)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text("Goal", style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(_rp(target),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          const SizedBox(height: 12),
                          const Text("Amount Saved", style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(_rp(saved),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: widget.primaryColor,
                              )),
                        ]),
                      ),
                      Container(
                        height: 64,
                        width: 64,
                        decoration: BoxDecoration(
                          color: widget.primaryColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(Icons.savings_outlined, color: widget.primaryColor, size: 34),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: const [
                      BoxShadow(blurRadius: 12, color: Color(0x11000000), offset: Offset(0, 6)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Goals", style: TextStyle(fontWeight: FontWeight.bold)),
                          Icon(Icons.calendar_month, color: widget.primaryColor),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Container(
                            height: 44,
                            width: 44,
                            decoration: BoxDecoration(
                              color: widget.primaryColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(Icons.laptop_mac, color: widget.primaryColor),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(goalName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(startDate,
                                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                          Text(_rp(saved), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),

                      const SizedBox(height: 14),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2FFFE),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedGoalId,
                            isExpanded: true,
                            items: goalsDocs.map((d) {
                              final name = (d.data()["name"] ?? "Goal").toString();
                              return DropdownMenuItem(
                                value: d.id,
                                child: Text(name, overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            onChanged: (v) {
                              if (v == null) return;
                              setState(() => selectedGoalId = v);
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddTransactionPage(
                                  isGoals: true,
                                  goalId: selectedGoalId,
                                  selectedCategoryName: "Goals",
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            "Add Progress",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                const Text(
                  "Progress History",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),

                if (pdocs.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text("Belum ada progress.", style: TextStyle(color: Colors.grey[700])),
                  ),

                ...pdocs.map((d) {
                  final data = d.data();
                  final desc = (data["description"] ?? "Progress").toString();
                  final date = (data["date"] ?? "-").toString();
                  final amount = (data["amount"] ?? 0) as num;

                  return Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(blurRadius: 10, color: Color(0x11000000), offset: Offset(0, 5)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 44,
                          width: 44,
                          decoration: BoxDecoration(
                            color: widget.primaryColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(Icons.flag, color: widget.primaryColor),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(desc, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ]),
                        ),

                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "+${_rp(amount)}",
                              style: TextStyle(
                                color: widget.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 6),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                              onPressed: () => _confirmDeleteProgress(
                                context,
                                goalId: selectedDoc.id,
                                progressId: d.id,
                              ),
                              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 20),
              ],
            );
          },
        );
      },
    );
  }

  static Widget _infoCard({
    required Color primary,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(blurRadius: 12, color: Color(0x11000000), offset: Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.flag_outlined, color: primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Colors.black54)),
            ]),
          ),
        ],
      ),
    );
  }

  static String _rp(num n) {
    final s = n.toInt().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idxFromEnd = s.length - i;
      buf.write(s[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) buf.write('.');
    }
    return "Rp $buf";
  }
}
