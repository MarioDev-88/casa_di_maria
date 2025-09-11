import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cotizador_casa_di_maria/system/add_card_arguments.dart';
import 'package:cotizador_casa_di_maria/services/card_service.dart';
import 'package:cotizador_casa_di_maria/services/certificado_service.dart';
import 'package:cotizador_casa_di_maria/system/globals.dart';
import 'package:cotizador_casa_di_maria/system/pago_vale_arguments.dart';
import 'package:cotizador_casa_di_maria/themes/custom.dart';

import '../models/Cards.dart';


class PagoValePage extends StatefulWidget {
  const PagoValePage({Key? key}) : super(key: key);

  @override
  State<PagoValePage> createState() => _PagoValePageState();
}

class _PagoValePageState extends State<PagoValePage> {
  
  final numberFormat = NumberFormat.currency(locale: 'es_MX', symbol:"\$");
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final CertificadoService _certificadoService = CertificadoService();
  final CardService _cardService = CardService();
  final String _reglas = '''Pasos para hacer válido el cupón después de generar la compra : 
      1.- Le mandaremos correo y WhatsApp a quien va cobrar su vale para informarle
      2.- Para cobrarlo, el regalado mandara  WhatsApp previamente a visita al 6623156835
      3.- Mostrará su ine en establecimiento 

      Y Listo, a disfrutar

      Nota: 
      - Uso del 100% en 1 sola exhibición 
      - No hay reembolso en efectivo
      - Para cambiar nombre de quien va cobrar vale,  mandar WhatsApp a 6623156835 

      A) El que compró vale
      o
      B) Al que le regalaron el vale

      Compartirá datos del nuevo afortunado y listo
          * Aplican restricciones *
      ''';
  final TextEditingController _nombreVale = TextEditingController();
  final TextEditingController _telefonoVale = TextEditingController();
  final TextEditingController _correoVale = TextEditingController();
  final TextEditingController _mensajeVale = TextEditingController();
  bool? isLinkChecked = true;
  bool? isTarjetaChecked = false;
  bool isLoading = false;
  String _idTarjeta = '';
  String _cuatroDigitos = '';
  String _tipoTarjeta = ''; 

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(seconds: 1) , () {
      _initStatePago(); 
    });
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as PagoValeArguments;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comprar vale de consumo'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _showAlert, 
            child: const Text('¿Como funciona?'),
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(Colors.white),
              backgroundColor: MaterialStateProperty.all(Colors.transparent),
            ),
          )
        ],
      ),
      body: _crearForm(args),
    );
  }
  
  Widget _crearForm(PagoValeArguments arguments) {
    return SafeArea(
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
               Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: TextFormField(
                  autocorrect: false,
                  controller: _nombreVale,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0)
                      ),
                      label: const Text('Vale a nombre de')
                    ),
                    validator: (String? value) {
                      if(value == null || value.isEmpty) {
                        return 'Ingrese su nombre';
                      }
                      return null;
                    },
                  ),
               ),
            Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: TextFormField(
                  autocorrect: false,
                    controller: _telefonoVale,
                    maxLength: 10,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0)
                      ),
                      label: const Text('Teléfono / WhatsApp')
                    ),
                    validator: (String? value) {
                      if(value == null || value.isEmpty) {
                        return 'Ingrese el teléfono';
                      }
                      return null;
                    },
                  ),
               ),
            Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: TextFormField(
                  autocorrect: false,
                  controller: _correoVale,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0)
                      ),
                      label: const Text('Correo electrónico')
                    ),
                    validator: (String? value) {
                      if(value == null || value.isEmpty) {
                        return 'Ingrese el correo electrónico';
                      }
                      return null;
                    },
                  ),
               ),
            Padding(  
                 padding: const EdgeInsets.all(8.0),
                 child: TextFormField(
                  autocorrect: false,
                  controller: _mensajeVale,
                  maxLines: 3,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0)
                      ),
                      label: const Text('Mensaje')
                    ),
                  ),
               ),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '1 x ${arguments.titulo}',
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Sucursal: $appName',
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            Column(
                children: [
                  CheckboxListTile(
                    activeColor: customTheme.primary,
                    value: isLinkChecked, 
                    onChanged: (value) async {
                      final SharedPreferences prefs = await SharedPreferences.getInstance();
                      setState(() {
                        prefs.setString("pago", "Terminal a domicilio");
                        prefs.setString("card", '');
                        isLinkChecked = value;
                        isTarjetaChecked = false;
                      });
                    },
                    title: const Text('Link de pago'),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  CheckboxListTile(
                    activeColor: customTheme.primary,
                    value: isTarjetaChecked, 
                    onChanged: (value) {
                      setState(() {
                        isTarjetaChecked = value;
                        isLinkChecked = false;
                      });
                      _checkTarjeta();
                    },
                    title: const Text('Tarjeta débito / crédito'),
                    subtitle: Text('$_tipoTarjeta $_cuatroDigitos'),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Subtotal ${numberFormat.format(double.parse(arguments.costo))}',
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w700
                        ),
                      ),
                    ),
                  )
                ],
              ),         
            SizedBox(
              height: 50,
              child: FilledButton(
                onPressed: (){
                  if (_formKey.currentState!.validate()) {
                    _enviarForm();
                  }
                }, 
                child: isLoading ? const CircularProgressIndicator(color: Colors.white,) : 
                  const Text(
                    'Realizar compra',
                    style: TextStyle(
                      fontWeight: FontWeight.w700
                    ),
                  )
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _showAlert() async {
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: const Center(
          child: Text(
            'Vales de consumo',
            style: TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.w600
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              child: Text(
                _reglas,
                textAlign: TextAlign.left,
              ),
            ),
            FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cerrar'))
          ],
        ),
      );
    });
  }

  _initStatePago() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("pago", "Terminal a domicilio");
    prefs.setString("card", '');
    List<Cards> _cards = await _cardService.getUsuarioTarjeta();    
    setState(() {
      try {
        _idTarjeta = _cards[0].idTarjeta;
        _cuatroDigitos = _cards[0].cuatroDigitos;
        _tipoTarjeta = _cards[0].tipoTarjeta;
        prefs.setString("card", _idTarjeta);
      } catch (e) {
        _idTarjeta = '';
        _cuatroDigitos = '';
        _tipoTarjeta = '';
      }
    });
    print(_idTarjeta);
  }
  
  Future<void> _enviarForm() async {    
    setState(() {
      isLoading = true;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final args = ModalRoute.of(context)!.settings.arguments as PagoValeArguments;
    final params = {
      'nombre_para' : _nombreVale.text,
      'telefono_para' : _telefonoVale.text,
      'correo_para' : _correoVale.text,
      'vale_id': args.id,
      'usuario': prefs.getInt('id'),
      'mensaje': _mensajeVale.text,
      'tipo_pago': prefs.getString("pago")
    };
    _certificadoService.pagoCertificado(params).then((value) => {
      if(value['status'] == 200) {
        showDialog(context: context, barrierDismissible: false, builder: (context) {          
          return AlertDialog(            
            title: Text(appName),
            content: const Text('Vale de consumo comprado'),
            actions: [
              TextButton(
                onPressed: (){
                  setState(() {
                  isLoading = false;
                });
                  Navigator.of(context).pop();
                  Navigator.pop(context, ['pago_vale']);
                }, 
                child: const Text('Regresar a la pantalla principal')
              )
            ],
          );
        })
      } else {
        setState(() {
          isLoading = false;
        }),
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('${value['data']['message']}'),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          )
        )
      }
    });
  }
  
  void _checkTarjeta() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if(_idTarjeta == '') {
      showDialog(context: context, builder: (context) {
        return AlertDialog(
          title: const Text('Aviso'),
          content: const Text('No se encontró ninguna tarjeta, ¿Desea agregar una?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
            TextButton(onPressed: _openAddCard, child: const Text('Agregar tarjeta'))
          ],
        );
      });
    } else {
      setState(() {                      
        prefs.setString("pago", "Tarjeta");
        prefs.setString("card", _idTarjeta);      
      });
    }    
  }

  void _openAddCard() {
    Navigator.pushNamed(
      context, 
      'add_card',
      arguments: AddCardArguments(_idTarjeta)
    ).then((value) => _initStatePago);
  }
}