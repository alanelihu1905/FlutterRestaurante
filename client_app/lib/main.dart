import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'theme/app_theme.dart';

import 'viewmodels/menu_view_model.dart';
import 'viewmodels/cart_view_model.dart';

import 'views/client_name_screen.dart';

import 'package:shared_logic/services/i_order_repository.dart';
import 'package:shared_logic/services/firestore_order_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final repository = FirestoreOrderRepository(FirebaseFirestore.instance);

  runApp(ClientApp(repository: repository));
}

class ClientApp extends StatelessWidget {
  final IOrderRepository repository;

  const ClientApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Repo compartido
        Provider<IOrderRepository>.value(value: repository),

        // Carrito (inicialmente invitado, luego lo actualizas desde ClientNameScreen)
        ChangeNotifierProvider(
          create: (_) => CartViewModel(
            repository,
            clientId: 'guest',
            clientName: 'Invitado',
          ),
        ),

        // Menú
        ChangeNotifierProvider(
          create: (_) => MenuViewModel(repository),
        ),
      ],
      child: MaterialApp(
        title: 'Cliente Restaurante',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(), // 👈 AQUÍ ya es función, no referencia
        home: const ClientNameScreen(),
      ),
    );
  }
}