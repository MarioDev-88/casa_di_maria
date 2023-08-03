import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elotes_make/system/globals.dart';

class CheckinPage extends StatefulWidget {
  const CheckinPage({ Key? key }) : super(key: key);
  
  @override
  State<CheckinPage> createState() => _CheckinPageState();
}

class _CheckinPageState extends State<CheckinPage> {
  final _urlCheckin = Uri.https('zesty.com.mx', '/apps/apiapps/v1/listavisitas/');
  final _urlSendCheckin = Uri.https('zesty.com.mx', '/apps/apiapps/v1/registrarvisita/');
  String _descripcion = '';
  String _reglas = '';
  List _visitasRegistradas = [];
  int _visitaRecompensa = 0;
  @override
  void initState() {
    super.initState();
    _fetchRecompensa();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recompensas'),
      ),
      body: SizedBox(
        width: double.infinity,
         child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/fondo.jpg'), fit: BoxFit.fill)
          ),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: ListView(
              children: [
                Card(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      '$_descripcion \n\n Reglas: \n\n $_reglas',
                      style: const TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w700
                      ),
                    ),
                  ),
                ),
                FilledButton(onPressed: _sendCheckin, child: Text('Realizar check-in')),
                _crearUI()
              ],
            ),
          )
         )
      ),
    );
  }
  
  void _fetchRecompensa() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print(prefs.getInt('id'));
    final _res = await http.post(
      _urlCheckin,
      headers: headers,
      body: jsonEncode({
        "usuario" : prefs.getInt('id')
      })
    );
    if(_res.statusCode == 200) {
      final _response = jsonDecode(_res.body);
      setState(() {
        _descripcion = _response[1]['descripcion'];
        _reglas = _response[1]['reglas'];
        _visitasRegistradas = jsonDecode(_response[2]['visitas']);
        _visitaRecompensa = int.parse(_response[1]['visitas']);
      });
    }
  }
  
  _crearUI() {    
    List<Widget> _contenedores = [];
    for (var i = 0; i <= _visitaRecompensa - 1; i++) {
      if(_visitasRegistradas.isNotEmpty) {
        try {
          _contenedores.add(Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40)
            ),
            child: Column(
              children: [
                Image.asset('assets/logo.png'),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    DateFormat.yMMMd().format(DateTime.parse(_visitasRegistradas[i]['fields']['updated_at'])),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 10.0
                    ),
                  ),
                ),
              ],
            )
          ));
          if(i < _visitaRecompensa-1) {
            _contenedores..add(Container(width: 5, height: 20, decoration: BoxDecoration(color: Colors.white),));
          } 
        } catch (e) {
          print(e);
          _contenedores.add(Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40)
            ),
          ));
          if(i < _visitaRecompensa-1) {
            _contenedores..add(Container(width: 5, height: 20, decoration: BoxDecoration(color: Colors.white),));
          } 
        }
        //if(_visitasRegistradas[i]['updated_at']) {
          
        //}
      }   else {
        _contenedores.add(
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40)
            ),
          ));
        if(i < _visitaRecompensa-1) {
          _contenedores..add(Container(width: 5, height: 20, decoration: BoxDecoration(color: Colors.white),));
        } 
      }    
    }
    return Column(children: _contenedores,);
  }

  _sendCheckin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final params = {
      "foto" : "",
      "usuario" : prefs.getInt('id'),
      "extension" : ""
    };
    final _res = await http.post(
      _urlSendCheckin,
      headers: headers,
      body: jsonEncode(params)
    );
    if(_res.statusCode == 200) {
      showDialog(context: context, builder: (_) {
        return AlertDialog(
          title: const Text('Gracias!'),
          content: const Text('Hemos recibido tu visita, pronto recibirás un correo de confirmación de tu visita.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Ok'))
          ],
        );
      });
    }
  }
}