import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {

  final Widget child;
  final bool showWatermark;

  const AppBackground({
    super.key,
    required this.child,
    this.showWatermark = true,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

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

          if (showWatermark)
            Opacity(
              opacity: 0.08,
              child: Image.asset(
                "assets/images/cadeado.jpeg",
                width: 300,
              ),
            ),

          child,

        ],
      ),
    );
  }
}