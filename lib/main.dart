import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // أضفنا هاد المكتبة
import 'package:pawvera/pages/sign_in_page.dart';

void main() async {
  // 1. تأكيد تهيئة الـ Widgets
  WidgetsFlutterBinding.ensureInitialized();

  // 2. تهيئة Hive للعمل على الموبايل
  await Hive.initFlutter();

  // 3. فتح الـ Box المخصص للبيانات (يجب أن يكون نفس الاسم المستخدم في MyPetPage)
  // فتحه هنا يضمن أن كل صفحات التطبيق تستطيع الوصول إليه فوراً
  await Hive.openBox('myBox');

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PawVera',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFFBF6EE),
      ),

      home: const SignInPage(),
    );
  }
}
