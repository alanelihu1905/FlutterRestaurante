import 'package:admin_app/theme/app_theme.dart';
import 'package:admin_app/viewmodels/orders_history_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_logic/models/order.dart' as app;
import 'package:shared_logic/models/product.dart';

class OrdersHistoryScreen extends StatelessWidget {
  const OrdersHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrdersHistoryViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Historial de pedidos'),
          ),
          backgroundColor: AppColors.background,
          body: RefreshIndicator(
            onRefresh: vm.refresh,
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.error != null
                    ? Center(child: Text(vm.error!))
                    : vm.orders.isEmpty
                        ? const Center(
                            child: Text(
                              'Todavía no hay pedidos.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                            itemCount: vm.orders.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (_, i) {
                              final order = vm.orders[i];
                              return _OrderHistoryCard(order: order);
                            },
                          ),
          ),
        );
      },
    );
  }
}

class _OrderHistoryCard extends StatelessWidget {
  final app.Order order;

  const _OrderHistoryCard({required this.order});

  Color _statusColor(app.OrderStatus status) {
    switch (status) {
      case app.OrderStatus.pending:
        return Colors.amber;
      case app.OrderStatus.inPreparation:
        return Colors.orange;
      case app.OrderStatus.ready:
      case app.OrderStatus.delivered:
        return Colors.green;
    }
  }

  String _statusLabel(app.OrderStatus status) {
    switch (status) {
      case app.OrderStatus.pending:
        return 'Pendiente';
      case app.OrderStatus.inPreparation:
        return 'En preparación';
      case app.OrderStatus.ready:
      case app.OrderStatus.delivered:
        return 'Listo';
    }
  }

  @override
  Widget build(BuildContext context) {
    final created = order.createdAt;
    final dateString = created != null
        ? '${created.day.toString().padLeft(2, '0')}/${created.month.toString().padLeft(2, '0')} ${created.hour.toString().padLeft(2, '0')}:${created.minute.toString().padLeft(2, '0')}'
        : '--';

    double total = 0;
    order.items.forEach((Product product, int qty) {
      total += product.price * qty;
    });

    final statusColor = _statusColor(order.status);

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(18),
      shadowColor: Colors.black.withOpacity(0.05),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header
            Row(
              children: [
                Text(
                  '#${order.id.substring(0, 6).toUpperCase()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _statusLabel(order.status),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  dateString,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (order.clientName != null && order.clientName!.isNotEmpty)
              Text(
                'Cliente: ${order.clientName}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            const SizedBox(height: 8),
            // items
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: order.items.entries.map((entry) {
                final product = entry.key as Product;
                final qty = entry.value as int;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    children: [
                      Text(
                        '${qty}× ${product.name}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '\$${(qty * product.price).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            // total
            Row(
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            if (order.note != null && order.note!.isNotEmpty) ...[
              const SizedBox(height: 6),
              const Text(
                'Nota:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                order.note!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}