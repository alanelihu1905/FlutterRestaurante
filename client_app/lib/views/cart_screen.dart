import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_logic/models/product.dart';
import 'package:shared_logic/models/order.dart';

import '../theme/app_theme.dart';
import '../viewmodels/cart_view_model.dart';
import 'order_summary_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartViewModel>(
      builder: (context, cartVM, _) {
        final items = cartVM.items.entries.toList();

        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            titleSpacing: 16,
            title: const Text(
              'Tu carrito',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
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
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          // Línea pequeña decorativa
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          const SizedBox(height: 12),

                          Expanded(
                            child: items.isEmpty
                                ? const Center(
                                    child: Text(
                                      'Todavía no has agregado productos.\nAgrega algo desde el menú ✨',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      8,
                                      16,
                                      16,
                                    ),
                                    itemCount: items.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 12),
                                    itemBuilder: (_, index) {
                                      final entry = items[index];
                                      final product = entry.key;
                                      final qty = entry.value;
                                      return _CartItemTile(
                                        product: product,
                                        quantity: qty,
                                        onIncrement: () =>
                                            cartVM.increment(product),
                                        onDecrement: () =>
                                            cartVM.decrement(product),
                                      );
                                    },
                                  ),
                          ),

                          if (items.isNotEmpty) ...[
                            const Divider(height: 1),

                            // ================== SERVICE TYPE ==================
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  16, 16, 16, 8),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Cómo vas a recibir tu pedido',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary
                                        .withOpacity(0.9),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              child: Row(
                                children: [
                                  _ServiceChip(
                                    label: ServiceType.pickUp.label,
                                    selected: cartVM.serviceType ==
                                        ServiceType.pickUp,
                                    onTap: () => cartVM
                                        .updateServiceType(
                                            ServiceType.pickUp),
                                  ),
                                  const SizedBox(width: 8),
                                  _ServiceChip(
                                    label: ServiceType.dineIn.label,
                                    selected: cartVM.serviceType ==
                                        ServiceType.dineIn,
                                    onTap: () => cartVM
                                        .updateServiceType(
                                            ServiceType.dineIn),
                                  ),
                                ],
                              ),
                            ),

                            // ================== MÉTODO DE PAGO ==================
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  16, 12, 16, 4),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Método de pago',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary
                                        .withOpacity(0.9),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.25),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color:
                                            const Color(0xFFE5EDFF),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.payments_rounded,
                                        size: 20,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Efectivo',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight:
                                                  FontWeight.w700,
                                              color: AppColors
                                                  .textPrimary,
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'Pagarás en efectivo al entregar o en caja.',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: AppColors
                                                  .textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // ================== NOTA PARA COCINA ==================
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  16, 10, 16, 8),
                              child: TextField(
                                maxLines: 3,
                                minLines: 1,
                                onChanged: cartVM.updateNote,
                                decoration: InputDecoration(
                                  labelText:
                                      'Nota para la cocina (opcional)',
                                  alignLabelWithHint: true,
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ),

                            // ================== BOTTOM BAR ==================
                            _BottomBar(cartVM: cartVM),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final Product product;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _CartItemTile({
    required this.product,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final total = product.price * quantity;

    return Material(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.08),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            // imagen
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                product.imageUrl,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 56,
                  height: 56,
                  color: Colors.grey.shade200,
                  child: const Icon(
                    Icons.fastfood_rounded,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${product.price.toStringAsFixed(2)} c/u',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // botones cantidad
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _QuantityButton(
                  icon: Icons.remove_rounded,
                  onTap: onDecrement,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    quantity.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                _QuantityButton(
                  icon: Icons.add_rounded,
                  onTap: onIncrement,
                ),
              ],
            ),
            const SizedBox(width: 8),
            Text(
              '\$${total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFFE5EDFF),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Icon(
          icon,
          size: 18,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _ServiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ServiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE5EDFF) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : Colors.grey.withOpacity(0.3),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w500,
                color:
                    selected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final CartViewModel cartVM;

  const _BottomBar({required this.cartVM});

  @override
  Widget build(BuildContext context) {
    if (cartVM.totalItems == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Resumen izquierda
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartVM.serviceType.label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${cartVM.totalItems} artículo(s) • \$${cartVM.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Botón confirmar
            SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24),
                ),
                onPressed: cartVM.isCreatingOrder
                    ? null
                    : () async {
                        try {
                          final order = await cartVM.createOrder();
                          if (!context.mounted) return;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OrderSummaryScreen(
                                order: order,
                              ),
                            ),
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Error al crear pedido: $e',
                              ),
                            ),
                          );
                        }
                      },
                child: cartVM.isCreatingOrder
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Confirmar pedido',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}