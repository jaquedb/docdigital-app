import 'package:flutter/material.dart';
import '../widgets/app_background.dart';

class DocumentListScreen extends StatelessWidget {
  const DocumentListScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final documentos = [
      {
        "nome": "RG",
        "categoria": "Documento pessoal",
        "data": "10/03/2026"
      },
      {
        "nome": "CNH",
        "categoria": "Documento veicular",
        "data": "05/03/2026"
      }
    ];

    return Scaffold(

      backgroundColor: Colors.transparent,

      appBar: AppBar(
        title: const Text(
          "Meus Documentos",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0B0F1A),
        elevation: 0,
      ),

      body: AppBackground(

        child: ListView.builder(

          padding: const EdgeInsets.all(16),

          itemCount: documentos.length,

          itemBuilder: (context, index) {

            final doc = documentos[index];

            return Card(

              color: const Color(0xFF1F2937),

              margin: const EdgeInsets.only(bottom: 12),

              child: ListTile(

                leading: const Icon(
                  Icons.description,
                  color: Colors.white,
                ),

                title: Text(
                  doc["nome"]!,
                  style: const TextStyle(color: Colors.white),
                ),

                subtitle: Text(
                  "${doc["categoria"]}\nUpload: ${doc["data"]}",
                  style: const TextStyle(color: Colors.white70),
                ),

                isThreeLine: true,

              ),
            );

          },

        ),

      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),

    );
  }
}