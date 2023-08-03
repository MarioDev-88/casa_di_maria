import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../system/globals.dart';

class OrdenService {
  Future<Map<String, dynamic>> sendOrderCard(Map data) async {
    final _urlOrden = Uri.http('zesty.com.mx', '/apps/apiapps/v1/generarpedidotarjeta/');
    final _resCard = await http.post(
      _urlOrden,
      headers: headers,
      body: jsonEncode(data)
    );    
    if(_resCard.statusCode == 201) {
      final _response = jsonDecode(_resCard.body);            
      return checkOrdenCard(_response['instance'] as int, data['customer_token']);
    } else {
      return {
        "status" : false
      };
    }
  }

  Future<Map<String, dynamic>> sendOrder(Map data) async {
    // return {
    //   "status" : true,
    //   "data" : {
    //     "folio" : "RAPP"
    //   }
    // };
    final _urlOrden = Uri.http('zesty.com.mx', '/apps/apiapps/v1/generarpedido/');
    final _res = await http.post(
      _urlOrden,
      headers: headers,
      body: jsonEncode(data)
    );
    if(_res.statusCode == 200) {
      final _response = jsonDecode(_res.body);
      return checkOrden(_response['instance'] as int);
    } else {
      return {
        "status" : false
      };
    }
  }

  Future<Map<String, dynamic>> checkOrden(int instance) async {
    final _urlOrdenCheck = Uri.http('zesty.com.mx', '/apps/apiapps/v1/checkpedido/');
    final _res = await http.post(
      _urlOrdenCheck,
      headers: headers,
      body: jsonEncode({
        "instance" : instance
      })
    );
    if(_res.statusCode == 200) {
      final _response = jsonDecode(_res.body);
      return {
          "status" : true,
          "data" : _response
        };
    } else {
      return {
        "status" : false
      };
    }
  }

  Future<Map<String, dynamic>> checkOrdenCard(int instance, String customerToken) async {
    print('card check');
    final _urlOrdenCheck = Uri.http('zesty.com.mx', '/apps/apiapps/v1/checkpedidotarjeta/');
    final _res = await http.post(
      _urlOrdenCheck,
      headers: headers,
      body: jsonEncode({
        "instance" : instance,
        "customer_token" : customerToken
      })
    );

    final _response = jsonDecode(_res.body);      
    if(_res.statusCode == 200) {      
      return {
          "status" : true,
          "data" : _response
        };
    } else {
      return {
        "status" : false,
        "data" : _response
      };
    }
  }
}