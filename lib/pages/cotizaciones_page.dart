import 'package:share_plus/share_plus.dart';
import 'package:cotizador_casa_di_maria/models/Cotizacion.dart';
import 'package:cotizador_casa_di_maria/services/coordinadores_service.dart';
import 'package:cotizador_casa_di_maria/services/cotizacion_service.dart';
import 'package:flutter_media_downloader/flutter_media_downloader.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/Coordinador.dart';


class CotizacionesPage extends StatefulWidget {
  const CotizacionesPage({ Key? key }) : super(key: key);

  @override
  State<CotizacionesPage> createState() => _CotizacionesPageState();
}

class _CotizacionesPageState extends State<CotizacionesPage> {

  final _flutterMediaDownloaderPlugin = MediaDownload();
  List<String> coordinadorList = <String>[];
  TextEditingController _folioController = TextEditingController();
  TextEditingController _telefonoController = TextEditingController();
  CotizacionService _cotizacionService = CotizacionService();
  CoordinadoresService _coordinadoresService = CoordinadoresService();
  Future? _cotizacionFuture;
  Future? _coordinadoresFuture;
  String? dropdownValueC;

  @override
  void initState() {
    super.initState();
    _cotizacionFuture = _cotizacionService.getCotizacion("", "", "");
    _coordinadoresFuture = _coordinadoresService.getCoordinadores("");

    _coordinadoresFuture?.then((value) {
      for(Coordinador coordinador in value) {
        setState(() {
          coordinadorList.add(coordinador.nombre);
        });
      }
    });
  }

  @override
  void dispose() {
    _telefonoController.dispose();
    _folioController.dispose();
    super.dispose();    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(''), backgroundColor: const Color(0xFFF5F1F1), forceMaterialTransparency:true),
      backgroundColor: const Color(0xFFF5F1F1),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'COTIZACIONES',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFDAA520), // Color mostazas
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3,
                    child: TextField(
                      controller: _folioController,
                      autocorrect: false,
                      decoration: const InputDecoration(
                          hintText: 'Folio'
                      ),
                      onSubmitted: (value) {
                        setState(() {
                          _cotizacionFuture = _cotizacionService.getCotizacion(value, "", "");
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2,
                    child:  DropdownButton(
                      value: dropdownValueC,
                      isExpanded:true,
                      hint: const Text("Coordinadores"),
                      icon: const Icon(Icons.arrow_drop_down),
                      items: coordinadorList.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(value: value, child: Text(limpiarEncoding(value)));
                        }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          dropdownValueC = value!;
                          _cotizacionFuture = _cotizacionService.getCotizacion("", dropdownValueC, "");
                        });
                      },
                    )
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _telefonoController,
                autocorrect: false,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: 'Teléfono'
                ),
                onChanged: (value) {
                  if(value.length > 4) {
                    setState(() {
                      _cotizacionFuture = _cotizacionService.getCotizacion("", "", value);
                    });
                  }                
                },
              ),
              const SizedBox(height: 10),
              FutureBuilder(
                future: _cotizacionFuture,
                builder: (_, AsyncSnapshot snap) {
                  if(snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snap.hasError) {
                    return Center(child: Text('Error: ${snap.error}'));
                  } else if(snap.hasData && !snap.data.isEmpty) {
                    return _showResults(snap.data);
                  } else {
                    return const Center(child: Text("Sin Cotizaciones", style: TextStyle(color: Colors.black),));
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _showResults(List<Cotizacion> cotizacion) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: cotizacion.length,
      itemBuilder: (_, i) {
        final _cotizacion = cotizacion[i];
        return SizedBox(
          height: 55,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(child: Text(_cotizacion.folio, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),)),
              SizedBox(width: 100, child: Text(limpiarEncoding(_cotizacion.evento), style: const TextStyle(fontSize: 17, color: const Color(0xFF253D5B),), textAlign: TextAlign.left,)),
              Text("${_cotizacion.expiracion} Dias", style: const TextStyle(fontSize: 16, color: const Color(0xFF253D5B)), textAlign: TextAlign.left,),
              GestureDetector(child: const Icon(Icons.find_in_page_outlined, size: 33,), onTap: () => _downloadCotizacion(_cotizacion.url_cotizacion),),
              Center(child: GestureDetector(child: Icon(Icons.check_circle_outline_outlined, size: 33,), onTap: () => _downloadContraton(_cotizacion.url_contrato, _cotizacion.id)))
            ],
          ),
        );
      }

    );

  }

  _downloadCotizacion(String? url) async {
    String _isNone = url!.split("/").last;
    SharePlus.instance.share(
      ShareParams(uri: Uri.http("104.248.52.156", "/cotizaciones/cotizaciones/${_isNone}")),
    );
    //_flutterMediaDownloaderPlugin.downloadMedia(context, url!);
  }

  _downloadContraton(String? url, int id) async {
    String _isNone = url!.split("/").last;
    if(_isNone == "None") {
      _cotizacionService.crearContrato(id).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Contrato generado correctamente. Descargando.."),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          )
        );
        _isNone = value['data']['contrato_url'];
        _isNone = _isNone!.split("/").last;
        SharePlus.instance.share(
          ShareParams(uri: Uri.http("104.248.52.156", "/cotizaciones/cotizaciones/${_isNone}")),
        );
        //_flutterMediaDownloaderPlugin.downloadMedia(context, value['data']['contrato_url']); 
        setState(() {
          _cotizacionFuture = _cotizacionService.getCotizacion("", "", "");
        });

      }).onError((error, stackTrace) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text("Error al crear contrato. Intente mas tarde"),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          )
        );
      });      
    } else {
      SharePlus.instance.share(
        ShareParams(uri: Uri.http("104.248.52.156", "/cotizaciones/cotizaciones/${_isNone}")),
      );
      //_flutterMediaDownloaderPlugin.downloadMedia(context, url); 
    }    
  }

  // Función helper para limpiar encoding
  String limpiarEncoding(String texto) {
    try {
      // Intentar diferentes decodificaciones
      List<int> bytes = latin1.encode(texto);
      return utf8.decode(bytes, allowMalformed: true);
    } catch (e) {
      return texto; // Devolver el original si falla
    }
  }
}