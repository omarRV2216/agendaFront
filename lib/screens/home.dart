import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schedulefront/screens/dashboard/dashboard.dart';
import 'package:schedulefront/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          // 👇 BOTÓN TEMPORAL PARA DEBUG
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final token = prefs.getString('token');
              print('=== TOKEN EN PREFERENCIAS ===');
              print(token ?? 'null');
              print('=== TOKEN EN MEMORIA ===');
              print(ApiService().token ?? 'null');
            },
          ),
        ],
      ),
      body: const DashboardScreen(),
    );
  }
}