import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PDFScreen extends StatefulWidget {
  final String path;

  const PDFScreen({Key? key, required this.path}) : super(key: key);

  @override
  State<PDFScreen> createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> with WidgetsBindingObserver {
  late Completer<PDFViewController> _controller;

  int? _currentPage = 0;
  bool _isReady = false;
  String errorMessage = '';
  String _path = "";

  @override
  void initState() {
    _path = widget.path;
    _controller = Completer<PDFViewController>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.path.split("/").last),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        actions: const [
          //ShareButton
          // IconButton(
          //     onPressed: () async {
          //       //await Share.share(widget.link);
          //     },
          //     icon: const Icon(Icons.share)),
        ],
      ),
      body: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: PDFView(
              filePath: _path,
              enableSwipe: true,
              swipeHorizontal: true,
              autoSpacing: false,
              pageFling: true,
              pageSnap: true,
              defaultPage: _currentPage!,
              onRender: (pages) {
                setState(() {
                  pages = pages;
                  _isReady = true;
                });
              },
              onError: (error) {
                setState(() {
                  errorMessage = error.toString();
                });
              },
              onPageError: (page, error) {
                setState(() {
                  errorMessage = '$page: ${error.toString()}';
                });
              },
              onViewCreated: (PDFViewController pdfViewController) {
                _controller.complete(pdfViewController);
              },
              onLinkHandler: (String? uri) {
                //launchURL(uri ?? "");
              },
              onPageChanged: (int? page, int? total) {
                setState(() {
                  _currentPage = page;
                });
              },
            ),
          ),
          errorMessage.isEmpty
              ? !_isReady
                  ? const Center(
                      child: CircularProgressIndicator.adaptive(),
                    )
                  : Container()
              : Center(
                  child: Text(errorMessage),
                )
        ],
      ),
    );
  }
}
