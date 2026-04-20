import 'package:flutter/material.dart';
import 'package:pawvera/pages/home.dart';
import 'package:pawvera/pages/service_provider_dashboard.dart';
import '../components/my_button.dart';
import '../components/my_textfields.dart';
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
          MyTextfields(
            controller: userEmailController,
            hitnText: "your@email.com",
            obscureText: false,
          ),

          const SizedBox(height: 15),

          // Password
          const Text(
            "Password",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          MyTextfields(
            controller: passwordController,
            hitnText: '********',
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

          MyButton(
            onTap: () {
              if (activeRole == "Pet Owner") {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Home()),
                );
              } else if (activeRole == "Provider") {
                if (selectedProviderType == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select a provider type'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ServiceProviderDashboard(
                        providerType: selectedProviderType!,
                      ),
                    ),
                  );
                }
              }
            },
            text: "Login",
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
              onPressed: () {},
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
