class Categories {
  final int idCategoria;
  final String foto;
  final String nombre;
  final String fotoCat;

  const Categories({
    required this.idCategoria, 
    required this.foto, 
    required this.fotoCat, 
    required this.nombre
  });

  static Categories fromJson(Map json) {
    return Categories(
      idCategoria : json['id_categoria'],
      foto : json['foto'] ?? "",
      nombre : json['nombre'],
      fotoCat : json['foto_cat']
    );
  }
}