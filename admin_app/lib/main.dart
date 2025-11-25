import 'package:admin_app/theme/app_theme.dart';
import 'package:admin_app/viewmodels/dashboard_view_model.dart';
import 'package:admin_app/viewmodels/kitchen_view_model.dart';
import 'package:admin_app/viewmodels/menu_editor_view_model.dart';
import 'package:admin_app/viewmodels/orders_history_view_model.dart';
import 'package:admin_app/views/dashboard_screen.dart';
import 'package:admin_app/firebase_options.dart';
import 'package:admin_app/views/kitchen_screen.dart';
import 'package:admin_app/views/menu_editor_screen.dart';
import 'package:admin_app/views/orders_history_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_logic/services/firestore_order_repository.dart';
import 'package:shared_logic/services/i_order_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;
  final repository = FirestoreOrderRepository(firestore);

  runApp(
    MultiProvider(
      providers: [
        Provider<IOrderRepository>.value(value: repository),
        ChangeNotifierProvider(
          create: (_) => KitchenViewModel(repository),
        ),
        ChangeNotifierProvider(
          create: (_) => MenuEditorViewModel(repository),
        ),
        ChangeNotifierProvider(
          // 👇 solo le pasamos el db por nombre
          create: (_) => DashboardViewModel(db: firestore),
        ),
        ChangeNotifierProvider(
          create: (_) => OrdersHistoryViewModel(db: firestore),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Restaurante',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const _AdminRoot(),
    );
  }
}

class _AdminRoot extends StatefulWidget {
  const _AdminRoot();

  @override
  State<_AdminRoot> createState() => _AdminRootState();
}

class _AdminRootState extends State<_AdminRoot> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const DashboardScreen(),
      const KitchenScreen(),
      const MenuEditorScreen(),
      const OrdersHistoryScreen(),
    ];

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Panel',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Cocina',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_outlined),
            selectedIcon: Icon(Icons.edit),
            label: 'Menú',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            selectedIcon: Icon(Icons.history_rounded),
            label: 'Historial',
          ),
        ],
      ),
    );
  }
}