// FILE: lib/screens/widgets/pdf_viewer_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

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
      // Usa um nome de arquivo baseado no nome original + ID para evitar conflitos
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

  // ## A CORREÇÃO ESTÁ AQUI ##
  // Esta função contém a lógica 'if/else' e retorna o widget correto
  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Erro ao carregar PDF: $error',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (localPath != null) {
      return PDFView(
        filePath: localPath!,
        enableSwipe: true,
        swipeHorizontal: false,
      );
    }
    // Fallback
    return const Center(child: Text('Não foi possível carregar o PDF.'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName, overflow: TextOverflow.ellipsis),
      ),
      body: Hero(
        tag: widget.heroTag,
        // O child agora chama a função _buildBody(), que retorna um único widget
        child: _buildBody(),
      ),
    );
  }
}
