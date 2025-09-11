import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
// Import for Android features.
// import 'package:webview_flutter_android/webview_flutter_android.dart';
// // Import for iOS features.
// import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import 'package:cotizador_casa_di_maria/system/globals.dart';

class PoliticasPage extends StatefulWidget {
  const PoliticasPage({ Key? key }) : super(key: key);

  @override
  State<PoliticasPage> createState() => _PoliticasPageState();
}

class _PoliticasPageState extends State<PoliticasPage> {
  final WebViewController _controller = WebViewController();

  @override
  void initState() {
    super.initState();    
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text(appName),
      ),
      body: Builder(builder: (_) {
        return WebViewWidget(
          controller: _controller..loadFlutterAsset("html/privacidad.html"),
        );
      }),
    );
  }
}