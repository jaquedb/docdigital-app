import 'package:flutter/material.dart';
import '../widgets/app_background.dart';

class AddDocumentScreen extends StatelessWidget {
  const AddDocumentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          title: const Text(
            "Adicionar Documento",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF0B0F1A),
          elevation: 0,
        ),

        body: const Center(
          child: Text(
            "Tela de upload do documento",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}