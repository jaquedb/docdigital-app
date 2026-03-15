import 'package:flutter/material.dart';
import '../widgets/app_background.dart';
import '../services/document_service.dart';
import '../services/token_storage.dart';
import '../services/auth_service.dart';
import '../models/documento.dart';
import '../config/api_config.dart';
import 'add_document_screen.dart';
import 'document_detail_screen.dart';
import '../utils/categoria_utils.dart';

class DocumentListScreen extends StatefulWidget {
  const DocumentListScreen({super.key});

  @override
  State<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends State<DocumentListScreen> {

  Future<List<Documento>> documentosFuture = Future.value([]);

  final TextEditingController buscaController = TextEditingController();

  String textoBusca = "";

  String saudacao() {
    final hora = DateTime.now().hour;

    if (hora < 12) {
      return "☀ Bom dia";
    } else if (hora < 18) {
      return "⛅ Boa tarde";
    } else {
      return "🌛 Boa noite";
    }
  }

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


  String formatarData(String dataIso) {

    final data = DateTime.parse(dataIso);

    return "${data.day.toString().padLeft(2,'0')}/"
        "${data.month.toString().padLeft(2,'0')}/"
        "${data.year}";
  }

  bool ehImagem(Documento doc) {

    final tipo = doc.tipoArquivo.toLowerCase();
    final nome = doc.caminhoArquivo.toLowerCase();

    return tipo.contains("image") ||
        nome.endsWith(".png") ||
        nome.endsWith(".jpg") ||
        nome.endsWith(".jpeg");
  }

  bool ehPdf(Documento doc) {

    final tipo = doc.tipoArquivo.toLowerCase();
    final nome = doc.caminhoArquivo.toLowerCase();

    return tipo.contains("pdf") || nome.endsWith(".pdf");
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

  int prioridadeDocumento(Documento doc) {

    final dias = diasParaVencer(doc);

    if (dias == null) return 5;
    if (dias < 0) return 0;
    if (dias == 0) return 1;
    if (dias <= 5) return 2;
    if (dias <= 10) return 3;

    return 4;
  }

  Color corDoCard(Documento doc) {

    final dias = diasParaVencer(doc);

    if (dias == null) return const Color(0xFF1F2937);
    if (dias < 0) return const Color(0xFF5A1A1A);
    if (dias == 0) return const Color(0xFF7A3E00);
    if (dias <= 5) return const Color(0xFF665200);
    if (dias <= 10) return const Color(0xFF1A3A5A);

    return const Color(0xFF1F2937);
  }

  Widget alertaVencimento(Documento doc) {

    final dias = diasParaVencer(doc);

    if (dias == null) return const SizedBox();

    if (dias < 0) {
      return const Text(
        "⚠ DOCUMENTO VENCIDO",
        style: TextStyle(color: Colors.redAccent,fontWeight: FontWeight.bold),
      );
    }

    if (dias == 0) {
      return const Text(
        "⚠ VENCE HOJE",
        style: TextStyle(color: Colors.orangeAccent,fontWeight: FontWeight.bold),
      );
    }

    if (dias <= 10) {
      return Text(
        "⚠ Vence em $dias dias",
        style: const TextStyle(color: Colors.yellowAccent,fontWeight: FontWeight.bold),
      );
    }

    return Text(
      "⏳ Vence em ${formatarData(doc.dataVencimento!)}",
      style: const TextStyle(color: Colors.orangeAccent),
    );
  }

  List<Documento> ordenarDocumentos(List<Documento> docs) {

    docs.sort((a, b) {

      final prioridadeA = prioridadeDocumento(a);
      final prioridadeB = prioridadeDocumento(b);

      if (prioridadeA != prioridadeB) {
        return prioridadeA.compareTo(prioridadeB);
      }

      final diasA = diasParaVencer(a);
      final diasB = diasParaVencer(b);

      if (diasA == null && diasB == null) return 0;
      if (diasA == null) return 1;
      if (diasB == null) return -1;

      return diasA.compareTo(diasB);

    });

    return docs;
  }

  List<Documento> filtrarDocumentos(List<Documento> docs) {

    if (textoBusca.isEmpty) return docs;

    return docs.where((doc) {

      final nome = doc.nome.toLowerCase();
      final descricao = (doc.descricao ?? "").toLowerCase();
      final busca = textoBusca.toLowerCase();

      return nome.contains(busca) || descricao.contains(busca);

    }).toList();
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
        "${ApiConfig.baseUrl}/documentos/visualizar/${doc.caminhoArquivo}";

    if (ehImagem(doc)) {

      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          url,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.image, size: 40, color: Colors.white70);
          },
        ),
      );

    } else if (ehPdf(doc)) {

      return const Icon(
        Icons.picture_as_pdf,
        size: 40,
        color: Colors.redAccent,
      );

    } else {

      return const Icon(
        Icons.insert_drive_file,
        size: 40,
        color: Colors.white70,
      );

    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        title: const Text("Meus Documentos"),
        backgroundColor: const Color(0xFF0B0F1A),
        actions: [
          IconButton(icon: const Icon(Icons.logout),onPressed: logout)
        ],
      ),

      body: AppBackground(

        child: FutureBuilder<List<Documento>>(
          future: documentosFuture,

          builder: (context, snapshot) {

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData) {
              return const Center(
                child: Text("Erro ao carregar documentos",
                    style: TextStyle(color: Colors.white)),
              );
            }

            var documentos = ordenarDocumentos(snapshot.data!);
            documentos = filtrarDocumentos(documentos);

            return Column(

              children: [

                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "${saudacao()}, ${AuthService.nomeUsuario ?? "Usuário"}!",
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(

                    controller: buscaController,

                    onChanged: (valor) {
                      setState(() {
                        textoBusca = valor;
                      });
                    },

                    style: const TextStyle(color: Colors.white),

                    decoration: InputDecoration(

                      hintText: "Buscar documento...",
                      hintStyle: const TextStyle(color: Colors.white54),

                      prefixIcon: const Icon(Icons.search,color: Colors.white),

                      filled: true,
                      fillColor: const Color(0xFF1F2937),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: documentos.length,

                    itemBuilder: (context, index) {

                      final doc = documentos[index];

                      return Card(
                        color: corDoCard(doc),
                        margin: const EdgeInsets.only(bottom: 12),

                        child: ListTile(

                          leading: construirPreview(doc),

                          title: Text(doc.nome,
                              style: const TextStyle(color: Colors.white)),

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
                  ),
                ),
              ],
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