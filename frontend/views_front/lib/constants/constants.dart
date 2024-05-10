import 'package:flutter/material.dart';

class AppStyles {
  // Colores
  static const Color greenButtonColor = Color(0xFFC8FFE0); 
  static const Color strokeColor = Color(0xFF1679AB); 
  static const Color labelBackgroundColor = Color(0xFFC5FFF8); 
  static const Color labelTextColor = Color(0xFF074173); 
  static const Color gradientStartColor = Color(0xFFA1E6FF); 
  static const Color gradientEndColor = Color.fromARGB(255, 203, 203, 203); 

  // Estilos de botón
  static ButtonStyle greenButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: Colors.black, backgroundColor: greenButtonColor,
    side: BorderSide(
      color: strokeColor,
      width: 2.0,
      style: BorderStyle.solid,
    ),
  );

  // Estilos de texto de etiqueta
  static TextStyle labelTextStyle = TextStyle(
    color: labelTextColor,
  );
}
