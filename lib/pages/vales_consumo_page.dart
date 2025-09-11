import 'package:flutter/material.dart';
import 'package:cotizador_casa_di_maria/system/pago_vale_arguments.dart';
import 'package:cotizador_casa_di_maria/models/Certificados.dart';
import 'package:cotizador_casa_di_maria/services/certificado_service.dart';
import 'package:intl/intl.dart';

class ValesConsumoPage extends StatefulWidget {
  const ValesConsumoPage({Key? key}) : super(key: key);

  @override
  State<ValesConsumoPage> createState() => _ValesConsumoPageState();
}

class _ValesConsumoPageState extends State<ValesConsumoPage> {  
  final numberFormat = NumberFormat.currency(locale: 'es_MX', symbol:"\$");
  final certificadoService = CertificadoService();
  final String _reglas = '''Pasos para hacer válido el cupón después de generar la compra : 
      1.- Le mandaremos correo  y WhatsApp a quien va cobrar su vale para informarle
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {  
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vales de consumo'),
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
      body: FutureBuilder(
        future: certificadoService.getCertificados(),
        builder: (_, AsyncSnapshot snap) {
          if(snap.hasData) {
            return _showResults(snap.data);
          } else {
            return const Center(child: CircularProgressIndicator(semanticsLabel: 'Obteniendo certificados',));
          }
        },
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
  
  Widget _showResults(List<Certificados> certificado) {
    return ListView.builder(
      itemCount: certificado.length,
      itemBuilder: (_, index) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: Colors.black,
                width: 0.5
              )
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      certificado[index].titulo,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 26.0
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                      'Costo: ${numberFormat.format(double.parse(certificado[index].costo))}',
                      textAlign: TextAlign.left,
                      style: const TextStyle(                      
                        fontSize: 20.0
                      ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                      certificado[index].descripcion,
                      textAlign: TextAlign.left,
                      style: const TextStyle(                      
                        fontSize: 20.0
                      ),
                  ),
                ),
                SizedBox(
                  height: 70,
                  width: 170,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FilledButton(
                      onPressed: (){
                        Navigator.pushNamed(context, 
                          'pago_vale',
                          arguments: PagoValeArguments(
                            certificado[index].titulo, 
                            certificado[index].costo,
                            certificado[index].id
                          )
                        );
                      },
                      child: const Text(
                        'Comprar',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}