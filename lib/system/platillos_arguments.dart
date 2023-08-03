class PlatillosArguments {
  final int idCategoria;
  final String nombre;
  final String servicio;
  final String precio;
  final bool edit;
  final int cantidad;
  final int index;
  final List adiciones;

  const PlatillosArguments({
    required this.idCategoria,
    required this.nombre,
    required this.servicio,
    this.precio = "",
    this.edit = false,
    this.cantidad = 1,
    this.index = 0,
    required this.adiciones
  });
}