import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:maps_launcher/maps_launcher.dart';

import 'package:cotizador_casa_di_maria/themes/custom.dart';
import 'package:cotizador_casa_di_maria/system/arguments.dart';
import 'package:cotizador_casa_di_maria/system/globals.dart';
import 'package:cotizador_casa_di_maria/presentation/navbar.dart';

class SelectMainPage extends StatefulWidget {
  const SelectMainPage({ Key? key }) : super(key: key);

  @override
  State<SelectMainPage> createState() => _SelectMainPageState();
}

class _SelectMainPageState extends State<SelectMainPage> {
  final _urlSugerencia = Uri.https('zesty.com.mx', '/apps/apiapps/v1/sugerencias/');
  final _urlDetalle = Uri.https('zesty.com.mx', '/apps/apiapps/v1/detallesrestaurante/');
  bool _statusCheckin = false;
  String _direccion = '';
  String _telefono = '';
  String _coords = '';
  bool _statusPromos = false;
  final List<String> _listCoords = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //_fetchDetalle();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      drawer: const Navbar(),
      appBar: AppBar(
        title: const Center(child: Text('')),
        backgroundColor: const Color(0xFFF5F1F1),
      ),
      backgroundColor: const Color(0xFFF5F1F1),
      body: SafeArea(
        child: DecoratedBox(
          decoration: const BoxDecoration(          
            image: DecorationImage(image: AssetImage("assets/fondo_casadimaria.jpeg"), fit: BoxFit.cover)
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/LogoCasaDiMaria.png'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _fetchDetalle() async {
    final _res = await http.post(
      _urlDetalle,
      headers: headers,
      body: jsonEncode({})
    );
    if(_res.statusCode == 200) {
      final _response = jsonDecode(_res.body);
      setState(() {
        _statusCheckin = _response['checkin'];
        _direccion = _response['direccion'];
        _telefono = _response['telefono'];
        _coords = _response['location'];
        _listCoords.addAll(_coords.split(','));
        if(int.parse(_response['vales']) >= 1) {
          _statusPromos = true;
        }
      });
    }
  }
  
  void _goDirectionRestaurant() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    //int? _countAddress = prefs.getStringList('address')?.length ?? 0;
    if(prefs.getStringList('address') != null && prefs.getStringList('address')!.isNotEmpty) {
      prefs.setString("servicio", "Servicio a domicilio");
      Navigator.pushNamed(
        context, 'restaurant', 
        arguments: AppArguments('Servicio a domicilio', '', '')
      );
    } else {
      Navigator.pushNamed(
        context, 'direction', 
        arguments: AppArguments('Servicio a domicilio', '', '')
      );
    }
  }

  void _goRestaurant() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("servicio", "Ordena y recoja");
    Navigator.pushNamed(
      context, 'restaurant', 
      arguments: AppArguments('Ordena y recoja', '', '')
    );
  }

  void _openCheckin() {
    Navigator.pushNamed(context, 'checkin');
  }
  
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }
  
  Future<void> _goMap() async {
    //MapsLauncher.launchQuery(_direccion);
  }

  Future<void> _openModalSugerencia() async {
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: const Text(
          'Buzón de sugerencias',
          style: TextStyle(
            fontSize: 25.0
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('¿Alguna idea de mejora, sugerencia?'),
            const SizedBox(height: 10.0,),
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: const InputDecoration(      
                border: OutlineInputBorder(),          
                hintText: '',
              ),
            ),
            const SizedBox(height: 10.0,),
            FilledButton(
              onPressed: _sendSugerencia, 
              child: const Text('Enviar') )            
          ],
        ),
      );
    });
  }

  void _sendSugerencia() async {
    if(_controller.text.isNotEmpty) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final _res = await http.post(
        _urlSugerencia,
        headers: headers,
        body: jsonEncode({
          'usuario' : prefs.getInt('id').toString(),
          'message' : _controller.text
        })
      );

      if(_res.statusCode == 201) {
        Navigator.of(context).pop();
        showDialog(context: context, builder: (context) {
          return AlertDialog(
            title: const Text('Sugerencia enviada!'),
            content: FilledButton(
              onPressed: () => {
                Navigator.of(context).pop(),
                _controller.clear()
              },
              child: const Text('Cerrar'),
            ),
          );
        });
      }
    }    
  }
  
  void _openVales() async {
    Navigator.pushNamed(context, 'beneficios');
  }
}