import 'dart:convert';
import 'dart:html';

import 'package:flutter/material.dart';

class BasicDataVisualization extends StatelessWidget {
  final String data;
  final Map json;

  BasicDataVisualization.isJSON({super.key, required this.data})
      : json = jsonDecode(data); // Decodifica el JSON

  BasicDataVisualization({super.key, required this.data}) : json = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Retrieved'),
      ),
      body: SingleChildScrollView(
          scrollDirection: Axis.vertical, child: Text(data)),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Save data',
        onPressed: () {
          String jsonBase64 = base64Encode(utf8.encode(data));

          int numUsers = 0;

          if (json.isNotEmpty) {
            numUsers = json['users'].length;
          }

          // Crea un enlace para descargar el archivo
          AnchorElement(
            href: 'data:application/json;charset=utf-8;base64,$jsonBase64',
          )
            ..setAttribute('download', 'group_of_$numUsers.json')
            ..click();
        },
        child: const Icon(Icons.save_alt_rounded),
      ),
    );
  }
}
