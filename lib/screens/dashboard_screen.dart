import 'package:flutter/material.dart';
import '../widgets/app_background.dart';
import '../services/document_service.dart';
import '../models/documento.dart';
import 'document_list_screen.dart';
import 'add_document_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  late Future<List<Documento>> documentosFuture;

  @override
  void initState() {
    super.initState();
    documentosFuture = DocumentService.listarDocumentos();
  }

  int? diasParaVencer(Documento doc) {

    if (doc.dataVencimento == null) return null;

    final hoje = DateTime.now();
    final vencimento = DateTime.parse(doc.dataVencimento!);

    final hojeSemHora = DateTime(hoje.year, hoje.month, hoje.day);
    final vencimentoSemHora =
    DateTime(vencimento.year, vencimento.month, vencimento.day);

    return vencimentoSemHora.difference(hojeSemHora).inDays;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.transparent,

      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: const Color(0xFF0B0F1A),
      ),

      body: AppBackground(

        child: FutureBuilder<List<Documento>>(
          future: documentosFuture,

          builder: (context, snapshot) {

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {

              final erro = snapshot.error.toString();

              if (erro.contains("TOKEN_INVALIDO")) {

                Future.microtask(() {
                  Navigator.pushReplacementNamed(context, '/login');
                });

                return const SizedBox();
              }

              return const Center(
                child: Text(
                  "Erro ao carregar dados",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: Text(
                  "Erro ao carregar dados",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            final docs = snapshot.data!;

            int vencidos = 0;
            int venceHoje = 0;
            int venceEmBreve = 0;

            for (var doc in docs) {

              final dias = diasParaVencer(doc);

              if (dias == null) continue;

              if (dias < 0) {
                vencidos++;
              } else if (dias == 0) {
                venceHoje++;
              } else if (dias <= 10) {
                venceEmBreve++;
              }

            }

            return SingleChildScrollView(

              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    const Text(
                      "Resumo dos documentos",
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.3,

                      children: [

                        _cardResumo(
                          "Vencidos",
                          vencidos,
                          Colors.red,
                          Icons.warning,
                        ),

                        _cardResumo(
                          "Vencem hoje",
                          venceHoje,
                          Colors.orange,
                          Icons.today,
                        ),

                        _cardResumo(
                          "Vencem em breve",
                          venceEmBreve,
                          Colors.yellow,
                          Icons.schedule,
                        ),

                        _cardResumo(
                          "Total documentos",
                          docs.length,
                          Colors.blue,
                          Icons.folder,
                        ),

                      ],
                    ),

                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,

                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.folder),
                        label: const Text("VER DOCUMENTOS"),

                        onPressed: () {

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                              const DocumentListScreen(),
                            ),
                          );

                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,

                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text("ADICIONAR DOCUMENTO"),

                        onPressed: () async {

                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                              const AddDocumentScreen(),
                            ),
                          );

                          if (!mounted) return;

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                              const DocumentListScreen(),
                            ),
                          );

                        },
                      ),
                    ),

                    const SizedBox(height: 40),

                  ],
                ),
              ),
            );

          },
        ),
      ),
    );
  }

  Widget _cardResumo(
      String titulo,
      int valor,
      Color cor,
      IconData icone,
      ) {

    return Container(

      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(12),
      ),

      padding: const EdgeInsets.all(16),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,

        children: [

          Icon(
            icone,
            color: cor,
            size: 32,
          ),

          const SizedBox(height: 8),

          Text(
            "$valor",
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),

        ],
      ),
    );
  }
}