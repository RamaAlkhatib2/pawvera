import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:pawvera/controllers/service_provider_controller.dart';
import 'package:pawvera/firebase_options.dart';
import 'package:pawvera/pages/sign_in_page.dart';
import 'package:pawvera/pages/pet_public_profile_page.dart';
import 'package:pawvera/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Hive for mobile
  await Hive.initFlutter();
  await Hive.openBox('myBox');

  // Initialize Notifications
  await NotificationService().init();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  Widget _resolvePage() {
    if (kIsWeb) {
      try {
        // Fragment is everything after '#' — e.g. '/pet/uid123/petId456'
        final fragment = Uri.base.fragment;
        if (fragment.startsWith('/pet/')) {
          final parts = fragment.substring('/pet/'.length).split('/');
          if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
            return PetPublicProfilePage(ownerUid: parts[0], petId: parts[1]);
          }
        }
      } catch (_) {}
    }
    return const SignInPage();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ServiceProviderController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PawVera',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          fontFamily: 'Roboto',
          scaffoldBackgroundColor: const Color(0xFFFBF6EE),
        ),
        home: _resolvePage(),
      ),
    );
  }
}
