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
  bool carregando = false;

  Future<void> redefinirSenha() async {

    if (carregando) return;

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

    if (novaSenha.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("A senha deve ter 6 números")),
      );
      return;
    }

    setState(() {
      carregando = true;
    });

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

            Positioned(
              top: 40,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ),

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
                          keyboardType: TextInputType.number,
                          maxLength: 6,
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
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: "Nova senha",
                            helperText: "A senha deve conter 6 números",
                            helperStyle: const TextStyle(color: Colors.white54),
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
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: "Confirmar senha",
                            helperText: "Digite novamente os 6 números",
                            helperStyle: const TextStyle(color: Colors.white54),
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
                            onPressed: carregando ? null : redefinirSenha,
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
                                : const Text("REDEFINIR SENHA"),
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