import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_media_downloader/flutter_media_downloader.dart';
import 'package:flutter/material.dart';

import 'package:cotizador_casa_di_maria/models/Complemento.dart';
import 'package:cotizador_casa_di_maria/models/Coordinador.dart';
import 'package:cotizador_casa_di_maria/models/Platillos.dart';
import 'package:cotizador_casa_di_maria/services/coordinadores_service.dart';
import 'package:cotizador_casa_di_maria/services/cotizacion_service.dart';
import 'package:cotizador_casa_di_maria/services/evento_service.dart';
import 'package:cotizador_casa_di_maria/services/platillos_service.dart';
import 'package:cotizador_casa_di_maria/system/arguments.dart';

import '../models/Evento.dart';

class CotizarPage extends StatefulWidget {
  const CotizarPage({Key? key}) : super(key: key);

  @override
  State<CotizarPage> createState() => _CotizarPageState();
}

class _CotizarPageState extends State<CotizarPage> {
  final _flutterMediaDownloaderPlugin = MediaDownload();
  
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  DateTime selectedDate = DateTime.now();
  TimeOfDay horaInicio = const TimeOfDay(hour: 20, minute: 0);
  TimeOfDay horaFin = const TimeOfDay(hour: 1, minute: 0);
  TextEditingController _adultos = TextEditingController();
  TextEditingController _jovenes = TextEditingController();
  TextEditingController _nombre = TextEditingController();
  TextEditingController _telefono = TextEditingController();
  TextEditingController _correo = TextEditingController();
  FocusNode _focusTelefono = FocusNode();
  FocusNode _focusAdulto = FocusNode();  
  bool _containerPlatilloJoven = false;
  bool _containerComplemento = false;
  List<String> list = <String>['One', 'Two', 'Three', 'Four'];
  List<String> coordinadorList = <String>[];
  List<String> eventoList = <String>[];
  List<String> platilloList = <String>[];
  List<String> platilloJovenList = <String>[];
  List<String> complementoList = <String>[];
  CoordinadoresService _coordinadoresService = CoordinadoresService();
  EventoService _eventoService = EventoService();
  PlatillosService _platillosService = PlatillosService();
  CotizacionService _cotizacionService = CotizacionService();
  Future? _coordinadoresFuture;
  Future? _eventoFuture;
  Future? _platilloFuture;
  Future? _platilloJovenFuture;
  Future? _complementoFuture;
  String? dropdownValueC;
  String? dropdownValueE;
  String? dropdownValueP;
  String? dropdownValuePJ;
  String? dropdownValueCO;

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
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      locale: const Locale("es"),
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2039),
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
  
  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? horaInicio : horaFin,
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
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          horaInicio = picked;
        } else {
          horaFin = picked;
        }
      });
    }
  }
  
  String _formatDateTime(DateTime date) {
    final DateFormat formatter = DateFormat('d \'de\' MMMM \'del\' y', 'es_ES');
    return formatter.format(date);
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final String hour = time.hour.toString().padLeft(2, '0');
    final String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute hrs';
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _coordinadoresFuture = _coordinadoresService.getCoordinadores("");
    _eventoFuture = _eventoService.getEvento();
    _platilloFuture = _platillosService.getPlatillo();
    _platilloJovenFuture = _platillosService.getPlatilloJoven();
    _complementoFuture = _platillosService.getComplemento();
    _coordinadoresFuture?.then((value) {
      for(Coordinador coordinador in value) {
        setState(() {
          coordinadorList.add(coordinador.nombre);
        });
      }
    });

    _eventoFuture?.then((value) {
      for(Evento coordinador in value) {
        setState(() {
          eventoList.add(coordinador.nombre);
        });
      }
    });

    _platilloFuture?.then((value) {
      for(Platillos coordinador in value) {
        setState(() {
          platilloList.add(coordinador.nombre);
        });
      }
    });

    _platilloJovenFuture?.then((value) {
      for(Platillos coordinador in value) {
        setState(() {
          platilloJovenList.add(coordinador.nombre);
        });
      }
    });

    _complementoFuture?.then((value) {
      for(Complemento coordinador in value) {
        setState(() {
          if(coordinador.id == 4 || coordinador.id == 5){
            complementoList.add(coordinador.nombre);
          }          
        });
      }
    });
  }
  
  @override
  void dispose() {
    _nombre.dispose();
    _telefono.dispose();
    _correo.dispose();
    _adultos.dispose();
    _focusTelefono.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DateTime nextDay = selectedDate.add(const Duration(days: 1));
    return Scaffold(
      appBar: AppBar(title: const Text(''), backgroundColor: const Color(0xFFF5F1F1), foregroundColor: const Color(0xFF253D5B), forceMaterialTransparency: true,),
      backgroundColor: const Color(0xFFF5F1F1),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'COTIZAR',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFDAA520), // Color mostazas
                  ),
                ),
                const SizedBox(height: 20),
                // Subtítulo "DIA Y HORA"
                const Text(
                  'DIA Y HORA',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF253D5B),
                  ),
                ),
                Row(
                  children: [
                    // Widget de fecha con icono
                    Expanded(
                      child: _buildDateTimeSelector(
                        icon: Icons.calendar_today,
                        title: _formatDateTime(selectedDate),
                        subtitle: 'De ${_formatTimeOfDay(horaInicio)}',
                        onTap: () => _selectDate(context),
                        onTimeTap: () => _selectTime(context, true),
                      ),
                    ),
                    const SizedBox(width: 16),
                     // Widget de hora de fin con icono
                    Expanded(
                      child: _buildDateTimeSelector(
                        icon: Icons.calendar_today,
                        title: _formatDateTime(nextDay), // Día siguiente
                        subtitle: 'De ${_formatTimeOfDay(horaFin)}',
                        onTap: () {}, // La fecha final no se edita, siempre es un día después
                        onTimeTap: () => _selectTime(context, false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Text(
                  'CLIENTE',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF253D5B),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextFormField(                  
                    controller: _nombre,
                    decoration: const InputDecoration(
                      suffixIcon: IconButton(onPressed: null, icon: Icon(Icons.account_box)),
                      hintText: "Nombre",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    style: const TextStyle(fontSize: 16),
                    validator: (String? value) {
                      if(value == null || value.isEmpty) {
                        return 'Ingrese el nombre del cliente';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextFormField(
                    controller: _telefono,
                    focusNode: _focusTelefono,
                    maxLength: 10,
                    keyboardType: const TextInputType.numberWithOptions(decimal: false),
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      counterText: "10 Dígitos",
                      suffixIcon: IconButton(onPressed: () { 
                        _focusTelefono.unfocus();
                      }, icon: const Icon(Icons.phone)),
                      hintText: "Teléfono",
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    style: const TextStyle(fontSize: 16),
                    validator: (String? value) {
                      if(value == null || value.isEmpty) {
                        return 'Ingrese el teléfono';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _correo,
                    decoration: const InputDecoration(
                      suffixIcon: IconButton(onPressed: null, icon: Icon(Icons.email)),
                      hintText: "Correo Electrónico",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'COORDINADOR',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF253D5B),
                  ),
                ),
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton(
                    value: dropdownValueC,
                    isExpanded:true,
                    iconSize: 36,
                    hint: const Text("Coordinadores"),
                    icon: const Icon(Icons.arrow_drop_down),
                    items: coordinadorList.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(value: value, child: Text(limpiarEncoding(value)));
                      }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        dropdownValueC = value!;
                      });
                    },
                  )
                ),
                const SizedBox(height: 30),
                const Text(
                  'EVENTO',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF253D5B),
                  ),
                ),
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton(
                    isExpanded: true,
                    iconSize: 36,
                    hint: const Text("Seleccione un evento"),
                    value: dropdownValueE,
                    icon: const Icon(Icons.arrow_drop_down),
                    elevation: 16,
                    items: eventoList.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(value: value, child: Text(limpiarEncoding(value)));
                      }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        dropdownValueE = value!;
                        if(limpiarEncoding(value) == 'XV Años') {                        
                          _containerPlatilloJoven = true;
                        } else {
                          _containerPlatilloJoven = false;
                        }
                      });
                    },
                  )
                ),
                const SizedBox(height: 30),
                const Text(
                  'ADULTOS',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF253D5B),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextFormField(                  
                    autocorrect: false,
                    controller: _adultos,
                    focusNode: _focusAdulto,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.number,                  
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,                
                    ],
                    decoration: InputDecoration(     
                      hintText: "Ej. 100",               
                      suffixIcon: IconButton(onPressed: () {
                        _focusAdulto.unfocus();
                      }, icon: const Icon(Icons.plus_one)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    style: const TextStyle(fontSize: 16),
                    validator: (String? value) {
                      if(value == null || value.isEmpty) {
                        return 'Ingrese el numero de adultos';
                      }
                    }
                  ),
                ),
                const SizedBox(height: 30),
                Visibility(
                  visible: _containerPlatilloJoven,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Text(
                        'JOVENES',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF253D5B),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextFormField(
                          autocorrect: false,
                          controller: _jovenes,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,                
                          ],
                          decoration: InputDecoration(
                            hintText: "Ej. 100",
                            suffixIcon: IconButton(onPressed: () {
                              _focusAdulto.unfocus();
                            }, icon: const Icon(Icons.plus_one)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                          ),
                          style: const TextStyle(fontSize: 16),
                          validator: (String? value) {
                            if(value == null || value.isEmpty) {
                              return 'Ingrese el numero de jovenes';
                            }
                          }      
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'PLATILLO ADULTO',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF253D5B),
                  ),
                ),
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton(
                    isExpanded: true,
                    iconSize: 36,
                    hint: const Text("Seleccione un platillo"),
                    value: dropdownValueP,
                    icon: const Icon(Icons.arrow_drop_down),
                    elevation: 16,
                    items: platilloList.map<DropdownMenuItem<String>>((String value) {
                      if(dropdownValueE != null) {
                        if(limpiarEncoding(dropdownValueE!) != "XV Años" && value == "Jovenes") {
                          return DropdownMenuItem<String>(value: value, child: const Text(""),);
                        } else {
                          return DropdownMenuItem<String>(value: value, child: Text(limpiarEncoding(value)));
                        }
                      } else {
                        return DropdownMenuItem<String>(value: "", child: Text(""),);
                      }               
                      }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        if(value == 'Pollo' || value == 'Puerco') {
                          _containerComplemento = true;
                        } else {
                          _containerComplemento = false;
                        }
                        dropdownValueP = value!;
                      });
                    },
                  )
                ),
                const SizedBox(height: 30),
                Visibility(
                  visible: _containerPlatilloJoven,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PLATILLO JOVEN',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF253D5B),
                        ),
                      ),
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton(
                          isExpanded: true,
                          iconSize: 36,
                          hint: const Text("Seleccione un platillo"),
                          value: dropdownValuePJ,
                          icon: const Icon(Icons.arrow_drop_down),
                          elevation: 16,
                          items: platilloJovenList.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(value: value, child: Text(value));
                            }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              dropdownValuePJ = value!;
                            });
                          },
                        )
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15,),
                Visibility(
                  visible: _containerComplemento,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'COMPLEMENTO',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF253D5B),
                        ),
                      ),
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton(
                          isExpanded: true,
                          iconSize: 36,
                          hint: const Text("Seleccione un complemento"),
                          value: dropdownValueCO,
                          icon: const Icon(Icons.arrow_drop_down),
                          elevation: 16,
                          items: complementoList.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(value: value, child: Text(value));
                            }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              dropdownValueCO = value!;
                            });
                          },
                        )
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30,),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFBD9C39),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("CREAR COTIZACIÓN"),
                    onPressed: (){
                      _crearCotizacion();
                    },
                  ),
                )
              ]
            )
          ),
        ),
      )
    );
  }

  _crearCotizacion() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if(_formKey.currentState!.validate()) {
      if(dropdownValueE == null || dropdownValueC == null || dropdownValueP == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text("Error: Falta información."),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          )
        );
        return;
      }
      if(dropdownValueE == "XV AÃ±os") {
        dropdownValueE = "XV Años";
      }
      Map json = {
        "telefono_novio": _telefono.text,
        "nombre_novio": _nombre.text,
        "nombre_novia": "",
        "telefono_novia": "",
        "correo": _correo.text,
        "fecha_evento": dateFormat.format(selectedDate),
        "hora_inicio": "${horaInicio.hour.toString().padLeft(2, '0')}:${horaInicio.minute.toString().padLeft(2, '0')}",
        "hora_fin": "${horaFin.hour.toString().padLeft(2, '0')}:${horaFin.minute.toString().padLeft(2, '0')}",
        "id_evento": dropdownValueE,
        "id_platillo": limpiarEncoding(dropdownValueP!),
        "personas": _adultos.text,
        "colaborador": dropdownValueC,
        "usuario": prefs.getInt("id")
      };

      if(dropdownValueP == 'Pollo' || dropdownValueP == 'Puerco') {
        json['adicional'] = dropdownValueCO;
      }

      if(json["id_evento"] == "XV Años") {
        json['id_platillo_joven'] = dropdownValuePJ;
        json['personas_jovenes'] =  _jovenes.text;
      }      
      
      _cotizacionService.createCotizacion(json).then((value) {
        if(value.containsKey('creado') && value['creado']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text('Cotización guardada'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            )
          );
          String _isNone = value['data']['documento_url'].toString().split("/").last;
          SharePlus.instance.share(
            ShareParams(uri: Uri.http("104.248.52.156", "/cotizaciones/cotizaciones/${_isNone}")),
          );     
               
          //_flutterMediaDownloaderPlugin.downloadMedia(context, value['data']['documento_url']);
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.deepOrange,
              content: Text("Este telefono ya esta asociado a la cotizacion: ${value['folio']}", style: TextStyle(fontWeight: FontWeight.bold),),
              duration: const Duration(seconds: 5),
              behavior: SnackBarBehavior.fixed,
              showCloseIcon: true,
            )
          );
        }
      }).onError((error, stackTrace) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(error.toString()),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          )
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("Error: Falta información."),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        )
      );
    }    
  }

}

Widget _buildDateTimeSelector({
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
  required VoidCallback onTimeTap,
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
                const SizedBox(height: 4),
                InkWell(
                  onTap: onTimeTap,
                  child: Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
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