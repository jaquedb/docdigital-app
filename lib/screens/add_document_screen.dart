import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../widgets/app_background.dart';
import '../services/document_service.dart';
import '../models/documento.dart';
import '../services/notification_service.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';

class AddDocumentScreen extends StatefulWidget {

  final Documento? documento;

  const AddDocumentScreen({
    super.key,
    this.documento,
  });

  @override
  State<AddDocumentScreen> createState() => _AddDocumentScreenState();
}

class _AddDocumentScreenState extends State<AddDocumentScreen> {

  PlatformFile? arquivoSelecionado;

  List<String> imagensDigitalizadas = [];

  final TextEditingController nomeController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();

  String categoriaSelecionada = "Documento pessoal";
  DateTime? dataVencimento;

  final ImagePicker _picker = ImagePicker();

  bool carregando = false;

  final Map<String, String> categorias = {
    "Documento pessoal": "DOCUMENTO_PESSOAL",
    "Documento veicular": "DOCUMENTO_VEICULAR",
    "Documento acadêmico": "DOCUMENTO_ACADEMICO",
    "Comprovante de pagamento": "COMPROVANTE_PAGAMENTO",
    "Nota fiscal": "NOTA_FISCAL",
    "Contrato": "CONTRATO",
    "Exame médico": "EXAME_MEDICO",
    "Receituário médico": "RECEITUARIO_MEDICO",
    "Outros": "OUTROS",
  };

  bool get modoEdicao => widget.documento != null;

  @override
  void initState() {
    super.initState();

    if (modoEdicao) {

      final doc = widget.documento!;

      nomeController.text = doc.nome;
      descricaoController.text = doc.descricao ?? "";

      final categoriaEncontrada = categorias.entries.firstWhere(
            (e) => e.value == doc.categoria,
        orElse: () => const MapEntry("Documento pessoal", "DOCUMENTO_PESSOAL"),
      );

      categoriaSelecionada = categoriaEncontrada.key;

      if (doc.dataVencimento != null) {
        dataVencimento = DateTime.parse(doc.dataVencimento!);
      }
    }
  }

  Future<void> selecionarArquivo() async {

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );

    if (result != null) {
      setState(() {
        arquivoSelecionado = result.files.single;
      });
    }
  }

  Future<void> digitalizarDocumento() async {

    try {

      List<String>? imagens = await CunningDocumentScanner.getPictures();

      if (imagens == null || imagens.isEmpty) return;

      imagensDigitalizadas = imagens;

      final File imagem = File(imagens.first);
      final bytes = await imagem.readAsBytes();

      setState(() {
        arquivoSelecionado = PlatformFile(
          name: "scan_${DateTime.now().millisecondsSinceEpoch}.jpg",
          size: bytes.length,
          bytes: bytes,
        );
      });

    } catch (e) {

      print("Erro ao digitalizar documento: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erro ao abrir scanner"),
        ),
      );

    }

  }

  Future<void> selecionarData() async {

    DateTime? data = await showDatePicker(
      context: context,
      initialDate: dataVencimento ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (data != null) {
      setState(() {
        dataVencimento = data;
      });
    }
  }

  Future<void> salvarDocumento() async {

    if (carregando) return;

    if (!modoEdicao && arquivoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecione ou digitalize um arquivo")),
      );
      return;
    }

    if (nomeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Informe o nome do documento")),
      );
      return;
    }

    setState(() {
      carregando = true;
    });

    try {

      String categoriaBackend = categorias[categoriaSelecionada]!;

      String? dataFormatada;

      if (dataVencimento != null) {
        dataFormatada =
        "${dataVencimento!.year}-${dataVencimento!.month.toString().padLeft(2, '0')}-${dataVencimento!.day.toString().padLeft(2, '0')}";
      }

      if (modoEdicao) {

        await DocumentService.atualizarDocumento(
          id: widget.documento!.id,
          nome: nomeController.text,
          descricao: descricaoController.text,
          categoria: categoriaBackend,
          dataVencimento: dataFormatada,
        );

      } else {

        if (imagensDigitalizadas.length > 1) {

          await DocumentService.uploadDocumentoMultipage(
            imagens: imagensDigitalizadas,
            nome: nomeController.text,
            descricao: descricaoController.text,
            categoria: categoriaBackend,
            dataVencimento: dataFormatada,
          );

        } else {

          await DocumentService.uploadDocumento(
            arquivo: arquivoSelecionado!,
            nome: nomeController.text,
            descricao: descricaoController.text,
            categoria: categoriaBackend,
            dataVencimento: dataFormatada,
          );

        }

      }

      // Verifica se vence hoje
      if (dataVencimento != null) {

        final hoje = DateTime.now();

        final hojeSemHora = DateTime(hoje.year, hoje.month, hoje.day);

        final vencimentoSemHora =
        DateTime(dataVencimento!.year, dataVencimento!.month, dataVencimento!.day);

        if (vencimentoSemHora == hojeSemHora) {

          await NotificationService.mostrarNotificacaoAgora(
            titulo: "Documento vencendo hoje",
            corpo: "O documento \"${nomeController.text}\" vence hoje.",
          );

        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            modoEdicao
                ? "Documento atualizado com sucesso"
                : "Documento enviado com sucesso",
          ),
        ),
      );

      Navigator.pop(context, true);

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao salvar documento")),
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

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          title: Text(
            modoEdicao
                ? "Editar Documento"
                : "Adicionar Documento",
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF0B0F1A),
          elevation: 0,
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 20),

              if (!modoEdicao)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selecionarArquivo,
                    child: const Text("Selecionar Arquivo"),
                  ),
                ),

              if (!modoEdicao) const SizedBox(height: 10),

              if (!modoEdicao)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: digitalizarDocumento,
                    child: const Text("Digitalizar com Câmera"),
                  ),
                ),

              if (!modoEdicao) const SizedBox(height: 10),

              if (arquivoSelecionado != null)
                Text(
                  "Arquivo selecionado: ${arquivoSelecionado!.name}",
                  style: const TextStyle(color: Colors.white70),
                ),

              const SizedBox(height: 30),

              const Text(
                "Nome do documento",
                style: TextStyle(color: Colors.white),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: nomeController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Color(0xFF1F2937),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Descrição",
                style: TextStyle(color: Colors.white),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: descricaoController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Color(0xFF1F2937),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Categoria",
                style: TextStyle(color: Colors.white),
              ),

              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                isExpanded: true,
                value: categoriaSelecionada,
                dropdownColor: const Color(0xFF1F2937),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Color(0xFF1F2937),
                  border: OutlineInputBorder(),
                ),
                items: categorias.keys.map((String categoria) {
                  return DropdownMenuItem<String>(
                    value: categoria,
                    child: Text(categoria),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    categoriaSelecionada = value!;
                  });
                },
              ),

              const SizedBox(height: 20),

              const Text(
                "Data de vencimento",
                style: TextStyle(color: Colors.white),
              ),

              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selecionarData,
                  child: Text(
                    dataVencimento == null
                        ? "Selecionar data"
                        : "${dataVencimento!.day}/${dataVencimento!.month}/${dataVencimento!.year}",
                  ),
                ),
              ),

              if (dataVencimento != null) ...[

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        dataVencimento = null;
                      });
                    },
                    child: const Text("Remover data de vencimento"),
                  ),
                ),
              ],

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: carregando ? null : salvarDocumento,
                  child: carregando
                      ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Text(
                    modoEdicao ? "ATUALIZAR" : "SALVAR",
                  ),
                ),
              ),

              const SizedBox(height: 40),

            ],
          ),
        ),
      ),
    );
  }
}