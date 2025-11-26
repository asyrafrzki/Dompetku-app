import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:dompetku/presentation/pages/profile/edit_profile_page.dart';
import 'package:dompetku/presentation/widgets/logout_confirmation_dialog.dart';
import 'package:dompetku/presentation/pages/auth/login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF07BEB8);
    const Color secondaryColor = Color(0xFFF8FFF2);

    return Scaffold(
      backgroundColor: primaryColor,
      body: Column(
        children: [
          const _ProfileHeader(primaryColor: primaryColor),

          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: ListView(
                padding:
                const EdgeInsets.only(top: 100, left: 20, right: 20),
                children: [
                  // ITEM EDIT PROFILE
                  _ProfileMenuItem(
                    icon: Icons.edit_note,
                    title: 'Edit Profile',
                    color: primaryColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const EditProfilePage()),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // ITEM LOGOUT
                  _ProfileMenuItem(
                    icon: Icons.logout,
                    title: 'Logout',
                    color: primaryColor,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return LogoutConfirmationDialog(
                            onLogoutConfirmed: () => _logout(context),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

// ---------------------- PROFILE HEADER ----------------------
class _ProfileHeader extends StatelessWidget {
  final Color primaryColor;

  const _ProfileHeader({required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    final double headerHeight =
        MediaQuery.of(context).size.height * 0.35;

    return Container(
      width: double.infinity,
      height: headerHeight,
      color: primaryColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + 10),
          const Text(
            'Profile',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 50, color: Colors.grey),
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
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ---------------------- PROFILE MENU ITEM ----------------------
class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 15),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
