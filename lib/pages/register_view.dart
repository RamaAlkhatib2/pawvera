import 'package:flutter/material.dart';
import '../components/my_textfields.dart';
import '../components/my_button.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  String? selectedCountry;
  List<String> countries = [
    "Jordan",
    "Saudi Arabia",
    "UAE",
    "Egypt",
    "Palestine",
  ];

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
          MyTextfields(
            controller: TextEditingController(),
            hitnText: "John Doe",
            obscureText: false,
          ),

          const SizedBox(height: 15),
          _buildLabel("Username"),
          MyTextfields(
            controller: TextEditingController(),
            hitnText: "johndoe",
            obscureText: false,
          ),

          const SizedBox(height: 15),
          _buildLabel("Country"),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedCountry,
                hint: const Text(
                  "Select your country",
                  style: TextStyle(fontSize: 14),
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
          MyTextfields(
            controller: TextEditingController(),
            hitnText: "your@email.com",
            obscureText: false,
          ),

          const SizedBox(height: 15),
          _buildLabel("Phone Number"),
          MyTextfields(
            controller: TextEditingController(),
            hitnText: "+962 7X XXX XXXX",
            obscureText: false,
          ),

          const SizedBox(height: 15),
          _buildLabel("Password"),
          MyTextfields(
            controller: TextEditingController(),
            hitnText: "********",
            obscureText: true,
          ),

          const SizedBox(height: 25),

          MyButton(onTap: () {}, text: "Register"),
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
