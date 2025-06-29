import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'services/background_service.dart';
import 'demo_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Populate demo data on first run (comment out after first run if needed)
  await DemoData.populateDemoData();
  await DemoData.createSampleAppointments();
  await DemoData.createSampleNotifications();
  await DemoData.printDatabaseStats();
  
  // Start background services for appointment management
  BackgroundServiceManager.startAllServices();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Healthcare AppointmentModel System',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 2,
        ),
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
