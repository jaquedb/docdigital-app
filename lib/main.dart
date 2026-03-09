import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/document_list_screen.dart';
import 'screens/register_screen.dart';
import 'services/token_storage.dart';

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

      home: const AuthCheck(),

      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/documentos': (context) => const DocumentListScreen(),
      },
    );
  }
}

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {

  Future<bool> verificarLogin() async {

    final token = await TokenStorage.obterToken();

    print("TOKEN RECUPERADO: $token");

    return token != null;
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder<bool>(
      future: verificarLogin(),

      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.data == true) {
          return const DocumentListScreen();
        } else {
          return const LoginScreen();
        }

      },
    );
  }
}