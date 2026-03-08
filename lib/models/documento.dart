class Documento {

  final int id;
  final String nome;
  final String? descricao;
  final String categoria;
  final String dataUpload;
  final String? dataVencimento;
  final String caminhoArquivo;
  final String tipoArquivo;

  Documento({
    required this.id,
    required this.nome,
    this.descricao,
    required this.categoria,
    required this.dataUpload,
    this.dataVencimento,
    required this.caminhoArquivo,
    required this.tipoArquivo,
  });

  factory Documento.fromJson(Map<String, dynamic> json) {

    return Documento(
      id: json['id'],
      nome: json['nome'],
      descricao: json['descricao'],
      categoria: json['categoria'],
      dataUpload: json['dataUpload'],
      dataVencimento: json['dataVencimento'],
      caminhoArquivo: json['caminhoArquivo'],
      tipoArquivo: json['tipoArquivo'],
    );
  }

}