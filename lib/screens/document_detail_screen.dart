import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/documento.dart';
import '../widgets/app_background.dart';
import '../services/token_storage.dart';
import '../services/document_service.dart';

class DocumentDetailScreen extends StatelessWidget {

  final Documento documento;

  const DocumentDetailScreen({
    super.key,
    required this.documento,
  });

  String formatarData(String dataIso) {

    final data = DateTime.parse(dataIso);

    return "${data.day.toString().padLeft(2,'0')}/"
        "${data.month.toString().padLeft(2,'0')}/"
        "${data.year}";
  }

  bool ehImagem(String tipoArquivo) {
    return tipoArquivo.contains("image");
  }

  Future<void> visualizarDocumento() async {

    final url = Uri.parse(
      "http://127.0.0.1:8080/documentos/visualizar/${documento.caminhoArquivo}",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }

  }

  Future<void> baixarDocumento() async {

    final url = Uri.parse(
      "http://127.0.0.1:8080/documentos/download/${documento.caminhoArquivo}",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }

  }

  Future<void> excluirDocumento(BuildContext context) async {

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {

        return AlertDialog(
          title: const Text("Excluir documento"),
          content: const Text(
            "Tem certeza que deseja excluir este documento? Esta ação não pode ser desfeita.",
          ),
          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("Cancelar"),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text("Excluir"),
            ),

          ],
        );
      },
    );

    if (confirmar != true) return;

    final token = await TokenStorage.obterToken();

    if (token == null) return;

    await DocumentService.deletarDocumento(documento.id!, token);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Documento excluído com sucesso"),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    final url =
        "http://127.0.0.1:8080/documentos/visualizar/${documento.caminhoArquivo}";

    return AppBackground(

      child: Scaffold(

        backgroundColor: Colors.transparent,

        appBar: AppBar(
          title: const Text(
            "Detalhes do documento",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF0B0F1A),
          elevation: 0,
        ),

        body: SingleChildScrollView(

          child: Padding(

            padding: const EdgeInsets.all(20),

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                const SizedBox(height: 20),

                Center(

                  child: ehImagem(documento.tipoArquivo)

                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      url,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  )

                      : const Icon(
                    Icons.picture_as_pdf,
                    size: 120,
                    color: Colors.redAccent,
                  ),
                ),

                const SizedBox(height: 30),

                Text(
                  documento.nome,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "Categoria: ${documento.categoria}",
                  style: const TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 10),

                Text(
                  "Enviado em: ${formatarData(documento.dataUpload)}",
                  style: const TextStyle(color: Colors.white70),
                ),

                if (documento.dataVencimento != null)
                  Text(
                    "Vence em: ${formatarData(documento.dataVencimento!)}",
                    style: const TextStyle(color: Colors.orangeAccent),
                  ),

                const SizedBox(height: 40),

                Row(
                  children: [

                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.visibility),
                        label: const Text("VISUALIZAR"),
                        onPressed: visualizarDocumento,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.download),
                        label: const Text("BAIXAR"),
                        onPressed: baixarDocumento,
                      ),
                    ),

                  ],
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.delete),
                    label: const Text("EXCLUIR"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => excluirDocumento(context),
                  ),
                ),

                const SizedBox(height: 30),

              ],
            ),
          ),
        ),
      ),
    );
  }
}