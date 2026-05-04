import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  // تعريف Controllers لكل حقل لضمان عملها بشكل صحيح
  final fullNameController = TextEditingController();
  final userNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  String? selectedCountry;
  List<String> countries = [
    "Jordan",
    "Saudi Arabia",
    "UAE",
    "Egypt",
    "Palestine",
  ];

  @override
  void dispose() {
    // تنظيف الـ Controllers عند إغلاق الصفحة
    fullNameController.dispose();
    userNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // دالة التسجيل في Firebase
  Future<void> registerUser() async {
    // إظهار مؤشر تحميل
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 1. إنشاء الحساب في Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // 2. حفظ بيانات المستخدم الإضافية في Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'uid': userCredential.user!.uid,
        'fullName': fullNameController.text.trim(),
        'userName': userNameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'country': selectedCountry,
        'role': 'adopter', // القيمة الافتراضية
        'createdAt': FieldValue.serverTimestamp(),
      });

      // إغلاق مؤشر التحميل
      if (mounted) Navigator.pop(context);

      // (اختياري) الانتقال للصفحة الرئيسية أو تسجيل الدخول
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account created successfully!")),
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "An error occurred")),
      );
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // --- Widget داخلي بديل لـ MyTextfields ---
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

  // --- Widget داخلي بديل لـ MyButton ---
  Widget buildRegisterButton({
    required VoidCallback onTap,
    required String text,
  }) {
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
              "Create Account",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF634732),
              ),
            ),
          ),
          const SizedBox(height: 20),

          _buildLabel("Full Name"),
          buildTextField(
            controller: fullNameController,
            hintText: "John Doe",
            obscureText: false,
          ),

          const SizedBox(height: 15),
          _buildLabel("Username"),
          buildTextField(
            controller: userNameController,
            hintText: "johndoe",
            obscureText: false,
          ),

          const SizedBox(height: 15),
          _buildLabel("Country"),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedCountry,
                hint: const Text(
                  "Select your country",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                isExpanded: true,
                items: countries.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedCountry = newValue;
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 15),
          _buildLabel("Email"),
          buildTextField(
            controller: emailController,
            hintText: "your@email.com",
            obscureText: false,
          ),

          const SizedBox(height: 15),
          _buildLabel("Phone Number"),
          buildTextField(
            controller: phoneController,
            hintText: "+962 7X XXX XXXX",
            obscureText: false,
          ),

          const SizedBox(height: 15),
          _buildLabel("Password"),
          buildTextField(
            controller: passwordController,
            hintText: "********",
            obscureText: true,
          ),

          const SizedBox(height: 25),

          buildRegisterButton(
            onTap: registerUser,
            text: "Register",
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }
}
