import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerScreen extends StatelessWidget {

  final String url;
  final String nomeDocumento;

  const PdfViewerScreen({
    super.key,
    required this.url,
    required this.nomeDocumento,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text(nomeDocumento),
      ),

      body: SfPdfViewer.network(url),

    );
  }
}