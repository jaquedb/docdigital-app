import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ConfirmarCadastroScreen extends StatefulWidget {
  const ConfirmarCadastroScreen({super.key});

  @override
  State<ConfirmarCadastroScreen> createState() => _ConfirmarCadastroScreenState();
}

class _ConfirmarCadastroScreenState extends State<ConfirmarCadastroScreen> {

  final TextEditingController codigoController = TextEditingController();

  bool carregando = false;
  bool jaEnviouAutomatico = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!jaEnviouAutomatico) {

      final args = ModalRoute.of(context)!.settings.arguments as Map;

      final email = args["email"] as String;
      final reenviar = args["reenviar"] ?? false;

      if (reenviar == true) {
        _reenviarCodigoAutomatico(email);
      }

      jaEnviouAutomatico = true;
    }
  }

  Future<void> _reenviarCodigoAutomatico(String email) async {
    try {
      await AuthService.reenviarCodigo(email);
    } catch (_) {
      // não mostra erro automático (UX limpa)
    }
  }

  Future<void> confirmar(String email, String senha) async {

    if (carregando) return;

    final codigo = codigoController.text;

    if (codigo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Digite o código")),
      );
      return;
    }

    setState(() {
      carregando = true;
    });

    try {

      await AuthService.confirmarCadastro(email, codigo);

      // LOGIN AUTOMÁTICO
      await AuthService.login(email, senha);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cadastro confirmado com sucesso")),
      );

      Navigator.pushReplacementNamed(context, '/documentos');

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Código inválido ou expirado")),
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

    final args = ModalRoute.of(context)!.settings.arguments as Map;

    final email = args["email"] as String;
    final senha = args["senha"] as String;

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

        child: Center(
          child: SingleChildScrollView(
            child: SizedBox(
              width: 350,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Image.asset(
                      "assets/images/logo_docdigital.png",
                      height: 120,
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      "Confirmar cadastro",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Digite o código enviado para seu email",
                      style: TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 10),

                    Text(
                      email,
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),

                    const SizedBox(height: 30),

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

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: carregando ? null : () => confirmar(email, senha),
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
                            : const Text("CONFIRMAR"),
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}