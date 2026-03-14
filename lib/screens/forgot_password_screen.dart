import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/app_background.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {

  final TextEditingController emailController = TextEditingController();
  bool carregando = false;

  Future<void> enviarCodigo() async {

    if (carregando) return;

    String email = emailController.text;

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Digite um email válido")),
      );
      return;
    }

    setState(() {
      carregando = true;
    });

    try {

      final response = await AuthService.forgotPassword(email);

      final codigo = response["codigo"];

      print("Código recebido: $codigo");

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Código para redefinição de senha"),
            content: Text(
              "Seu código de recuperação é:\n\n$codigo\n\nUse este código na próxima tela para redefinir sua senha.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResetPasswordScreen(email: email),
                    ),
                  );
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao enviar código")),
      );

    } finally {

      if (mounted) {
        setState(() {
          carregando = false;
        });
      }

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recuperar senha"),
        backgroundColor: const Color(0xFF0B0F1A),
      ),
      body: AppBackground(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const SizedBox(height: 40),

            const Text(
              "Digite seu email para receber o código de recuperação",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            TextField(
              controller: emailController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Email",
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: carregando ? null : enviarCodigo,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: carregando
                    ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text("ENVIAR"),
              ),
            ),

          ],
        ),
      ),
    );
  }
}