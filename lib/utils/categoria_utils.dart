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

    case "OUTROS":
      return "Outros";

    default:
      return "Outros";
  }
}