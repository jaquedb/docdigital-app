import 'package:flutter/material.dart';
import '../widgets/app_background.dart';
import '../services/document_service.dart';
import '../services/token_storage.dart';
import '../models/documento.dart';
import 'add_document_screen.dart';
import 'document_detail_screen.dart';

class DocumentListScreen extends StatefulWidget {
  const DocumentListScreen({super.key});

  @override
  State<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends State<DocumentListScreen> {

  late Future<List<Documento>> documentosFuture;

  @override
  void initState() {
    super.initState();
    carregarDocumentos();
  }

  Future<void> carregarDocumentos() async {

    final token = await TokenStorage.obterToken();

    if (token == null) return;

    setState(() {
      documentosFuture = DocumentService.listarDocumentos();
    });
  }

  Future<void> logout() async {

    await TokenStorage.removerToken();

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, '/login');
  }

  String obterNomeCategoria(String categoria) {

    switch (categoria) {

      case "DOCUMENTO_PESSOAL":
        return "Documento pessoal";

      case "DOCUMENTO_VEICULAR":
        return "Documento veicular";

      case "DOCUMENTO_ACADEMICO":
        return "Documento acadêmico";

      case "COMPROVANTE_PAGAMENTO":
        return "Comprovante de pagamento";

      case "NOTA_FISCAL":
        return "Nota fiscal";

      case "CONTRATO":
        return "Contrato";

      case "EXAME_MEDICO":
        return "Exame médico";

      case "RECEITUARIO_MEDICO":
        return "Receituário médico";

      default:
        return "Outros";
    }
  }

  String formatarData(String dataIso) {

    final data = DateTime.parse(dataIso);

    return "${data.day.toString().padLeft(2,'0')}/"
        "${data.month.toString().padLeft(2,'0')}/"
        "${data.year}";
  }

  bool ehImagem(String tipoArquivo) {
    return tipoArquivo.contains("image");
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

  Color corDoCard(Documento doc) {

    final dias = diasParaVencer(doc);

    if (dias == null) {
      return const Color(0xFF1F2937);
    }

    if (dias < 0) {
      return const Color(0xFF5A1A1A); // vencido
    }

    if (dias == 0) {
      return const Color(0xFF7A3E00); // vence hoje
    }

    if (dias <= 5) {
      return const Color(0xFF665200); // até 5 dias
    }

    if (dias <= 10) {
      return const Color(0xFF1A3A5A); // até 10 dias
    }

    return const Color(0xFF1F2937);
  }

  Widget alertaVencimento(Documento doc) {

    final dias = diasParaVencer(doc);

    if (dias == null) return const SizedBox();

    if (dias < 0) {
      return const Text(
        "⚠ DOCUMENTO VENCIDO",
        style: TextStyle(
          color: Colors.redAccent,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    if (dias == 0) {
      return const Text(
        "⚠ VENCE HOJE",
        style: TextStyle(
          color: Colors.orangeAccent,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    if (dias <= 10) {
      return Text(
        "⚠ Vence em $dias dias",
        style: const TextStyle(
          color: Colors.yellowAccent,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return Text(
      "⏳ Vence em ${formatarData(doc.dataVencimento!)}",
      style: const TextStyle(
        color: Colors.orangeAccent,
      ),
    );
  }

  Future<void> abrirTelaAdicionar() async {

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddDocumentScreen(),
      ),
    );

    await carregarDocumentos();
  }

  Future<void> abrirDetalhes(Documento doc) async {

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentDetailScreen(documento: doc),
      ),
    );

    await carregarDocumentos();
  }

  Widget construirPreview(Documento doc) {

    final url =
        "http://127.0.0.1:8080/documentos/visualizar/${doc.caminhoArquivo}";

    if (ehImagem(doc.tipoArquivo)) {

      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          url,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
        ),
      );

    } else {

      return const Icon(
        Icons.picture_as_pdf,
        size: 40,
        color: Colors.redAccent,
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        title: const Text(
          "Meus Documentos",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0B0F1A),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          )
        ],
      ),

      body: AppBackground(

        child: FutureBuilder<List<Documento>>(
          future: documentosFuture,

          builder: (context, snapshot) {

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {

              return const Center(
                child: Text(
                  "Erro ao carregar documentos",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {

              return const Center(
                child: Text(
                  "Nenhum documento cadastrado",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            final documentos = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: documentos.length,

              itemBuilder: (context, index) {

                final doc = documentos[index];

                return Card(
                  color: corDoCard(doc),
                  margin: const EdgeInsets.only(bottom: 12),

                  child: ListTile(

                    leading: construirPreview(doc),

                    title: Text(
                      doc.nome,
                      style: const TextStyle(color: Colors.white),
                    ),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          obterNomeCategoria(doc.categoria),
                          style: const TextStyle(color: Colors.white70),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          "📅 Enviado em ${formatarData(doc.dataUpload)}",
                          style: const TextStyle(color: Colors.white54),
                        ),

                        if (doc.dataVencimento != null)
                          alertaVencimento(doc),

                      ],
                    ),

                    onTap: () => abrirDetalhes(doc),

                  ),
                );
              },
            );
          },
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: abrirTelaAdicionar,
        child: const Icon(Icons.add),
      ),
    );
  }
}