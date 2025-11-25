import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_logic/models/order.dart';
import 'package:shared_logic/models/product.dart';

import '../theme/app_theme.dart';
import '../viewmodels/order_tracking_view_model.dart';
import 'package:shared_logic/services/i_order_repository.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OrderTrackingViewModel(
        context.read<IOrderRepository>(),
        orderId: orderId,
      ),
      child: Consumer<OrderTrackingViewModel>(
        builder: (context, vm, _) {
          final order = vm.currentOrder;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.primary,
              elevation: 0,
              centerTitle: false,
              iconTheme: const IconThemeData(color: Colors.white),
              title: const Text(
                'Detalle del pedido',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            body: vm.isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : vm.error != null
                    ? Center(child: Text(vm.error!))
                    : order == null
                        ? const Center(
                            child: Text('No encontramos tu pedido'),
                          )
                        : _OrderTrackingContent(order: order),
          );
        },
      ),
    );
  }
}

class _OrderTrackingContent extends StatelessWidget {
  final Order order;

  const _OrderTrackingContent({required this.order});

  int _statusIndex(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 1;
      case OrderStatus.inPreparation:
        return 2;
      case OrderStatus.ready:
        return 3;
      case OrderStatus.delivered:
        return 3;
    }
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '-';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dt.day)}/${two(dt.month)}/${dt.year} ${two(dt.hour)}:${two(dt.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final itemsList = order.items.entries.toList();
    final totalItems =
        order.items.values.fold<int>(0, (sum, qty) => sum + qty);
    final currentStep = _statusIndex(order.status);
    final note = (order.note ?? '').trim();

    return Column(
      children: [
        // TOP AZUL + TARJETA BLANCA
        Container(
          width: double.infinity,
          color: AppColors.primary,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título "Pedido ABC123" + fecha
              Row(
                children: [
                  Text(
                    'Pedido ${order.id.substring(0, 6).toUpperCase()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDateTime(order.createdAt),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Card resúmen
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Primera fila: código chip + nombre + total
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF3FF),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '#${order.id.substring(0, 6).toUpperCase()}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if ((order.clientName ?? '').isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4F4F7),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Cliente: ${order.clientName}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        const Spacer(),
                        Text(
                          '\$${order.totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$totalItems artículo(s) en este pedido',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Chips de productos
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: itemsList.map((entry) {
                        final product = entry.key as Product;
                        final qty = entry.value;
                        final line =
                            '\u00D7$qty ${product.name} \$${product.price.toStringAsFixed(0)}';
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F4F7),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            line,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // CUERPO BLANCO: TIMELINE + NOTA
        Expanded(
          child: Container(
            width: double.infinity,
            color: AppColors.background,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Estatus de tu pedido',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Te mostramos el avance de tu pedido en tiempo real.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Timeline
                  _TimelineStep(
                    title: 'Pedido creado',
                    description:
                        'Hemos recibido tu pedido y estamos preparando todo para empezar.',
                    isActive: currentStep >= 0,
                    isFirst: true,
                  ),
                  _TimelineStep(
                    title: 'Pendiente',
                    description:
                        'Tu pedido está en cola. Nuestro equipo está revisando los detalles.',
                    isActive: currentStep >= 1,
                  ),
                  _TimelineStep(
                    title: 'En preparación',
                    description:
                        'Estamos preparando tu orden con cuidado para que salga perfecta.',
                    isActive: currentStep >= 2,
                  ),
                  _TimelineStep(
                    title: 'Listo',
                    description:
                        'Tu pedido está listo para ser entregado o recogido.',
                    isActive: currentStep >= 3,
                    isLast: true,
                  ),

                  const SizedBox(height: 16),
                  // Estado actual
                  Row(
                    children: [
                      const Text(
                        'Estado actual: ',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        _statusLabel(order.status),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  // Nota del cliente (opcional)
                  if (note.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Nota que enviaste a la cocina',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        note,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _statusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pendiente';
      case OrderStatus.inPreparation:
        return 'En preparación';
      case OrderStatus.ready:
        return 'Listo';
      case OrderStatus.delivered:
        return 'Entregado';
    }
  }
}

class _TimelineStep extends StatelessWidget {
  final String title;
  final String description;
  final bool isActive;
  final bool isFirst;
  final bool isLast;

  const _TimelineStep({
    required this.title,
    required this.description,
    required this.isActive,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : Colors.grey.shade400;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Línea + círculo
        Column(
          children: [
            if (!isFirst)
              Container(
                width: 2,
                height: 18,
                color: Colors.grey.shade300,
              ),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? AppColors.primary : Colors.white,
                border: Border.all(color: color, width: 2),
              ),
              child: isActive
                  ? const Icon(
                      Icons.check,
                      size: 10,
                      color: Colors.white,
                    )
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 12),
        // Texto
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              top: isFirst ? 0 : 4,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }
}