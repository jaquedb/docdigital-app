import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/document_list_screen.dart';

void main() {
  runApp(const DocDigitalApp());
}

class DocDigitalApp extends StatelessWidget {
  const DocDigitalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DocDigital',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),

      initialRoute: '/documentos',

      routes: {
        '/login': (context) => const LoginScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/documentos': (context) => const DocumentListScreen(),
      },
    );
  }
}