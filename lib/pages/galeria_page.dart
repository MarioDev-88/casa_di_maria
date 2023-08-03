import 'package:flutter/material.dart';
import 'package:elotes_make/system/arguments.dart';
import 'package:elotes_make/system/platillos_arguments.dart';
import 'package:elotes_make/models/Platillos.dart';
import 'package:elotes_make/services/platillos_service.dart';

class GaleriaPage extends StatelessWidget {
  const GaleriaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as AppArguments;
    final PlatillosService _platillosService = PlatillosService();
    String _servicio = args.servicio;
    return Scaffold(
      appBar: AppBar(title: const Text('Galería')),
      backgroundColor: Colors.yellow,
      body: SafeArea(
        child: FutureBuilder(
          future: _platillosService.getPlatilloGaleria(),
          builder: (context, AsyncSnapshot snapshot) {
            if(snapshot.hasData) {
              return _showResults(snapshot.data, _servicio);
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

  Widget _showResults(List<Platillos> platillos, String servicio) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 5, mainAxisSpacing: 5), 
      itemCount: platillos.length,
      itemBuilder: (context, index) {
        final platillo = platillos[index];
        return RawMaterialButton(
          onPressed: () => Navigator.pushNamed(context, 'platillo', arguments: PlatillosArguments(idCategoria: platillo.id, nombre: platillo.nombre, servicio: servicio, precio:(servicio == 'Servicio a domicilio') ? platillo.precio : platillo.precio_normal, adiciones: [])),
          child: Container(
            width: 170,
            height: 170,
            child: FadeInImage(
              fadeInCurve: Curves.fastEaseInToSlowEaseOut,
              fadeInDuration: const Duration(milliseconds: 1500),
              placeholder: const AssetImage("assets/nuevos-04.png"), 
              image: NetworkImage(platillo.foto_platillo),
              fit: BoxFit.cover,
              imageErrorBuilder: (context, error, stackTrace) {
                return Image.asset("assets/nuevos-04.png", fit: BoxFit.cover, width: 120, height: 120,);
              },            
            ),
          )
        );
      }
    );
  }
}