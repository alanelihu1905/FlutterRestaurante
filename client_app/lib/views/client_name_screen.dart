import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../viewmodels/cart_view_model.dart';
import 'menu_screen.dart';

class ClientNameScreen extends StatefulWidget {
  const ClientNameScreen({super.key});

  @override
  State<ClientNameScreen> createState() => _ClientNameScreenState();
}

class _ClientNameScreenState extends State<ClientNameScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _touched = false;

  void _continue() {
    setState(() => _touched = true);
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    context.read<CartViewModel>().updateClientName(name);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MenuScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nameError = _touched && _nameController.text.trim().isEmpty;

    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      // importante para que se mueva con el teclado
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  24,
                  24,
                  24,
                  24 + viewInsets, // deja espacio para el teclado
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 48,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ICONO
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF60A5FA),
                              Color(0xFF1D4ED8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.18),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.restaurant_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Bienvenido 👋',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Antes de empezar, dime tu nombre para personalizar tu experiencia.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFE5E7EB),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // TARJETA BLANCA
                      Material(
                        elevation: 10,
                        shadowColor: Colors.black.withOpacity(0.20),
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '¿Cómo te llamas?',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _nameController,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _continue(),
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(
                                    Icons.person_outline_rounded,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                  hintText: 'Ej. Alan',
                                  filled: true,
                                  fillColor: const Color(0xFFF9FAFB),
                                  contentPadding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE5E7EB),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE5E7EB),
                                    ),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(14),
                                    ),
                                    borderSide: BorderSide(
                                      color: AppColors.primary,
                                      width: 1.6,
                                    ),
                                  ),
                                  errorText: nameError
                                      ? 'Por favor escribe tu nombre'
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(999),
                                    ),
                                  ),
                                  onPressed: _continue,
                                  child: const Text(
                                    'Empezar a ordenar',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Podrás cambiar tu nombre más adelante desde el menú.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFBFDBFE),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}