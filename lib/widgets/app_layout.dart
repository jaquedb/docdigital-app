import 'package:flutter/material.dart';

class AppLayout extends StatelessWidget {
  final Widget child;

  const AppLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [

        // FUNDO COM DEGRADÊ
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.3),
              radius: 1.2,
              colors: [
                Color(0xFF1A2333),
                Color(0xFF0B0F1A),
                Color(0xFF000000),
              ],
            ),
          ),
        ),

        // CADEADO COMO MARCA D'ÁGUA
        Center(
          child: Opacity(
            opacity: 0.05,
            child: Image.asset(
              "assets/images/cadeado.jpeg",
              width: 280,
            ),
          ),
        ),

        // CONTEÚDO DAS TELAS
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}