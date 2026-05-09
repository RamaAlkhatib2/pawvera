import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawvera/pages/home.dart';
import 'package:pawvera/pages/service%20provider%20dashboard%20pages/service_provider_dashboard.dart';
import 'package:pawvera/pages/pet_supplies_store_owner_dashboard.dart';
import '../components/role_button.dart';

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

  String? _emailError;
  String? _passwordError;
  String? _providerTypeError;

  final List<String> providerTypes = [
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

  bool _validateInputs() {
    bool isValid = true;
    setState(() {
      _emailError = null;
      _passwordError = null;
      _providerTypeError = null;

      if (userEmailController.text.trim().isEmpty) {
        _emailError = "Email is required";
        isValid = false;
      } else if (!RegExp(
        r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$',
      ).hasMatch(userEmailController.text.trim())) {
        _emailError = "Enter a valid email address";
        isValid = false;
      }

      if (passwordController.text.isEmpty) {
        _passwordError = "Password is required";
        isValid = false;
      } else if (passwordController.text.length < 6) {
        _passwordError = "Password must be at least 6 characters";
        isValid = false;
      }

      if (activeRole == "Provider" && selectedProviderType == null) {
        _providerTypeError = "Please select a provider type";
        isValid = false;
      }
    });
    return isValid;
  }

  Future<void> loginUser() async {
    if (!_validateInputs()) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: userEmailController.text.trim(),
            password: passwordController.text.trim(),
          );

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (mounted) Navigator.pop(context);

      if (!mounted) return;

      if (!userDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("User data not found. Please register again."),
          ),
        );
        return;
      }

      final String dbRole =
          (userDoc.data() as Map<String, dynamic>)['role'] ?? '';
      final String? dbProviderType =
          (userDoc.data() as Map<String, dynamic>)['providerType'];

      // Verify the selected role matches what was registered
      if (activeRole == "Pet Owner" && dbRole != 'pet_owner') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "This account is registered as a Provider. Please select Provider.",
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (activeRole == "Provider" && dbRole != 'provider') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "This account is registered as a Pet Owner. Please select Pet Owner.",
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Verify provider type matches
      if (activeRole == "Provider" &&
          dbProviderType != null &&
          dbProviderType != selectedProviderType) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "This account is registered as '$dbProviderType'. Please select that type.",
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Navigate based on verified role
      if (dbRole == 'pet_owner') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      } else if (dbRole == 'provider') {
        final String providerType =
            dbProviderType ?? selectedProviderType ?? '';
        if (providerType == "Pet Supplies Store") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const PetSuppliesStoreOwnerDashboard(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const ServiceProviderDashboard(),
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        Navigator.pop(context);
        String message;
        switch (e.code) {
          case 'user-not-found':
          case 'invalid-credential':
            message = "No account found with these credentials.";
            break;
          case 'wrong-password':
            message = "Incorrect password. Please try again.";
            setState(() => _passwordError = "Incorrect password");
            break;
          case 'invalid-email':
            message = "The email address is not valid.";
            setState(() => _emailError = "Invalid email address");
            break;
          case 'user-disabled':
            message = "This account has been disabled.";
            break;
          case 'too-many-requests':
            message = "Too many failed attempts. Please try again later.";
            break;
          default:
            message = e.message ?? "Authentication failed";
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    String? errorText,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
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
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : Colors.grey[300]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : const Color(0xFF5B9D8E),
                width: 2,
              ),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              errorText,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Email",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          _buildTextField(
            controller: userEmailController,
            hintText: "your@email.com",
            obscureText: false,
            errorText: _emailError,
            keyboardType: TextInputType.emailAddress,
          ),
          const Padding(
            padding: EdgeInsets.only(top: 4, left: 4),
            child: Text(
              "Must be a valid email (e.g. user@example.com)",
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ),

          const SizedBox(height: 15),

          const Text(
            "Password",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          _buildTextField(
            controller: passwordController,
            hintText: '••••••••',
            obscureText: true,
            errorText: _passwordError,
          ),
          const Padding(
            padding: EdgeInsets.only(top: 4, left: 4),
            child: Text(
              "Min 6 characters · Must contain letters and numbers",
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ),

          const SizedBox(height: 20),

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
                      _providerTypeError = null;
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
                border: Border.all(
                  color: _providerTypeError != null
                      ? Colors.red
                      : Colors.grey[300]!,
                ),
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
                      _providerTypeError = null;
                    });
                  },
                ),
              ),
            ),
            if (_providerTypeError != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Text(
                  _providerTypeError!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],

          const SizedBox(height: 25),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: loginUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B9D8E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Login",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
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
