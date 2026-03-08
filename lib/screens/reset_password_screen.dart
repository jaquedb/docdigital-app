import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {

  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {

  final TextEditingController codigoController = TextEditingController();
  final TextEditingController novaSenhaController = TextEditingController();
  final TextEditingController confirmarSenhaController = TextEditingController();

  bool mostrarNovaSenha = false;
  bool mostrarConfirmarSenha = false;

  Future<void> redefinirSenha() async {

    String codigo = codigoController.text;
    String novaSenha = novaSenhaController.text;
    String confirmarSenha = confirmarSenhaController.text;

    if (codigo.isEmpty || novaSenha.isEmpty || confirmarSenha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha todos os campos")),
      );
      return;
    }

    if (novaSenha != confirmarSenha) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("As senhas não coincidem")),
      );
      return;
    }

    try {

      await AuthService.resetPassword(
        widget.email,
        codigo,
        novaSenha,
      );

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Senha redefinida"),
            content: const Text("Sua senha foi redefinida com sucesso."),
            actions: [
              TextButton(
                onPressed: () {

                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                        (route) => false,
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
        const SnackBar(content: Text("Erro ao redefinir senha")),
      );

    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Container(

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0B0F1A),
              Color(0xFF111827),
              Color(0xFF000000),
            ],
          ),
        ),

        child: Stack(
          alignment: Alignment.center,
          children: [

            Opacity(
              opacity: 0.08,
              child: Image.asset(
                "assets/images/cadeado.png",
                width: 300,
              ),
            ),

            Center(
              child: SingleChildScrollView(
                child: SizedBox(
                  width: 350,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(

                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [

                        const Text(
                          "Redefinir senha",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          "Digite o código recebido e crie sua nova senha",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 40),

                        TextField(
                          controller: codigoController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: "Código",
                            labelStyle: TextStyle(color: Colors.white70),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white30),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        TextField(
                          controller: novaSenhaController,
                          obscureText: !mostrarNovaSenha,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: "Nova senha (6 números)",
                            labelStyle: const TextStyle(color: Colors.white70),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white30),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                mostrarNovaSenha
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.white70,
                              ),
                              onPressed: () {
                                setState(() {
                                  mostrarNovaSenha = !mostrarNovaSenha;
                                });
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        TextField(
                          controller: confirmarSenhaController,
                          obscureText: !mostrarConfirmarSenha,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: "Confirmar senha",
                            labelStyle: const TextStyle(color: Colors.white70),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white30),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                mostrarConfirmarSenha
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.white70,
                              ),
                              onPressed: () {
                                setState(() {
                                  mostrarConfirmarSenha =
                                  !mostrarConfirmarSenha;
                                });
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: redefinirSenha,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text("REDEFINIR SENHA"),
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}