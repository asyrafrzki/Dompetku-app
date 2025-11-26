import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'login_page.dart';
import 'signup_page.dart';

class PilihanLogin extends StatelessWidget {
  const PilihanLogin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFF2),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              Hero(
                tag: "app_logo",
                child: Image.asset(
                  "assets/images/logo.png",
                  width: 400,
                  height: 250,
                ),
              ),

              const SizedBox(height: 8),
              Text(
                "DompetKu",
                style: GoogleFonts.poppins(
                  fontSize: 42,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF4F6F52),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  // Warna tombol Log In: 07BEB8
                  backgroundColor: const Color(0xFF07BEB8),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    // Bentuk bulat
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                  shadowColor: Colors.black.withOpacity(0.2),
                ),
                child: Text(
                  "Log In",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Tombol Sign Up (Warna: 07BEB8, Bentuk: Bulat)
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignUpPage()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  // Border Side: 07BEB8
                  side: const BorderSide(color: Color(0xFF07BEB8), width: 1.5),
                  shape: RoundedRectangleBorder(
                    // Bentuk bulat
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  "Sign Up",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    // Text Color: 07BEB8
                    color: const Color(0xFF07BEB8),
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}