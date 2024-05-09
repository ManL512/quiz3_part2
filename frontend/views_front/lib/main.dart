//main.dart - pagina 1
import 'package:flutter/material.dart';
import 'package:views_front/pages/registration_page.dart';

void main() {
  runApp(MaterialApp(
    title: 'QUIZ 3',
    initialRoute: '/', 
    routes: {
      '/': (context) => RegistrationPage(), 
    },
  ));
}
