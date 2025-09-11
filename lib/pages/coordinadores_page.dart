import 'dart:convert';

import 'package:cotizador_casa_di_maria/models/Coordinador.dart';
import 'package:cotizador_casa_di_maria/services/coordinadores_service.dart';
import 'package:flutter/material.dart';
import 'package:cotizador_casa_di_maria/system/arguments.dart';
import 'package:intl/intl.dart';

class CoordinadoresPage extends StatefulWidget {
  const CoordinadoresPage({Key? key}) : super(key: key);

  @override
  State<CoordinadoresPage> createState() => _CoordinadoresPageState();
}

class _CoordinadoresPageState extends State<CoordinadoresPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final CoordinadoresService _coordinadoresService = CoordinadoresService();
  Future<dynamic>? _coordinadoresFuture;

  @override
  void initState() {
    super.initState();
    _coordinadoresFuture = _coordinadoresService.getCoordinadores("");
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
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
                'COORDINADORES',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFDAA520), // Color mostazas
                ),
              ),
              // Campo de búsqueda mejorado
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  decoration: InputDecoration(
                    hintText: 'Nombre',
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey.shade600,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            color: Colors.grey.shade600,
                            onPressed: () {
                              _searchController.clear();
                              _searchFocus.unfocus();
                              setState(() {
                                _coordinadoresFuture = _coordinadoresService.getCoordinadores("");
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                  ),
                  style: const TextStyle(fontSize: 16),
                  onChanged: (value) {
                    setState(() {
                      if(value.length >= 3) {
                        _coordinadoresFuture = _coordinadoresService.getCoordinadores(value);
                      }
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
               // Botón AGREGAR
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  onPressed: _agregarCoordinador,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBD9C39),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'AGREGAR',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              FutureBuilder(
                future: _coordinadoresFuture,
                builder: (_, AsyncSnapshot snap) {
                  if(snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snap.hasError) {
                    return Center(child: Text('Error: ${snap.error}'));
                  } else if(snap.hasData && !snap.data.isEmpty) {
                    return _showResults(snap.data);
                  } else {
                    return const Center(child: Text("Sin Coordinadores", style: TextStyle(color: Colors.black),));
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _showResults(List<Coordinador> coordinador) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: coordinador.length,
      itemBuilder: (_, i) {
        final _coordinador = coordinador[i];
        return Visibility(
          visible: _coordinador.status,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 18.0, left: 5.0),
                child: Text(
                  limpiarEncoding(_coordinador.nombre),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Titillium',
                    fontSize: 16,
                    color: Color(0xFF253D5B)
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _deleteCoordinador(_coordinador.id),
                child: const Icon(
                  Icons.delete_forever,
                  size: 35,
                  color: Color(0xFF253D5B),
                ),
              )                  
            ],              
          ),
        );
      },
    );
  }

  _agregarCoordinador() async {
    String coordinador = "";
    if(_searchController.text.isNotEmpty) {
      coordinador = _searchController.text;
      _coordinadoresService.addCoordinador(coordinador).then((value) {
        if(value) {   
          setState(() {
            _coordinadoresFuture = _coordinadoresService.getCoordinadores("");
          });       
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text('Coordinador guardado'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            )
          );
          _searchController.clear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text('Hubo un error al guardar. Intente mas tarde'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            )
          );
          _searchController.clear();
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Ingrese el nombre del Coordinador'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        )
      );
    }
  }

  _deleteCoordinador(int id) async {
    showAdaptiveDialog(context: context, builder: (_) {
      return AlertDialog(
        title: const Text("Aviso"),
        content: const Text('¿Esta seguro/a que desea eliminar a este coordinador?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          TextButton(onPressed: () async {
            _coordinadoresService.deleteCoordinador(id).then((value) {
              Navigator.of(context).pop();
              if(value) {
                setState(() {
                  _coordinadoresFuture = _coordinadoresService.getCoordinadores("");
                });  
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.green,
                    content: Text('Coordinador eliminado'),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  )
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.red,
                    content: Text('Hubo un error. Intente mas tarde'),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  )
                );
              }
            });
          }, child: const Text('Si, eliminar'))
        ],
      );
    });
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