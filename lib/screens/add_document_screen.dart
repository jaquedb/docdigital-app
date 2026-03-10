import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../widgets/app_background.dart';
import '../services/document_service.dart';
import '../models/documento.dart';

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

  final TextEditingController nomeController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();

  String categoriaSelecionada = "Documento pessoal";
  DateTime? dataVencimento;

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

      categoriaSelecionada = categorias.entries
          .firstWhere((e) => e.value == doc.categoria)
          .key;

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

    if (!modoEdicao && arquivoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecione um arquivo")),
      );
      return;
    }

    if (nomeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Informe o nome do documento")),
      );
      return;
    }

    try {

      String categoriaBackend = categorias[categoriaSelecionada]!;

      String? dataFormatada;

      if (dataVencimento != null) {
        dataFormatada =
        "${dataVencimento!.year}-${dataVencimento!.month.toString().padLeft(2, '0')}-${dataVencimento!.day.toString().padLeft(2, '0')}";
      }

      if (modoEdicao) {

        await DocumentService.atualizarDocumento(
          id: widget.documento!.id!,
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
                  onPressed: salvarDocumento,
                  child: Text(
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