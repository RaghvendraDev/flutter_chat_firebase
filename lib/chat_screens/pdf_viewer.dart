import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PDFViewerClass extends StatelessWidget {
  final File file;
  final String fileName;
  const PDFViewerClass({Key? key, required this.file, required this.fileName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("file will be at ${file}");
    return Scaffold(
      appBar: AppBar(
        title: Text("$fileName"),
      ),
      body: SfPdfViewer.file(
        file,
        enableDoubleTapZooming: true,
      ),
    );
  }
}
