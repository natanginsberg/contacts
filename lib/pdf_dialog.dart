import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

import 'package:http/http.dart' as http;

class PDF extends StatelessWidget {
  final String doc;

  const PDF(this.doc, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    try {
      return Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        child: FutureBuilder<String>(
            future: downloadPdf(doc),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.none &&
                  snapshot.hasData) {
                return const Text("No pdf to show");
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                    height: 200, child: CupertinoActivityIndicator());
              } else if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.data == null) {
                return SizedBox(
                    height: MediaQuery.of(context).size.height / 3,
                    child: const Center(child: Text("Error loading file")));
              } else {
                return PDFView(
                  filePath: snapshot.data!,
                  autoSpacing: true,
                  enableSwipe: true,
                  pageSnap: true,
                  swipeHorizontal: true,
                  nightMode: false,
                  onError: (e) {
                    //Show some error message or UI
                  },
                  onPageError: (page, e) {},
                );
              }
            }),
      );
    } catch (e) {
      return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: SizedBox(
            height: MediaQuery.of(context).size.height / 3,
            child: const Center(
              child: Text("Error loading file"),
            ),
          ));
    }
  }

  Future<String> downloadPdf(String url) async {
    var data = await http.get(Uri.parse(url));
    var bytes = data.bodyBytes;
    var dir = await getApplicationDocumentsDirectory();

    File file = File("${dir.path} fileName.pdf");

    File urlFile = await file.writeAsBytes(bytes);

    return urlFile.path;
  }
}
