import 'package:flutter/material.dart';

class WorkInProgressScreen extends StatelessWidget {
  const WorkInProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Work in Progress'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Work in Progress',
              style: TextStyle(fontSize: 24.0),
            ),
            SizedBox(height: 20.0),
            Icon(
              Icons.build, // Icono de herramientas
              size: 48.0, // Tamaño del icono
            ),
          ],
        ),
      ),
    );
  }
}
