import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_logic/models/order.dart';

import '../theme/app_theme.dart';
import '../viewmodels/kitchen_view_model.dart';

class KitchenScreen extends StatefulWidget {
  const KitchenScreen({super.key});

  @override
  State<KitchenScreen> createState() => _KitchenScreenState();
}

class _KitchenScreenState extends State<KitchenScreen> {
  OrderStatus _selectedStatus = OrderStatus.pending;

  @override
  Widget build(BuildContext context) {
    return Consumer<KitchenViewModel>(
      builder: (context, vm, _) {
        final allOrders = vm.orders;

        final pendingCount =
            allOrders.where((o) => o.status == OrderStatus.pending).length;
        final prepCount = allOrders
            .where((o) => o.status == OrderStatus.inPreparation)
            .length;
        final readyCount =
            allOrders.where((o) => o.status == OrderStatus.ready).length;

        final filteredOrders =
            allOrders.where((o) => o.status == _selectedStatus).toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            elevation: 0,
            title: const Text(
              'Órdenes de cocina',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          body: Column(
            children: [
              const SizedBox(height: 8),
              _StatusTabs(
                selected: _selectedStatus,
                pendingCount: pendingCount,
                prepCount: prepCount,
                readyCount: readyCount,
                onChanged: (status) {
                  setState(() => _selectedStatus = status);
                },
              ),
              const SizedBox(height: 8),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: vm.refresh,
                  child: vm.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : vm.error != null
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  'Error al cargar órdenes: ${vm.error}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.danger,
                                  ),
                                ),
                              ),
                            )
                          : filteredOrders.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No hay órdenes para este estado.',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.fromLTRB(
                                      16, 8, 16, 32),
                                  itemCount: filteredOrders.length,
                                  itemBuilder: (context, index) {
                                    final order = filteredOrders[index];
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: _OrderCard(
                                        order: order,
                                        onTake: () => vm.updateOrderStatus(
                                          order,
                                          OrderStatus.inPreparation,
                                        ),
                                        onMarkReady: () =>
                                            vm.updateOrderStatus(
                                          order,
                                          OrderStatus.ready,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatusTabs extends StatelessWidget {
  final OrderStatus selected;
  final int pendingCount;
  final int prepCount;
  final int readyCount;
  final ValueChanged<OrderStatus> onChanged;

  const _StatusTabs({
    required this.selected,
    required this.pendingCount,
    required this.prepCount,
    required this.readyCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: _StatusTabChip(
              label: 'Pendientes ($pendingCount)',
              selected: selected == OrderStatus.pending,
              onTap: () => onChanged(OrderStatus.pending),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatusTabChip(
              label: 'En preparación ($prepCount)',
              selected: selected == OrderStatus.inPreparation,
              onTap: () => onChanged(OrderStatus.inPreparation),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatusTabChip(
              label: 'Listos ($readyCount)',
              selected: selected == OrderStatus.ready,
              onTap: () => onChanged(OrderStatus.ready),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusTabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _StatusTabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white : const Color(0xFFEEF2FF),
          borderRadius: BorderRadius.circular(999),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTake;
  final VoidCallback onMarkReady;

  const _OrderCard({
    required this.order,
    required this.onTake,
    required this.onMarkReady,
  });

  @override
  Widget build(BuildContext context) {
    final note = (order.note ?? '').trim();

    return Material(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.06),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // estado + código
            Row(
              children: [
                _StatusPill(status: order.status),
                const Spacer(),
                Text(
                  '#${order.id.substring(0, 6)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // cliente + tipo
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  order.clientName?.isNotEmpty == true
                      ? order.clientName!
                      : 'Sin nombre',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4FF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Servicio',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // 🔹 Detalle de lo que pidieron (DESGLOSE)
            const Text(
              'Detalle del pedido',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            ...order.items.entries.map((entry) {
              final product = entry.key;
              final qty = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Text(
                      '${qty}x',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 8),

            // total + hora
            Row(
              children: [
                Text(
                  '\$${order.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatTime(order.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            if (note.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Nota: $note',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 12),

            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    // Listo -> sin botones
    if (order.status == OrderStatus.ready) {
      return const SizedBox.shrink();
    }

    // En preparación -> solo "Marcar listo"
    if (order.status == OrderStatus.inPreparation) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: onMarkReady,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: const Text(
            'Marcar listo',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    // Pendiente
    return Row(
      children: [
        Expanded(
          child: FilledButton(
            onPressed: onTake,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              'Tomar pedido',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: onMarkReady,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              'Marcar listo',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '--:--';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dt.hour)}:${two(dt.minute)}';
  }
}

class _StatusPill extends StatelessWidget {
  final OrderStatus status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case OrderStatus.pending:
        bg = const Color(0xFFFFF7E6);
        fg = const Color(0xFF92400E);
        label = 'Pendiente';
        break;
      case OrderStatus.inPreparation:
        bg = const Color(0xFFFFF4E5);
        fg = const Color(0xFFB45309);
        label = 'En preparación';
        break;
      case OrderStatus.ready:
        bg = const Color(0xFFE6F9EC);
        fg = const Color(0xFF15803D);
        label = 'Listo';
        break;
      case OrderStatus.delivered:
        bg = const Color(0xFFE5E7EB);
        fg = const Color(0xFF4B5563);
        label = 'Entregado';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}