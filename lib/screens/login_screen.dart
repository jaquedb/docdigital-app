import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  bool carregando = false;
  bool senhaVisivel = false;

  Future<void> fazerLogin() async {

    if (carregando) return;

    final email = emailController.text.trim();
    final senha = senhaController.text;

    if (email.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Informe email e senha")),
      );
      return;
    }

    setState(() {
      carregando = true;
    });

    try {

      await AuthService.login(email, senha);

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/dashboard');

    } catch (e) {

      String mensagem = e.toString();

      if (mensagem.startsWith("Exception: ")) {
        mensagem = mensagem.replaceFirst("Exception: ", "");
      }

      // 🔥 TRATAMENTO INTELIGENTE
      if (mensagem.contains("Email não verificado")) {

        if (!mounted) return;

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Confirmação necessária"),
            content: const Text(
                "Seu email ainda não foi verificado. Deseja confirmar agora?"
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);

                  Navigator.pushNamed(
                    context,
                    '/confirmar-cadastro',
                    arguments: {
                      "email": email,
                      "senha": senha,
                      "reenviar": true, // 🔥 ESSA LINHA É A CHAVE
                    },
                  );
                },
                child: const Text("Confirmar"),
              ),
            ],
          ),
        );

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensagem),
          ),
        );

      }

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
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                      isAntiAlias: true,
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      "Bem-vindo ao DocDigital",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 40),

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

                    const SizedBox(height: 20),

                    TextField(
                      controller: senhaController,
                      obscureText: !senhaVisivel,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Senha",
                        hintText: "(6 dígitos)",
                        hintStyle: const TextStyle(color: Colors.white54),
                        labelStyle: const TextStyle(color: Colors.white70),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white30),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            senhaVisivel ? Icons.visibility : Icons.visibility_off,
                            color: Colors.white70,
                          ),
                          onPressed: () {
                            setState(() {
                              senhaVisivel = !senhaVisivel;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/forgot-password');
                        },
                        child: const Text(
                          "Esqueceu a senha?",
                          style: TextStyle(
                            color: Colors.white70,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: carregando ? null : fazerLogin,
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
                            : const Text("ENTRAR"),
                      ),
                    ),

                    const SizedBox(height: 25),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        const Text(
                          "Não tem uma conta? ",
                          style: TextStyle(color: Colors.white70),
                        ),

                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: const Text(
                            "Cadastre-se",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),

                      ],
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