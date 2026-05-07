import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawvera/pages/home.dart';
import 'package:pawvera/pages/service%20provider%20dashboard%20pages/service_provider_dashboard.dart';
import 'package:pawvera/pages/pet_supplies_store_dashboard.dart';
import '../components/role_button.dart'; // تأكد أن هذا الملف لا يزال موجوداً

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final userEmailController = TextEditingController();
  final passwordController = TextEditingController();

  String activeRole = "Pet Owner";
  String? selectedProviderType;

  List<String> providerTypes = [
    "Pet Supplies Store",
    "Services Provider Shop",
    "Vet Clinic Admin",
    "Doctor Staff",
  ];

  @override
  void dispose() {
    userEmailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // دالة تسجيل الدخول عبر Firebase
  Future<void> loginUser() async {
    // إظهار مؤشر تحميل
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 1. تسجيل الدخول في Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: userEmailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // 2. التحقق من دور المستخدم في Firestore للتأكد من صلاحياته
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      // إغلاق مؤشر التحميل
      if (mounted) Navigator.pop(context);

      if (mounted) {
        if (userDoc.exists) {
          // التحقق من توافق الدور المختار مع الدور في قاعدة البيانات (اختياري)
          // String dbRole = userDoc.get('role');

          if (activeRole == "Pet Owner") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Home()),
            );
          } else if (activeRole == "Provider") {
            if (selectedProviderType == "Pet Supplies Store") {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const PetSuppliesStoreDashboard()),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => ServiceProviderDashboard(
                      providerType: selectedProviderType!,
                    )),
              );
            }
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User data not found")),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Authentication failed")),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  // --- Widget بديل لـ MyTextfields المحذوف ---
  Widget buildTextField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF5B9D8E), width: 2),
        ),
      ),
    );
  }

  // --- Widget بديل لـ MyButton المحذوف ---
  Widget buildLoginButton({required VoidCallback onTap, required String text}) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5B9D8E), // اللون الأخضر حسب Figma
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              "Welcome",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF634732),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Email
          const Text(
            "Email",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          buildTextField(
            controller: userEmailController,
            hintText: "your@email.com",
            obscureText: false,
          ),

          const SizedBox(height: 15),

          // Password
          const Text(
            "Password",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          buildTextField(
            controller: passwordController,
            hintText: '********',
            obscureText: true,
          ),

          const SizedBox(height: 20),

          // Login as Title
          const Text(
            "Login as",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: RoleButton(
                  role: "Pet Owner",
                  isSelected: activeRole == "Pet Owner",
                  onTap: () {
                    setState(() {
                      activeRole = "Pet Owner";
                      selectedProviderType = null;
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: RoleButton(
                  role: "Provider",
                  isSelected: activeRole == "Provider",
                  onTap: () {
                    setState(() {
                      activeRole = "Provider";
                    });
                  },
                ),
              ),
            ],
          ),

          if (activeRole == "Provider") ...[
            const SizedBox(height: 20),
            const Text(
              "Provider Type",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedProviderType,
                  hint: const Text(
                    "Select Provider Type",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: providerTypes.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedProviderType = newValue;
                    });
                  },
                ),
              ),
            ),
          ],

          const SizedBox(height: 25),

          buildLoginButton(
            text: "Login",
            onTap: loginUser,
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey[300])),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "OR",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey[300])),
            ],
          ),

          const SizedBox(height: 15),

          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Home()),
                );
              },
              child: const Text(
                "Continue as Guest",
                style: TextStyle(
                  color: Color(0xFF5B9D8E),
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
