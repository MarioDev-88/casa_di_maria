import 'package:cotizador_casa_di_maria/system/arguments.dart';
import 'package:flutter/material.dart';
import 'package:cotizador_casa_di_maria/system/globals.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DirectionPage extends StatefulWidget {
  const DirectionPage({Key? key}) : super(key: key);

  @override
  State<DirectionPage> createState() => _DirectionPageState();
}

class _DirectionPageState extends State<DirectionPage> {
  final _urlColonias = Uri.https('zesty.com.mx', '/apps/apiapps/v1/checkcolonia/');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _calle = TextEditingController();
  final TextEditingController _numero = TextEditingController();
  final TextEditingController _codigoPostal = TextEditingController();
  final TextEditingController _referencia = TextEditingController();
  final List<String> _colonias = <String>[];
  late List<String> _listadoDirecciones;
  String _coloniaV = '';
  bool _isMatch = false;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchColonias();
  }

  @override
  void dispose() {    
    focusNode.dispose();
    _colonias.clear();  
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar dirección')),
      backgroundColor: Colors.yellow,
      body: _crearForm(),
    );
  }
  
  Widget _crearForm() {
    return SafeArea(
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Container(
              margin: const EdgeInsets.all(15.0),
              child: Focus(
                onFocusChange: (value) {},
                child: Autocomplete<String>(          
                  fieldViewBuilder: (context, _colonia, _focusNode, onFieldSubmitted) => TextFormField(
                    controller: _colonia,
                    focusNode: _focusNode,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    autocorrect: false,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: "Busca tu colonia",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0)
                      ),
                    ),
                    validator: (String? value) {
                      if(value == null || value.isEmpty) {
                        return 'Ingrese una colonia';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        focusNode = _focusNode;
                      });
                    },
                    onFieldSubmitted: (value){
                        if(!_isMatch) {                   
                          showDialog(context: context, barrierDismissible: false, builder: (_) {
                            return AlertDialog(
                              title: const Text('Aviso'),
                              content: const Text('Colonia no esta dentro de la cobertura'),
                              actions: [
                                TextButton(onPressed: () {
                                  FocusScope.of(context).requestFocus(focusNode);
                                  Navigator.of(context).pop();
                                }, child: const Text('Cerrar'))
                              ],
                            );
                          });
                        }
                    },
                  ),
                  optionsBuilder: (_textEditingValue) {
                    if(_textEditingValue.text.isEmpty) {                    
                      return List.empty();
                    }
                    var result = _colonias.where((String option) => option.toLowerCase().contains(_textEditingValue.text.toLowerCase()));
                    if(result.isNotEmpty) {                      
                      return _colonias.where((String option) {                        
                        return option.toLowerCase().contains(_textEditingValue.text.toLowerCase());
                      });
                    } else {
                      _isMatch = false;
                      return List.empty();        
                    }                  
                  },
                  onSelected: (option) {     
                    setState(() {
                      _isMatch = true;
                    });
                    _coloniaV = option;
                  },
                ),
              ),
            ),
            Visibility(
              visible: _isMatch,
              child: Container(
                margin: const EdgeInsets.all(20.0),
                child: TextFormField(
                  onTap: () {
                    if(!_isMatch) {
                      FocusScope.of(context).requestFocus(focusNode);
                    }
                  },
                  controller: _calle,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0)
                    ),
                    label: const Text('Calle')
                  ),
                  validator: (String? value) {
                    if(value == null || value.isEmpty) {
                      return 'Ingrese una calle';
                    }
                    return null;
                  },
                ),
              ),
            ),
            Visibility(
              visible: _isMatch,
              child: Container(
                margin: const EdgeInsets.all(20.0),
                child: TextFormField(
                  onTap: () {
                    if(!_isMatch) {
                      FocusScope.of(context).requestFocus(focusNode);
                    }
                  },
                  controller: _numero,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0)
                    ),
                    label: const Text('Numero')
                  ),
                  validator: (String? value) {
                    if(value == null || value.isEmpty) {
                      return 'Ingrese un numero de casa / edificio';
                    }
                    return null;
                  },
                ),
              ),
            ),
            Visibility(
              visible: _isMatch,
              child: Container(
                margin: const EdgeInsets.all(20.0),
                child: TextFormField(
                  onTap: () {
                    if(!_isMatch) {
                      FocusScope.of(context).requestFocus(focusNode);
                    }
                  },
                  maxLength: 5,
                  keyboardType: TextInputType.number,
                  controller: _codigoPostal,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0)
                    ),
                    label: const Text('Código postal')
                  ),              
                ),
              ),
            ),
            Visibility(
              visible: _isMatch,
              child: Container(
                margin: const EdgeInsets.all(20.0),
                child: TextFormField(
                  onTap: () {
                    if(!_isMatch) {
                      FocusScope.of(context).requestFocus(focusNode);
                    }
                  },
                  controller: _referencia,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0)
                    ),
                    label: const Text('Entre calles / Referencia')
                  ),
                  validator: (String? value) {          
                    return null;
                  },
                ),
              ),
            ),
            Visibility(
              visible: _isMatch,
              child: Center(
                child: SizedBox(
                  width: 200.0,
                  height: 50.0,
                  child: ElevatedButton(
                    onPressed: () {
                      // Validate will return true if the form is valid, or false if
                      // the form is invalid.
                      if (_formKey.currentState!.validate()) {
                        // Process data.     
                        if(_coloniaV.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              duration: Duration(seconds: 3),
                              closeIconColor: Colors.white,
                              showCloseIcon: true,
                              backgroundColor: Colors.red,
                              content: Text("La colonia no se encuentra registrada. Ingrese una colonia de la lista.",
                                style: TextStyle(fontWeight: FontWeight.w600),),
                            )
                          );
                          return;
                        }
                        _guardarDireccion();              
                      }
                    },
                    child: const Text('Confirmar dirección'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _fetchColonias() async {
    var _res = await http.post(
      _urlColonias,
      headers: headers,
      body: jsonEncode({
        'colonia' : ""
      })
    );
    List _response = jsonDecode(_res.body)['colonias'];
    _response.forEach((element) { 
      _colonias.add(element);
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _listadoDirecciones = prefs.getStringList('address') ?? [];
    });
  }
  
  void _guardarDireccion() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool fromRestaurant = true;
    if(_listadoDirecciones.isEmpty) {
      fromRestaurant = false;
    }
    final String _finalAddress = _calle.text + " " + _numero.text + "," + _coloniaV;
    _listadoDirecciones.add(_finalAddress);
    prefs.setString("calle", _calle.text);
    prefs.setString("entre", _referencia.text);
    prefs.setString("numero", _numero.text);
    prefs.setString("colonia", _coloniaV);
    prefs.setString("codigo_postal", _codigoPostal.text);
    prefs.setString('actualAddress', _finalAddress);
    prefs.setStringList('address', _listadoDirecciones);
    if(fromRestaurant) {
      Navigator.popAndPushNamed(context, 'restaurant', arguments: AppArguments('Servicio a domicilio', '', ''));
    } else {
      Navigator.pushReplacementNamed(
        context, 
        'restaurant', 
        arguments: AppArguments('Servicio a domicilio', '', '')
      );
    }
  }
}