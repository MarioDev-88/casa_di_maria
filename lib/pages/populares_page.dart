import 'package:flutter/material.dart';
import 'package:elotes_make/system/arguments.dart';
import 'package:elotes_make/system/platillos_arguments.dart';
import 'package:elotes_make/models/Platillos.dart';
import 'package:elotes_make/services/platillos_service.dart';
import 'package:intl/intl.dart';

class PopularesPage extends StatelessWidget {
  const PopularesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as AppArguments;
    final PlatillosService _platillosService = PlatillosService();
    String _servicio = args.servicio;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Populares'),
      ),
      backgroundColor: Colors.yellow,
      body: FutureBuilder(
        future: _platillosService.getPlatilloPopulares(),
        builder: (context, AsyncSnapshot snapshot) {
          if(snapshot.hasData) {
            return _showResults(snapshot.data, _servicio);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      )
    );
  }

  Widget _showResults(List<Platillos> platillos, String servicio) {
    final numberFormat = NumberFormat.currency(locale: 'es_MX', symbol:"\$");
    return ListView.builder(
      itemCount: platillos.length,
      itemBuilder: (context, index) {
        final platillo = platillos[index];
        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, 'platillo', arguments: PlatillosArguments(idCategoria: platillo.id, nombre: platillo.nombre, servicio: servicio, precio:(servicio == 'Servicio a domicilio') ? platillo.precio : platillo.precio_normal, adiciones: [])),
          child: SizedBox(
            width: double.infinity,
            height: 200,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                FadeInImage.assetNetwork(
                  width: double.infinity,
                  height: 200,
                  imageErrorBuilder: (context, error, stackTrace) {
                    return Image.asset('assets/nuevos-04.png', fit: BoxFit.cover,);
                  },
                  fit: BoxFit.cover,
                  placeholder: "assets/nuevos-04.png", image: platillo.foto_platillo
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    width: double.infinity,
                    color: Colors.black.withOpacity(0.3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [                        
                        Text(
                          platillo.nombre,
                          style: const TextStyle(
                            fontSize: 20.0,
                            color: Colors.white,
                            fontWeight: FontWeight.w700
                          ),
                        ),
                        const SizedBox(height: 4,),
                        SizedBox(
                          width: 150,
                          child: Text(
                            platillo.descripcion,     
                            maxLines: 2,                     
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.white,    
                              fontWeight: FontWeight.w700                        
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 20,
                  bottom: 35,
                  child: Text(
                    (servicio == "Servicio a domicilio") ? 
                      numberFormat.format(double.parse(platillo.precio))
                      : numberFormat.format(double.parse(platillo.precio_normal)),
                    style: const TextStyle(
                      fontSize: 17.0,
                      color: Colors.white,    
                      fontWeight: FontWeight.w700                        
                    ),
                  ),
                )
              ],
            ),
          )
        );
      },
    );
  }
}