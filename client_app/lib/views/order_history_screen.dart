import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:shared_logic/models/order.dart';
import 'package:shared_logic/services/i_order_repository.dart';

import '../theme/app_theme.dart';
import '../viewmodels/order_history_view_model.dart';
import 'order_tracking_screen.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartVM = Provider.of<OrdersHistoryClientIdProvider?>(context,
        listen: false);

    final clientId = cartVM?.clientId ?? 'guest';

    return ChangeNotifierProvider(
      create: (_) => OrderHistoryViewModel(
        context.read<IOrderRepository>(),
        clientId: clientId,
      ),
      child: Consumer<OrderHistoryViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              title: const Text(
                'Historial de pedidos',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: false,
            ),
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Header “Hola de nuevo”
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 16, right: 16, top: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              'Tus pedidos',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Revisa el historial y dale tap para ver el estado.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Contenedor blanco con las tarjetas
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(28),
                          ),
                        ),
                        child: _HistoryBody(vm: vm),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Provider opcional para compartir clientId
class OrdersHistoryClientIdProvider {
  final String clientId;
  OrdersHistoryClientIdProvider(this.clientId);
}

class _HistoryBody extends StatelessWidget {
  final OrderHistoryViewModel vm;

  const _HistoryBody({required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.error != null) {
      return Center(child: Text(vm.error!));
    }

    if (vm.orders.isEmpty) {
      return RefreshIndicator(
        onRefresh: vm.refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            SizedBox(height: 40),
            Center(
              child: Text(
                'Todavía no tienes pedidos.\nHaz tu primer pedido desde el menú 👀',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: vm.refresh,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        itemCount: vm.orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final order = vm.orders[index];
          return _HistoryTile(
            order: order,
            onTap: () {
              debugPrint('TAP historial: ${order.id}');
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => OrderTrackingScreen(orderId: order.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap;

  const _HistoryTile({
    required this.order,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final note = (order.note ?? '').trim();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Primera fila: código + fecha + flecha
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '#${order.id.substring(0, 6)}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const Spacer(),
                if (order.createdAt != null)
                  Text(
                    _formatDateTime(order.createdAt!),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Estado
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(order.status).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _statusLabel(order.status),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _statusColor(order.status),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '\$${order.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Nota (si hay)
            if (note.isNotEmpty) ...[
              const Text(
                'Nota:',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                note,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
            ],

            // Hint de tap
            Row(
              children: const [
                Icon(
                  Icons.remove_red_eye_outlined,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 4),
                Text(
                  'Toca para ver el estado en tiempo real',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.amber;
      case OrderStatus.inPreparation:
        return Colors.orange;
      case OrderStatus.ready:
        return Colors.green;
      case OrderStatus.delivered:
        return Colors.blueGrey;
    }
  }

  String _formatDateTime(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dt.day)}/${two(dt.month)}/${dt.year} '
        '${two(dt.hour)}:${two(dt.minute)}';
  }
}