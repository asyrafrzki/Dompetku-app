import 'package:flutter/material.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF07BEB8);
    const Color secondaryColor = Color(0xFFF8FFF2);

    return Scaffold(
      backgroundColor: secondaryColor,
      body: Column(
        children: [
          _EditProfileHeader(
            context: context,
            primaryColor: primaryColor,
            secondaryColor: secondaryColor,
          ),
          Expanded(
            child: Container(
              color: secondaryColor,
              child: ListView(
                padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 40),
                children: [
                  const Text(
                    'Account Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _ProfileInputField(
                    title: 'Username',
                    initialValue: 'John Smith',
                    hintText: 'Masukkan nama pengguna baru',
                  ),
                  _ProfileInputField(
                    title: 'Phone',
                    initialValue: '+62 123456778',
                    hintText: 'Masukkan nomor telepon baru',
                    keyboardType: TextInputType.phone,
                  ),
                  _ProfileInputField(
                    title: 'Email Address',
                    initialValue: 'user@gmail.com',
                    hintText: 'Masukkan email baru',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 40),

                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Update Profile',
                        style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
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
  }
}

class _EditProfileHeader extends StatelessWidget {
  final BuildContext context;
  final Color primaryColor;
  final Color secondaryColor;

  const _EditProfileHeader({
    required this.context,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final double headerHeight = MediaQuery.of(context).size.height * 0.35;

    return Container(
      width: double.infinity,
      height: headerHeight,
      decoration: BoxDecoration(
        color: primaryColor,
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
                const Expanded(
                  child: Center(
                    child: Text(
                      'Edit My Profile',
                      style: TextStyle(
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
          ),

          // Foto Profil & User Text
          Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    const Icon(Icons.person, size: 50, color: Colors.grey),
                    // Edit Icon
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: secondaryColor, width: 2),
                      ),
                      child: const Icon(Icons.edit, color: Colors.white, size: 15),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'User',
                style: TextStyle(
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

// Widget untuk setiap baris input form (Tidak diubah)
class _ProfileInputField extends StatelessWidget {
  final String title;
  final String initialValue;
  final String hintText;
  final TextInputType keyboardType;

  const _ProfileInputField({
    required this.title,
    required this.initialValue,
    required this.hintText,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    const Color inputFieldColor = Color(0xFFE0F4F2);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: inputFieldColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: TextEditingController(text: initialValue),
              keyboardType: keyboardType,
              style: const TextStyle(color: Colors.black87),
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