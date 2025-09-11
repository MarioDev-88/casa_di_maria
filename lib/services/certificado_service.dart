import 'package:cotizador_casa_di_maria/models/Certificados.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cotizador_casa_di_maria/system/globals.dart';

class CertificadoService {
  Future getCertificados() async {
    final _urlCertificados = Uri.http('zesty.com.mx', '/apps/apiapps/v1/certificados/');
    final _res = await http.get(
      _urlCertificados,
      headers: headers
    );
    if(_res.statusCode == 201) {
      final List<dynamic> _response = jsonDecode(_res.body);
      return _response.map((obj) => Certificados.fromJson(obj)).toList();
    }
  }

  Future<Map<String, dynamic>> pagoCertificado(Object? params) async {
    final _urlCertificados = Uri.http('zesty.com.mx', '/apps/apiapps/v1/generarpago/');
    final _res = await http.post(
      _urlCertificados,
      headers: headers,
      body: jsonEncode(params)
    );
    return {
      "status" : _res.statusCode,
    }; 
  }
}