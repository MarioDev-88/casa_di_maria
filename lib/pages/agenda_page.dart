import 'package:cotizador_casa_di_maria/models/Agenda.dart';
import 'package:cotizador_casa_di_maria/services/cotizacion_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({ Key? key }) : super(key: key);

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {

  DateTime selectedDate = DateTime.now();
  DateTime selectedDateTo = DateTime.now();
  CotizacionService _cotizacionService = CotizacionService();
  Future? _cotizacionFuture;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2036),
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

  Future<void> _selectDateTo(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateTo,
      firstDate: DateTime(2025),
      lastDate: DateTime(2036),
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
    if (picked != null && picked != selectedDateTo) {
      setState(() {
        selectedDateTo = picked;
        _cotizacionFuture = _cotizacionService.getAgenda(selectedDate.toString().split(" ")[0], selectedDateTo.toString().split(" ")[0]);
      });
    }
  }

  String _formatDateTime(DateTime date) {
    final DateFormat formatter = DateFormat('d \'de\' MMMM \'del\' y', 'es_ES');
    return formatter.format(date);
  }

  @override
  void initState() {
    super.initState();
    _cotizacionFuture = _cotizacionService.getAgenda("", "");
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
                  'AGENDA',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFDAA520), // Color mostazas
                  ),
                ),
                const SizedBox(height: 10),
                 Row(
                  children: [
                    // Widget de fecha con icono
                    Expanded(
                      child: _buildDateTimeSelector(
                        icon: Icons.calendar_today,
                        title: _formatDateTime(selectedDate),
                        onTap: () => _selectDate(context),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text("AL"),
                    // Widget de hora de fin con icono
                    Expanded(
                      child: _buildDateTimeSelector(
                        icon: Icons.calendar_today,
                        title: _formatDateTime(selectedDateTo), // Día siguiente
                        onTap: () => _selectDateTo(context) , // La fecha final no se edita, siempre es un día después
                      ),
                    )
                  ],
                ), 
                const SizedBox(height: 10),
                FutureBuilder(future: _cotizacionFuture,
                   builder: (_, AsyncSnapshot snap) {
                    if(snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snap.hasError) {
                      return Center(child: Text('Error: ${snap.error}'));
                    } else if(snap.hasData && !snap.data.isEmpty) {
                      return _showResults(snap.data);
                    } else {
                      return const Center(child: Text("Sin Información", style: TextStyle(color: Colors.black),));
                    }
                   }),
              ]
            ),
         )
         ),       
    );
  }

  Widget _showResults(List<Agenda> cotizacion) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: cotizacion.length,
      itemBuilder: (_, i) {
        final _cotizacion = cotizacion[i];
        return SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            children: [
              Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width/2,
                    child: Text(_cotizacion.fecha_evento!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF253D5B)), textAlign: TextAlign.left,)),
                  SizedBox(
                    width: MediaQuery.of(context).size.width/2,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(_cotizacion.hora_inicio!, style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 16, color: const Color(0xFF253D5B)), textAlign: TextAlign.left,),
                        const SizedBox(width: 10,),
                        const Text("-"),
                        const SizedBox(width: 10,),
                        Text(_cotizacion.hora_fin!, style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 16, color: const Color(0xFF253D5B)),),
                      ],
                    ),
                  ),                  
                ],
              ),
              Text(
                (_cotizacion.contrato.toString() == "false") ?
                "Pendiente" :
                "Con contrato",
                style: TextStyle(
                  color: (_cotizacion.contrato.toString() == "false") ? Colors.red : Colors.green
                ),
              )
            ],
          ),
        );
      }

    );

  }

  String _stringToDate(String date)  {
    DateFormat formato1 = DateFormat("yyyy-MM-dd");
    DateTime fechaConvertida1 = formato1.parse(date);
    return fechaConvertida1.toString();
  }

  Widget _buildDateTimeSelector({
    required IconData icon,
    required String title,
    required VoidCallback onTap
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}