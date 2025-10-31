// FILE: lib/screens/widgets/pdf_viewer_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart'; // Importe o share_plus

class PdfViewerScreen extends StatefulWidget {
  final String fileUrl;
  final String heroTag;
  final String fileName;

  const PdfViewerScreen({
    super.key,
    required this.fileUrl,
    required this.heroTag,
    required this.fileName,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  String? localPath;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filename = '${widget.heroTag}-${widget.fileName}';
      final file = File('${dir.path}/$filename');

      if (await file.exists()) {
        if (!mounted) return;
        setState(() {
          localPath = file.path;
          isLoading = false;
        });
        return;
      }

      final response = await http.get(Uri.parse(widget.fileUrl));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        if (!mounted) return;
        setState(() {
          localPath = file.path;
          isLoading = false;
        });
      } else {
        throw Exception(
          'Falha ao baixar o PDF. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  // NOVO: Função para compartilhar o arquivo PDF local
  Future<void> _shareLocalFile() async {
    if (localPath != null) {
      await Share.shareXFiles([
        XFile(localPath!),
      ], text: 'Confira este documento: ${widget.fileName}');
    }
  }

  Widget _buildBody() {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (error != null)
      return Center(child: Text('Erro ao carregar PDF: $error'));
    if (localPath != null) return PDFView(filePath: localPath!);
    return const Center(child: Text('Não foi possível carregar o PDF.'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName, overflow: TextOverflow.ellipsis),
        actions: [
          // NOVO: Botão de compartilhar, habilitado apenas se o arquivo foi carregado
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Compartilhar PDF',
            onPressed: (isLoading || localPath == null)
                ? null
                : _shareLocalFile,
          ),
        ],
      ),
      body: Hero(tag: widget.heroTag, child: _buildBody()),
    );
  }
}
