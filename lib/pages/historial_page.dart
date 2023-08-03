import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:elotes_make/services/historial_service.dart';

class HistorialPage extends StatelessWidget {
  const HistorialPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    HistorialService _historialService = HistorialService();    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: _historialService.getHistorial(),
          builder: (context, AsyncSnapshot snapshot) {
            if(snapshot.hasData) {
              return _showResult(snapshot.data);
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

  _showResult(List data) {
    final numberFormat = NumberFormat.currency(locale: 'es_MX', symbol:"\$");
    List<TableRow> _rows = [];
    for(var i=0; i < data.length; i++) {
      _rows.add(
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '${data[i]['restaurante']} ${data[i]['fecha']}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '${data[i]['folio']}',
                style: TextStyle(
                  fontWeight: FontWeight.w400
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '${numberFormat.format(double.parse(data[i]['total']))}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: (data[i]['status'] == 6) ? 
                Icon(Icons.close_rounded, color: Colors.red,) : 
                Icon(Icons.check_circle, color: Colors.green,),
            )
          ]
        )
      );
    }
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50.0),
                  child: Container(
                    color: Colors.grey.shade300,                    
                    width: 50.0,
                    height: 50.0,
                    child: Image.asset("assets/zp-ico-27.png", scale: 1.5, width: 5, height: 5,),
                  ),
                ),
              ),
              const Text(
                'Historial de pedidos',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 15.0,),
        Table(children: _rows, border: TableBorder.all(width: 0.1, color: Colors.white10),)
      ],
    );
  }
}