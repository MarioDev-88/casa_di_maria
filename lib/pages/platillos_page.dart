import 'package:flutter/material.dart';
import 'package:elotes_make/models/Platillos.dart';
import 'package:elotes_make/services/platillos_service.dart';
import 'package:elotes_make/system/platillos_arguments.dart';
import 'package:intl/intl.dart';

import '../presentation/carrito.dart';

class PlatillosPage extends StatefulWidget {
  const PlatillosPage({Key? key}) : super(key: key);

  @override
  State<PlatillosPage> createState() => _PlatillosPageState();
}

class _PlatillosPageState extends State<PlatillosPage> {
  final carrito = Carrito();
  @override
  Widget build(BuildContext context) {   
    final args = ModalRoute.of(context)!.settings.arguments as PlatillosArguments;
    final int _idCat = args.idCategoria;
    final PlatillosService _platillosService = PlatillosService();
    return Scaffold(
      appBar: AppBar(
        title: Text(args.nombre)
      ),
      backgroundColor: Colors.yellow,
      floatingActionButton: carrito.showFloatingButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: carrito.showBottomBar(),
      body: SafeArea(
        child: FutureBuilder(
          future: _platillosService.getPlatillos(_idCat),
          builder: (context, AsyncSnapshot snap) {
            if(snap.hasData) {
              return _showResults(snap.data, context, args.servicio);
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _showResults(List<Platillos> platillos, BuildContext context, String servicio) {
    return ListView.builder(
      itemCount: platillos.length,
      itemBuilder: (_, i) {
        final platillo = platillos[i];
        final numberFormat = NumberFormat.currency(locale: 'es_MX', symbol:"\$");
        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, 'platillo', arguments: PlatillosArguments(idCategoria: platillo.id, nombre: platillo.nombre, servicio: servicio, precio:(servicio == 'Servicio a domicilio') ? platillo.precio : platillo.precio_normal, adiciones: [])),
          child: Container(
            padding: const EdgeInsets.all(5.0),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black, width: 0.1)),
              color: Colors.white
            ),
            child: Row(
              children: [
                _crearImage(platillo.imagekit),
                Column(              
                  crossAxisAlignment: CrossAxisAlignment.start,               
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: SizedBox(
                        width: 150,
                        child: Text(
                          platillo.nombre, 
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 19.0
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 185,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(platillo.descripcion),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      (servicio == "Servicio a domicilio") ? numberFormat.format(double.parse(platillo.precio))
                      : numberFormat.format(double.parse(platillo.precio_normal)),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16.0
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

  Widget _crearImage(String image) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5.0),
      child: FadeInImage(
        height: 80,
        width: 80,
        fit: BoxFit.cover,
        placeholderFit: BoxFit.cover,
        placeholder: const AssetImage("assets/logo.png"), 
        image:NetworkImage(image),
        imageErrorBuilder: (context, error, stackTrace) {
          return Image.asset('assets/logo.png', width: 80, height: 80, fit: BoxFit.cover,);
        },
      ),
    );
  }
}