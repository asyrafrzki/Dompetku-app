import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dompetku/providers/profile_provider.dart';
import 'package:provider/provider.dart';

const Color actionColor = Color(0xFF07BEB8);
const Color backgroundColor = Color(0xFFF8FFF2);
const Color inputFieldColor = Color(0xFFE0F4F2);
const Color errorColor = Colors.red;

void _showSnackBar(BuildContext context, String title, String message, Color bgColor, IconData icon) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(20),
      duration: const Duration(seconds: 2),
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: bgColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title.isNotEmpty)
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  Text(
                    message,
                    style: GoogleFonts.poppins(
                      fontSize: title.isNotEmpty ? 12 : 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ProfileInputField extends StatelessWidget {
  final String title;
  final String? initialValue;
  final String hintText;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final bool isEditable;

  const _ProfileInputField({
    required this.title,
    this.initialValue,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.isEditable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: isEditable ? inputFieldColor : inputFieldColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextFormField(
              controller: controller,
              initialValue: controller == null ? initialValue : null,
              readOnly: !isEditable,
              keyboardType: keyboardType,
              style: GoogleFonts.poppins(color: Colors.black87),
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditProfileHeader extends StatelessWidget {
  final String userName;

  const _EditProfileHeader({required this.userName});

  @override
  Widget build(BuildContext context) {
    final double headerHeight = MediaQuery.of(context).size.height * 0.30;

    return Container(
      width: double.infinity,
      height: headerHeight,
      decoration: BoxDecoration(
        color: actionColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: Column(
        children: [
          // Row Navigasi
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              left: 10,
              right: 10,
              bottom: 20,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Edit My Profile',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 48), // Padding kanan untuk menyeimbangkan tombol kembali
              ],
            ),
          ),

          Column(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 50, color: Colors.grey),
              ),
              const SizedBox(height: 5),
              Text(
                userName.isNotEmpty ? userName : 'Pengguna',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


// --- WIDGET UTAMA (MENGGUNAKAN PROVIDER UNTUK STATE MANAGEMENT) ---
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Controller lokal (TIDAK LAGI GLOBAL)
  final TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Panggil fungsi inisialisasi di Provider setelah widget dibangun
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ProfileProvider>(context, listen: false);
      // Jika data belum dimuat, panggil fetchProfileData
      if (provider.currentUserName == 'Loading...') {
        provider.fetchProfileData();
      }
    });
  }

  // Fungsi untuk menginisialisasi controller setelah data dari provider siap
  void _initializeController(ProfileProvider provider) {
    // Isi controller hanya jika kosong (pertama kali load) dan data sudah siap
    if (_usernameController.text.isEmpty && provider.currentUserName != 'Loading...' && provider.currentUserName != 'Not Logged In') {
      _usernameController.text = provider.currentUserName;
    }
  }

  // Fungsi update yang memanggil Provider
  Future<void> _updateUsernameFromUI(BuildContext context) async {
    final provider = Provider.of<ProfileProvider>(context, listen: false);
    final newName = _usernameController.text.trim();

    // Validasi sederhana
    if (newName.isEmpty) {
      _showSnackBar(context, "Perhatian", "Nama pengguna tidak boleh kosong.", Colors.orange, Icons.warning_amber_rounded);
      return;
    }
    if (newName == provider.currentUserName) {
      _showSnackBar(context, "Info", "Tidak ada perubahan nama.", actionColor, Icons.info_outline);
      return;
    }

    // Panggil logika update di Provider
    final errorMessage = await provider.updateUsername(newName);

    if (errorMessage == null) {
      _showSnackBar(context, "Sukses", "Nama pengguna berhasil diperbarui!", actionColor, Icons.check_circle_outline);
      // Data sudah otomatis diperbarui di Provider, Header akan rebuild.
    } else {
      _showSnackBar(context, "Update Gagal", errorMessage, errorColor, Icons.cloud_off);
    }
  }


  @override
  void dispose() {
    _usernameController.dispose(); // Dispose controller lokal
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Consumer mendengarkan perubahan state dari ProfileProvider
    return Consumer<ProfileProvider>(
      builder: (context, provider, child) {

        // Inisialisasi controller hanya jika provider sudah selesai loading
        _initializeController(provider);

        // --- Status Loading Penuh ---
        if (provider.isLoading && provider.currentUserName == 'Loading...') {
          return Scaffold(
            backgroundColor: backgroundColor,
            body: Center(child: CircularProgressIndicator(color: actionColor)),
          );
        }

        // --- Data Siap ---
        String currentUserName = provider.currentUserName;
        bool isUpdating = provider.isLoading;

        // Ambil email dari Auth instance karena tidak perlu dimasukkan ke Provider
        final userEmail = FirebaseAuth.instance.currentUser?.email ?? 'Tidak Tersedia';

        return Scaffold(
          backgroundColor: backgroundColor,
          body: Column(
            children: [
              // HEADER (Menggunakan data dari Provider)
              _EditProfileHeader(userName: currentUserName),

              // BODY FORM
              Expanded(
                child: Container(
                  color: backgroundColor,
                  child: ListView(
                    padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 40),
                    children: [
                      Text(
                        'Account Settings',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // FIELD 1: USERNAME
                      _ProfileInputField(
                        title: 'Username',
                        hintText: 'Masukkan nama pengguna baru',
                        isEditable: true,
                        controller: _usernameController,
                      ),

                      // FIELD 2: EMAIL ADDRESS
                      _ProfileInputField(
                        title: 'Email Address',
                        initialValue: userEmail,
                        hintText: 'Email Anda (Placeholder)',
                        keyboardType: TextInputType.emailAddress,
                        isEditable: false,
                      ),

                      const SizedBox(height: 40),

                      // TOMBOL UPDATE
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isUpdating ? null : () => _updateUsernameFromUI(context), // Nonaktifkan saat updating
                          style: ElevatedButton.styleFrom(
                            backgroundColor: actionColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: isUpdating
                              ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                              : Text(
                            'Update Profile',
                            style: GoogleFonts.poppins(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}