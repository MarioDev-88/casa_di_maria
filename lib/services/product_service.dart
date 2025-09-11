import 'package:cotizador_casa_di_maria/models/Product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cotizador_casa_di_maria/system/globals.dart';

class ProductService {
  Future getProductByName(String search) async {
    final _urlSearchPlatillo = Uri.http('zesty.com.mx', '/apps/apiapps/v1/searchbyplatillo/');
    final _res = await http.post(
      _urlSearchPlatillo,
      headers: headers,
      body: jsonEncode({
        'search' : search
      })
    );
    if(_res.statusCode == 200) {
      final List<dynamic> _response = jsonDecode(_res.body);
      return _response.map((obj) => Product.fromJson(obj)).toList();
    }
  }
}