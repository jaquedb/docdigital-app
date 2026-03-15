import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/login_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/document_list_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'services/token_storage.dart';
import 'services/notification_service.dart';
import 'services/auth_service.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.inicializar();

  runApp(const DocDigitalApp());
}

class DocDigitalApp extends StatelessWidget {
  const DocDigitalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DocDigital',
      debugShowCheckedModeBanner: false,

      locale: const Locale('pt', 'BR'),

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: const [
        Locale('pt', 'BR'),
      ],

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
        '/dashboard': (context) => const DashboardScreen(),
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

    if (token != null) {

      final nome = await TokenStorage.obterNome();

      if (nome != null) {
        AuthService.nomeUsuario = nome;
        print("NOME RECUPERADO: $nome");
      }

      return true;
    }

    return false;
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
          return const DashboardScreen();
        } else {
          return const LoginScreen();
        }

      },
    );
  }
}