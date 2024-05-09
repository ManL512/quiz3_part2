import 'package:flutter/material.dart';

class ArticlesPage extends StatelessWidget {
  final List<dynamic> articles;

  ArticlesPage({required this.articles});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Artículos'),
      ),
      body: ListView.builder(
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          return ListTile(
            title: Text(article['articulo']),
            subtitle: Text(article['descripcion']),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetails(
                    articulo: article['articulo'],
                    calificaciones: article['calificaciones'],
                    valoracion: article['valoracion'],
                    precio: article['precio'],
                    descuento: article['descuento'],
                    descripcion: article['descripcion'],
                    urlimagen: article['urlimagen'],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ProductDetails extends StatelessWidget {
  final String articulo;
  final String calificaciones;
  final String valoracion;
  final String precio;
  final String descuento;
  final String descripcion;
  final String urlimagen;

  const ProductDetails({
    Key? key,
    required this.articulo,
    required this.calificaciones,
    required this.valoracion,
    required this.precio,
    required this.descuento,
    required this.descripcion,
    required this.urlimagen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Producto'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.network(
                  urlimagen,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                articulo,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'DESCUENTO: $descuento %',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'PRECIO: $precio',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'VALORACIÓN: $valoracion',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'CALIFICACIONES: $calificaciones',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                descripcion,
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Regresar'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
