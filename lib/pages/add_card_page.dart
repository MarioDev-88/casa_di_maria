import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:elotes_make/themes/custom.dart';
import 'package:elotes_make/system/add_card_arguments.dart';
import 'package:elotes_make/system/globals.dart';

class AddCardPage extends StatefulWidget {
  const AddCardPage({Key? key}) : super(key: key);

  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  late final WebViewController _controllerWebView;
  final _url = Uri.http('zesty.com.mx', '/apps/apiapps/v1/borrartarjeta/');
  final _urlAdd = Uri.http('zesty.com.mx', '/apps/apiapps/v1/usuarioconekta/');
  String _idTarjeta = '';
  final Duration _timeDelay = const Duration(seconds: 2);
  late Timer _timeName;
  late Timer _timeToken;

  @override
  void dispose() {
    _timeName.cancel();
    _timeToken.cancel();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }
    final WebViewController controller = WebViewController.fromPlatformCreationParams(params);
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel('Toaster', onMessageReceived: (JavaScriptMessage message) {
        print(message.message);
      })
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            
          },
          onPageFinished: (url) {  

            fetchDataName() {
              controller.runJavaScriptReturningResult('getNameCard()').then((value) async {
                if(value.toString().isEmpty || value.toString().length < 15) {
                  _timeName = Timer(_timeDelay, fetchDataName);                  
                } else {
                  final SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.setString('tokenCard', value.toString());
                  _timeName.cancel();
                }
              })
              .onError((error, stackTrace) {                
                _timeName = Timer(_timeDelay, fetchDataName);
              });
            }
            
            fetchDataToken() {
              controller.runJavaScriptReturningResult('getToken()').then((value) async{
                if(value.toString().isEmpty || value.toString() == null || value.toString() == "null") {
                  _timeToken = Timer(_timeDelay, fetchDataToken);
                } else {
                  final SharedPreferences prefs = await SharedPreferences.getInstance();                 
                  prefs.setString('tokenId', value.toString());
                  _sendCard();       
                  _timeToken.cancel();
                }
                         
              })
              .onError((error, stackTrace) {
                _timeToken = Timer(_timeDelay, fetchDataToken);
              });
            }

            fetchDataName();
            fetchDataToken();
          }
        )
      )
      ..loadRequest(Uri.parse('https://zesty.com.mx/tarjetas/$restId/crear/'));

    if(controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _controllerWebView = controller;
  }

  Future<bool> _onWillPop() async  {
    return await showDialog(context: context, builder: (_) {
      return AlertDialog(
        title: const Text('Desea salir sin agregar tarjeta?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Salir'))
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as AddCardArguments;
    _idTarjeta = args.idTarjeta;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(title: const Text('Agregar tarjeta')),
        body:  SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: WebViewWidget(controller: _controllerWebView),
          ),
        ),
      ),
    );
  }

  _sendCard() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final paramsAdd = {
      "id_usuario" : prefs.getInt('id'),
      "name" : prefs.getString("tokenCard"),
      "email" : prefs.getString('email'),
      "token_id" : prefs.getString('tokenId'),
      "isNew" : true
    };  

    // Borramos la tarjeta si hay
    if(_idTarjeta.isEmpty) {
      var params = {
        "id_usuario": prefs.getInt('id'),
        "token_id": _idTarjeta
      };
      await http.post(
        _url,
        headers: headers,
        body: jsonEncode(params)
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: customTheme.secondary,
        duration: const Duration(seconds: 2),
        content: const Center(child: CircularProgressIndicator(),),
        behavior: SnackBarBehavior.floating,
      )
    );
    Future.delayed(const Duration(seconds: 2), () async {
      final _resAdd = await http.post(
      _urlAdd,
      headers: headers,
      body: jsonEncode(paramsAdd)
    );
    List _response = jsonDecode(_resAdd.body);
    bool _isSrPago = false;
    String _error = "";
    if(_response.contains("msg_srpago")) {
      _isSrPago = _response[0]['msg_srpago'];
      _error = _response[0]['error'];
    }     
    if(_response.contains("msg_srpago") || _response[0]['msg_srpago'] == true) {
      if(_response.contains("error") || _response[0]['error'] != "") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(_response[0]['error']),
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          )
        );
      } else {
        setState(() {
          prefs.remove('tokenCard');
          prefs.remove('tokenId');
          prefs.setString('customer_token', _response[0]['id']);
          Navigator.pop(context, true);
        });
      }      
    } else {
      if(_response.contains("error")) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(_response[0]['error']['details']['message']),
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          )
        );
      } else {
        
        setState(() {
          prefs.remove('tokenCard');
          prefs.remove('tokenId');
          prefs.setString('customer_token', _response[0]['id']);
          Navigator.pop(context, true);
        });
      }
    }
    });
  }
}