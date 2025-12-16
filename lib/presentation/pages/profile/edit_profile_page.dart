import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:dompetku/providers/profile_provider.dart';

// ================== WARNA ==================
const Color actionColor = Color(0xFF07BEB8);
const Color backgroundColor = Color(0xFFF8FFF2);
const Color inputFieldColor = Color(0xFFE0F4F2);
const Color errorColor = Colors.red;

// ================== SNACKBAR ==================
void _showSnackBar(
    BuildContext context,
    String title,
    String message,
    Color bgColor,
    IconData icon,
    ) {
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
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title.isNotEmpty)
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  Text(
                    message,
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 13,
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

// ================== INPUT FIELD ==================
class _ProfileInputField extends StatelessWidget {
  final String title;
  final String hintText;
  final TextEditingController controller;
  final bool isEditable;

  const _ProfileInputField({
    required this.title,
    required this.hintText,
    required this.controller,
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
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: inputFieldColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: controller,
              readOnly: !isEditable,
              style: GoogleFonts.poppins(),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: GoogleFonts.poppins(color: Colors.grey.shade600),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================== HEADER (FIX OVERFLOW LANDSCAPE) ==================
class _EditProfileHeader extends StatelessWidget {
  final String userName;

  const _EditProfileHeader({required this.userName});

  @override
  Widget build(BuildContext context) {
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    // Tinggi landscape jangan kekecilan (biar aman dari overflow)
    final double height = isLandscape ? 190 : 260;

    return Container(
      height: height,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: actionColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(45),
          bottomRight: Radius.circular(45),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Top bar
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Edit My Profile',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: isLandscape ? 16 : 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // biar center bener
                ],
              ),

              SizedBox(height: isLandscape ? 8 : 18),

              // Avatar + Name
              CircleAvatar(
                radius: isLandscape ? 26 : 42,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: isLandscape ? 30 : 48,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                userName.isNotEmpty ? userName : 'Pengguna',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: isLandscape ? 14 : 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================== PAGE ==================
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileProvider>(context, listen: false).fetchProfileData();
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _updateUsername(BuildContext context) async {
    final provider = Provider.of<ProfileProvider>(context, listen: false);
    final name = _usernameController.text.trim();

    if (name.isEmpty) {
      _showSnackBar(
        context,
        'Perhatian',
        'Username tidak boleh kosong',
        Colors.orange,
        Icons.warning,
      );
      return;
    }

    final error = await provider.updateUsername(name);

    if (error == null) {
      _showSnackBar(
        context,
        'Sukses',
        'Username berhasil diperbarui',
        actionColor,
        Icons.check_circle,
      );
    } else {
      _showSnackBar(
        context,
        'Gagal',
        error,
        errorColor,
        Icons.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, _) {
        // isi controller sekali saat data sudah kebaca
        if (_usernameController.text.isEmpty &&
            provider.currentUserName != 'Loading.') {
          _usernameController.text = provider.currentUserName;
        }

        if (provider.isLoading && provider.currentUserName == 'Loading.') {
          return const Scaffold(
            backgroundColor: backgroundColor,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: backgroundColor,
          body: SafeArea(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _EditProfileHeader(userName: provider.currentUserName),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 25, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account Settings',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _ProfileInputField(
                        title: 'Username',
                        hintText: 'Masukkan username',
                        controller: _usernameController,
                        isEditable: true,
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: provider.isLoading
                              ? null
                              : () => _updateUsername(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: actionColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: provider.isLoading
                              ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                              : Text(
                            'Update Profile',
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
