import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maps_launcher/maps_launcher.dart';

import 'package:elotes_make/themes/custom.dart';
import 'package:elotes_make/system/arguments.dart';
import 'package:elotes_make/system/globals.dart';
import 'package:elotes_make/presentation/navbar.dart';

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
    _fetchDetalle();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      drawer: const Navbar(),
      appBar: AppBar(
        title: const Center(child: Text('¿Que desea hacer?')),
        actions: [
          IconButton(
            onPressed: () => setState(() {
              _makePhoneCall(_telefono);
            }), 
            icon: const Icon(Icons.phone)),
          IconButton(
            onPressed: _goMap, 
            icon: const Icon(Icons.location_on)
          )
        ],
      ),
      bottomNavigationBar: BottomAppBar(color: customTheme.primary,),
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/fondo.jpg'), fit: BoxFit.cover)
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png'),
              const SizedBox(height: 40.0,),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [                  
                  SizedBox(
                    height: 50.0,
                    width: 170.0,
                    child: FilledButton(
                      child: const Text(
                        'Servicio a domicilio',
                        style: TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w600
                        ),
                      ),
                      onPressed: _goDirectionRestaurant,
                    ),
                  ),
                  SizedBox(
                    width: 170.0,
                    height: 50.0,
                    child: FilledButton(
                      child: const Text(
                        'Ordene y recoja',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600
                        ),
                      ),
                      onPressed: _goRestaurant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40.0,),
              Row( 
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(
                    height: 50.0,
                    width: 170.0,
                  ),
                  SizedBox(
                    height: 50.0,
                    width: 170.0,
                    child: Visibility(
                      visible: _statusCheckin,
                      child: FilledButton(
                        child: const Text(
                          'Check in',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600
                          ),
                        ),
                        onPressed: _statusCheckin ? _openCheckin : null,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40.0,),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: 50.0,
                    width: 170.0,
                    child: FilledButton(
                      child: const Text(
                        'Sugerencias',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600
                        ),
                      ),
                      onPressed: _openModalSugerencia,
                    ),
                  ),
                  SizedBox(
                    height: 50.0,
                    width: 170.0,
                    child: Visibility(
                      visible: _statusPromos,
                      child: FilledButton(
                        child: const Text(
                          'Vale de regalo',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600
                          ),
                        ),
                        onPressed: 
                          _statusPromos ?
                          _openVales
                          : null,
                      ),
                    ),
                  ),
                ],
              )
            ],
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
    MapsLauncher.launchQuery(_direccion);
    // final Uri launchUri = Uri(
    //   scheme: 'https',
    //   host: 'maps.google.com',
    //   queryParameters: {
    //     'q' : _direccion
    //   } 
    // );

    // if(await canLaunchUrl(launchUri)) {
    //   launchUrl(launchUri);
    // }
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