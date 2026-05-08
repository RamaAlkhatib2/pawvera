import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/role_button.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final fullNameController = TextEditingController();
  final userNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final countryCodeController = TextEditingController(text: '+962');
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? selectedCountry = "Jordan";
  String activeRole = "Pet Owner";
  String? selectedProviderType;

  static const Map<String, String> _countryCodes = {
    "Jordan": "+962",
    "Saudi Arabia": "+966",
    "UAE": "+971",
    "Egypt": "+20",
    "Palestine": "+970",
  };

  final List<String> countries = [
    "Jordan",
    "Saudi Arabia",
    "UAE",
    "Egypt",
    "Palestine",
  ];

  final List<String> providerTypes = [
    "Pet Supplies Store",
    "Services Provider Shop",
    "Vet Clinic Admin",
    "Doctor Staff",
  ];

  // Validation error messages
  String? _fullNameError;
  String? _userNameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _providerTypeError;

  @override
  void dispose() {
    fullNameController.dispose();
    userNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    countryCodeController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    bool isValid = true;
    setState(() {
      _fullNameError = null;
      _userNameError = null;
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
      _providerTypeError = null;

      if (fullNameController.text.trim().isEmpty) {
        _fullNameError = "Full name is required";
        isValid = false;
      }

      if (userNameController.text.trim().isEmpty) {
        _userNameError = "Username is required";
        isValid = false;
      }

      final email = emailController.text.trim();
      if (email.isEmpty) {
        _emailError = "Email is required";
        isValid = false;
      } else if (!RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
        _emailError = "Enter a valid email address (e.g. user@example.com)";
        isValid = false;
      }

      final password = passwordController.text;
      if (password.isEmpty) {
        _passwordError = "Password is required";
        isValid = false;
      } else if (password.length < 6) {
        _passwordError = "Password must be at least 6 characters";
        isValid = false;
      } else if (!RegExp(r'[A-Za-z]').hasMatch(password) ||
          !RegExp(r'[0-9]').hasMatch(password)) {
        _passwordError = "Password must contain letters and numbers";
        isValid = false;
      }

      if (confirmPasswordController.text.isEmpty) {
        _confirmPasswordError = "Please confirm your password";
        isValid = false;
      } else if (confirmPasswordController.text != passwordController.text) {
        _confirmPasswordError = "Passwords do not match";
        isValid = false;
      }

      if (activeRole == "Provider" && selectedProviderType == null) {
        _providerTypeError = "Please select a provider type";
        isValid = false;
      }
    });
    return isValid;
  }

  Future<void> registerUser() async {
    if (!_validateInputs()) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final Map<String, dynamic> userData = {
        'uid': userCredential.user!.uid,
        'fullName': fullNameController.text.trim(),
        'userName': userNameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': '${countryCodeController.text.trim()} ${phoneController.text.trim()}',
        'country': selectedCountry,
        'role': activeRole == "Pet Owner" ? 'pet_owner' : 'provider',
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (activeRole == "Provider") {
        userData['providerType'] = selectedProviderType;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userData);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Account created successfully!"),
            backgroundColor: Color(0xFF5B9D8E),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        Navigator.pop(context);
        String message;
        switch (e.code) {
          case 'email-already-in-use':
            message = "This email is already registered. Please login instead.";
            setState(() => _emailError = message);
            break;
          case 'invalid-email':
            message = "The email address is not valid.";
            setState(() => _emailError = message);
            break;
          case 'weak-password':
            message = "Password is too weak. Use at least 6 characters with letters and numbers.";
            setState(() => _passwordError = message);
            break;
          default:
            message = e.message ?? "An error occurred";
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
        }
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          _buildLabel("Full Name"),
          _buildTextField(
            controller: fullNameController,
            hintText: "John Doe",
            obscureText: false,
            errorText: _fullNameError,
          ),

          const SizedBox(height: 15),
          _buildLabel("Username"),
          _buildTextField(
            controller: userNameController,
            hintText: "johndoe",
            obscureText: false,
            errorText: _userNameError,
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
                isExpanded: true,
                items: countries.map((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedCountry = newValue;
                    countryCodeController.text =
                        _countryCodes[newValue] ?? countryCodeController.text;
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 15),
          _buildLabel("Email"),
          _buildTextField(
            controller: emailController,
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
          _buildLabel("Phone Number"),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                // Country code field
                SizedBox(
                  width: 75,
                  child: TextField(
                    controller: countryCodeController,
                    keyboardType: TextInputType.phone,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                    ),
                  ),
                ),
                // Vertical divider
                Container(
                  width: 1,
                  height: 28,
                  color: Colors.grey[300],
                ),
                // Local number field
                Expanded(
                  child: TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '7X XXX XXXX',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),
          _buildLabel("Password"),
          _buildTextField(
            controller: passwordController,
            hintText: "••••••••",
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

          const SizedBox(height: 15),
          _buildLabel("Confirm Password"),
          _buildTextField(
            controller: confirmPasswordController,
            hintText: "••••••••",
            obscureText: true,
            errorText: _confirmPasswordError,
          ),

          const SizedBox(height: 20),

          // Role selection
          const Text(
            "Register as",
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
            const SizedBox(height: 15),
            const Text(
              "Provider Type",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _providerTypeError != null ? Colors.red : Colors.grey[300]!,
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
                    return DropdownMenuItem<String>(value: value, child: Text(value));
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
              onPressed: registerUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B9D8E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Create Account",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
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
