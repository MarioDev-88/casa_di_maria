import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:cotizador_casa_di_maria/models/Cotizacion.dart';
import 'package:cotizador_casa_di_maria/services/coordinadores_service.dart';
import 'package:cotizador_casa_di_maria/services/cotizacion_service.dart';
import 'package:flutter_media_downloader/flutter_media_downloader.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/Coordinador.dart';


class ContratosPage extends StatefulWidget {
  const ContratosPage({ Key? key }) : super(key: key);

  @override
  State<ContratosPage> createState() => _ContratosPageState();
}

class _ContratosPageState extends State<ContratosPage> {

  final _flutterMediaDownloaderPlugin = MediaDownload();
  DateTime selectedDate = DateTime.now();
  DateTime selectedDateTo = DateTime.now();
  List<String> coordinadorList = <String>[];
  TextEditingController _folioController = TextEditingController();
  TextEditingController _telefonoController = TextEditingController();
  CotizacionService _cotizacionService = CotizacionService();
  CoordinadoresService _coordinadoresService = CoordinadoresService();
  Future? _cotizacionFuture;
  Future? _coordinadoresFuture;
  String? dropdownValueC;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2036),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFBD9C39), // Color mostaza para el tema
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectDateTo(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateTo,
      firstDate: DateTime(2025),
      lastDate: DateTime(2036),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFBD9C39), // Color mostaza para el tema
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDateTo) {
      setState(() {
        selectedDateTo = picked;
        _cotizacionFuture = _cotizacionService.getContrato("", "", "", selectedDate.toString().split(" ")[0], selectedDateTo.toString().split(" ")[0]);
      });
    }
  }

  String _formatDateTime(DateTime date) {
    final DateFormat formatter = DateFormat('d \'de\' MMMM \'del\' y', 'es_ES');
    return formatter.format(date);
  }

  @override
  void initState() {
    super.initState();
    _cotizacionFuture = _cotizacionService.getContrato("", "", "", "", "");
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
    final DateTime nextDay = selectedDate.add(const Duration(days: 1));
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
                'CONTRATOS',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFDAA520), // Color mostazas
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  // Widget de fecha con icono
                  Expanded(
                    child: _buildDateTimeSelector(
                      icon: Icons.calendar_today,
                      title: _formatDateTime(selectedDate),
                      onTap: () => _selectDate(context),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text("AL"),
                  // Widget de hora de fin con icono
                  Expanded(
                    child: _buildDateTimeSelector(
                      icon: Icons.calendar_today,
                      title: _formatDateTime(selectedDateTo), // Día siguiente
                      onTap: () => _selectDateTo(context) , // La fecha final no se edita, siempre es un día después
                    ),
                  )
                ],
              ),              
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
                          _cotizacionFuture = _cotizacionService.getContrato(value, "", "", "", "");
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
                          _cotizacionFuture = _cotizacionService.getContrato("", dropdownValueC, "", "", "");
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
                      _cotizacionFuture = _cotizacionService.getContrato("", "", value, "", "");
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
                    return const Center(child: Text("Sin Contratos", style: TextStyle(color: Colors.black),));
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
      physics: NeverScrollableScrollPhysics(),
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
              Text(_cotizacion.folio, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),),
              SizedBox(width: 100, child: Text(limpiarEncoding(_cotizacion.evento), style: const TextStyle(fontSize: 16), textAlign: TextAlign.left,)),
              Center(child: GestureDetector(child: const Icon(Icons.request_quote_outlined, size: 33,), onTap: () => _downloadCotizacion(_cotizacion.url_cotizacion),)),
              Center(child: GestureDetector(child: const Icon(Icons.receipt_long_sharp, size: 33,), onTap: () => _downloadContraton(_cotizacion.url_contrato, _cotizacion.id)))
            ],
          ),
        );
      }

    );

  }

  _downloadCotizacion(String? url) async {
    String _isNone = url!.split("/")[4];
    SharePlus.instance.share(
      ShareParams(uri: Uri.http("104.248.52.156", "/cotizaciones/cotizaciones/${_isNone}")),
    );
    //_flutterMediaDownloaderPlugin.downloadMedia(context, "http://104.248.52.156/cotizaciones/cotizaciones/${_isNone}");
  }

  _downloadContraton(String? url, int id) async {
    String _isNone = url!.split("/")[4];
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
        _isNone = _isNone.split("/")[4];
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
      //_flutterMediaDownloaderPlugin.downloadMedia(context, "http://104.248.52.156/cotizaciones/cotizaciones/${_isNone}", (await getApplicationDocumentsDirectory()).absolute.path); 
      //final taskId = await FlutterDownloader.enqueue(
      //  url: "http://104.248.52.156/cotizaciones/cotizaciones/${_isNone}",
      //  headers: {}, // optional: header send with url (auth token etc)
      //  savedDir: (await getApplicationDocumentsDirectory()).absolute.path
      //);

      //print(taskId);
      //return FlutterDownloader.open(taskId: taskId!);
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

  Widget _buildDateTimeSelector({
    required IconData icon,
    required String title,
    required VoidCallback onTap
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icono de calendario
            Icon(
              icon,
              size: 36,
              color: Colors.black87,
            ),
            const SizedBox(width: 10),
            // Información de fecha y hora
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}