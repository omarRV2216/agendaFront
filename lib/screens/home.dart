import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schedulefront/screens/dashboard/dashboard.dart';
import 'package:schedulefront/screens/login.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: const DashboardScreen(),
    );
  }
}