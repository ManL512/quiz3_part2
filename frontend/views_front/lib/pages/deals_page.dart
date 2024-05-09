import 'package:flutter/material.dart';
import 'package:views_front/pages/articles_page.dart';

class DealsPage extends StatelessWidget {
  final List<dynamic> articles;

  DealsPage({required this.articles});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ofertas'),
      ),
      body: ListView.builder(
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          return ListTile(
            title: Text(article['articulo']),
            subtitle: Text(article['descripcion']),
            onTap: () {
              // Aquí puedes implementar la navegación a la página de detalles del producto si lo deseas
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
