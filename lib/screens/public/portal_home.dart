import 'package:flutter/material.dart';

import 'appbar/appbar.dart';

class PortalHome extends StatelessWidget {
  const PortalHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PortalAppBar(seccionActual: 'inicio'),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.spa, size: 80, color: Colors.pink.shade200),
            const SizedBox(height: 24),
            const Text(
              'Portal público — próximamente',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}