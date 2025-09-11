import 'package:cotizador_casa_di_maria/models/Platillos.dart';
import 'package:cotizador_casa_di_maria/services/costofijo_service.dart';
import 'package:cotizador_casa_di_maria/services/platillos_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cotizador_casa_di_maria/system/globals.dart';

import '../models/CostoFijo.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({ Key? key }) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _url = Uri.https('zesty.com.mx', '/apps/apiapps/v1/addusuario/');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _pwd = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final MaterialStatesController _button = MaterialStatesController();
  // Service
  final CostoFijoService _costofijoService = CostoFijoService();
  final PlatillosService _platillosService = PlatillosService();
  Future? _costofijoFuture;
  Future? _platilloFuture;

  // Controladores para los campos de texto de precio fijo
  final TextEditingController _precio30a199 = TextEditingController(text: "0");
  final TextEditingController _precio200a299 = TextEditingController(text: "0");
  final TextEditingController _precio300a499 = TextEditingController(text: "0");

  // Controladores para los campos de texto de platillos
  final TextEditingController _precioPollo = TextEditingController(text: "0");
  final TextEditingController _precioPuerco = TextEditingController(text: "0");
  final TextEditingController _precioItaliano = TextEditingController(text: "0");
  final TextEditingController _precioMixto = TextEditingController(text: "0");
  final TextEditingController _precioPremium = TextEditingController(text: "0");
  final TextEditingController _precioParrillada = TextEditingController(text: "0");
  final TextEditingController _precioGuisos = TextEditingController(text: "0");
  final TextEditingController _precioJovenes = TextEditingController(text: "0");
  // Controladores para los campos de textp de platillos en promocion
  final TextEditingController _precioPolloPromo = TextEditingController(text: "0");
  final TextEditingController _precioPuercoPromo = TextEditingController(text: "0");
  final TextEditingController _precioItalianoPromo = TextEditingController(text: "0");
  final TextEditingController _precioMixtoPromo = TextEditingController(text: "0");
  final TextEditingController _precioPremiumPromo = TextEditingController(text: "0");
  final TextEditingController _precioParrilladaPromo = TextEditingController(text: "0");
  final TextEditingController _precioGuisosPromo = TextEditingController(text: "0");
  final TextEditingController _precioJovenesPromo = TextEditingController(text: "0");

  @override
  void initState() {
    super.initState();
    _costofijoFuture = _costofijoService.getCostoFijo();
    _platilloFuture = _platillosService.getPlatillo();
  }

  @override
  void dispose() {
    // Liberar los controladores
    _precio30a199.dispose();
    _precio200a299.dispose();
    _precio300a499.dispose();
    _precioPollo.dispose();
    _precioPuerco.dispose();
    _precioItaliano.dispose();
    _precioMixto.dispose();
    _precioPremium.dispose();
    _precioParrillada.dispose();
    _precioGuisos.dispose();
    _precioJovenes.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(''), backgroundColor: const Color(0xFFF5F1F1), forceMaterialTransparency:true),
      backgroundColor: const Color(0xFFF5F1F1),
      body: SafeArea(child: _crearForm()),
    );
  }

  Widget _crearForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView( 
        padding: const EdgeInsets.all(20.0),       
        child: 
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
          const Text(
            'COSTOS',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFFDAA520), // Color mostazas
            ),
          ),
          const SizedBox(height: 40,),
          const Text(
            'PRECIO FIJO',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF253D5B),
            ),
          ),
          const SizedBox(height: 20),
          FutureBuilder(
            future: _costofijoFuture,
            builder: (_, AsyncSnapshot snap) {
              if(snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snap.hasError) {
                return Center(child: Text('Error: ${snap.error}'));
              } else if(snap.hasData && !snap.data.isEmpty) {
                return _showResults(snap.data);
              }
              else {
                return const Center(child: Text("Sin Costos Fijos", style: TextStyle(color: Colors.black),));
              }
            }
          ),          
          const SizedBox(height: 40),
          // Sección de Platillo
          const Text(
            'PLATILLO',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF253D5B),
            ),
          ),
          const SizedBox(height: 20),
          FutureBuilder(
            future: _platilloFuture,
            builder: (_, AsyncSnapshot snap) {
              if(snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snap.hasError) {
                return Center(child: Text('Error: ${snap.error}'));
              } else if(snap.hasData && !snap.data.isEmpty) {
                return _showResultsPlatillo(snap.data);
              }
              else {
                return const Center(child: Text("Sin Platillos", style: TextStyle(color: Colors.black),));
              }
            }
          )
        ],
      ),
    )
    );
  }

  
  Widget _showResults(List<CostoFijo> costofijo) {
  
    List<Widget> _data = [];
    for(CostoFijo costo in costofijo) {
      if(costo.id == 11) {
        _precio30a199.text = costo.precio;        
        _data.add(_buildPriceRow(costo.nombre, _precio30a199, costo.id, "costofijo"));
        _data.add(const SizedBox(height: 15));
      }
      if(costo.id == 12) {
        _precio200a299.text = costo.precio;
        _data.add(_buildPriceRow(costo.nombre, _precio200a299, costo.id, "costofijo"));
        _data.add(const SizedBox(height: 15));
      }
      if(costo.id == 13) {
        _precio300a499.text = costo.precio;
        _data.add(_buildPriceRow(costo.nombre, _precio300a499, costo.id, "costofijo"));  
        _data.add(const SizedBox(height: 15));      
      }      
    }
    return Column(
      children: _data,
    );
  }

  Widget _showResultsPlatillo(List<Platillos> platillo) {
    _precioPollo.text = platillo[0].precio;
    _precioPuerco.text = platillo[1].precio;
    _precioItaliano.text = platillo[2].precio;
    _precioMixto.text = platillo[3].precio;
    _precioPremium.text = platillo[4].precio;
    _precioParrillada.text = platillo[5].precio;
    _precioGuisos.text = platillo[6].precio;
    _precioJovenes.text = platillo[7].precio;
    // Promo
    _precioPolloPromo.text = platillo[8].precio;
    _precioPuercoPromo.text = platillo[9].precio;
    _precioItalianoPromo.text = platillo[10].precio;
    _precioMixtoPromo.text = platillo[11].precio;
    _precioPremiumPromo.text = platillo[12].precio;
    _precioParrilladaPromo.text = platillo[13].precio;
    _precioGuisosPromo.text = platillo[14].precio;
    _precioJovenesPromo.text = platillo[15].precio;
    return Column(
      children: [
        // Campos de Platillo
        _buildPriceRow(platillo[0].nombre, _precioPollo, platillo[0].id, "platillo"),
        const SizedBox(height: 15),
        _buildPriceRow(platillo[1].nombre, _precioPuerco, platillo[1].id, "platillo"),
        const SizedBox(height: 15),
        _buildPriceRow(platillo[2].nombre, _precioItaliano, platillo[2].id, "platillo"),
        const SizedBox(height: 15),
        _buildPriceRow(platillo[3].nombre, _precioMixto, platillo[3].id, "platillo"),
        const SizedBox(height: 15),
        _buildPriceRow(platillo[4].nombre, _precioPremium, platillo[4].id, "platillo"),
        const SizedBox(height: 15),
        _buildPriceRow(platillo[5].nombre, _precioParrillada, platillo[5].id, "platillo"),
        const SizedBox(height: 15),
        _buildPriceRow(platillo[6].nombre, _precioGuisos, platillo[6].id, "platillo"),
        const SizedBox(height: 15),
        _buildPriceRow(platillo[7].nombre, _precioJovenes, platillo[7].id, "platillo"),
        const SizedBox(height: 15),
        _buildPriceRow(limpiarEncoding(platillo[8].nombre), _precioPolloPromo, platillo[8].id, "platillo"),
        const SizedBox(height: 15),
        _buildPriceRow(limpiarEncoding(platillo[9].nombre), _precioPuercoPromo, platillo[9].id, "platillo"),
        const SizedBox(height: 15),
        _buildPriceRow(limpiarEncoding(platillo[10].nombre), _precioItalianoPromo, platillo[10].id, "platillo"),
        const SizedBox(height: 15),
        _buildPriceRow(limpiarEncoding(platillo[11].nombre), _precioMixtoPromo, platillo[11].id, "platillo"),
        const SizedBox(height: 15),
        _buildPriceRow(limpiarEncoding(platillo[12].nombre), _precioPremiumPromo, platillo[12].id, "platillo"),
        const SizedBox(height: 15),
        _buildPriceRow(limpiarEncoding(platillo[13].nombre), _precioParrilladaPromo, platillo[13].id, "platillo"),
        const SizedBox(height: 15),
        _buildPriceRow(limpiarEncoding(platillo[14].nombre), _precioGuisosPromo, platillo[14].id, "platillo"),
        const SizedBox(height: 15),
        _buildPriceRow(limpiarEncoding(platillo[15].nombre), _precioJovenesPromo, platillo[15].id, "platillo"),
      ],
    );
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
  
  // Widget para construir una fila de precio
  Widget _buildPriceRow(String label, TextEditingController controller, int id, String tipo) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF566573),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,                
              ],
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
       const SizedBox(width: 15,),
        GestureDetector(
          child: const Icon(Icons.check_circle, color: Colors.green,),
          onTap: (){
            if(tipo == "costofijo") {
              _costofijoService.editCostoFijo(id, controller.text).then((value) {
                if(value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.green,
                      content: Text('Costo Fijo guardado'),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    )
                  );
                }
              });
            } else {
              _platillosService.editPlatillo(id, controller.text).then((value) {
                if(value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.green,
                      content: Text('Platillo guardado'),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    )
                  );
                }
              });
            }
          },
        )
      ],
    );
  }

  void _register() async {
    final user = {
      "nombre" : _name.text,
      "correo" : _email.text,
      "telefono" : _phone.text,
      "password" : _pwd.text
    };
    final res = await http.post(
      _url,
      headers: headers,
      body: jsonEncode(user)
    );
    if(res.statusCode == 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Correo ya registrado'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        )
      );
    } else {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = jsonDecode(res.body);
      prefs.setInt('id', response['id']);
      prefs.setString('email', response['correo']);
      prefs.setString('nombre', response['nombre']);
      prefs.setString('telefono', response['telefono']);
      prefs.setString('monedero', response['monedero']);
      prefs.setBool('destacado', response['destacado']);
      prefs.setBool('prime', response['prime']);
      prefs.setBool('premiere', response['premiere']);
      prefs.setString('pago', "Efectivo");
      prefs.setString('card', "");
      prefs.setBool('habilitar_tarjeta', response['habilitar_tarjeta']);
      prefs.setString('customer_conekta', response['customer_conekta'] ?? "");
      prefs.setBool('active', true);
      _name.clear();
      _email.clear();
      _phone.clear();
      _pwd.clear();
      Navigator.pushNamed(context, 'select');
    }
  }
}