import 'package:admin_app/theme/app_theme.dart';
import 'package:admin_app/viewmodels/dashboard_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: RefreshIndicator(
            onRefresh: vm.refresh,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                const _DashboardAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _DashboardHeader(),
                        const SizedBox(height: 16),
                        _DashboardContent(vm: vm),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// AppBar igual de “normalito” que en MenuEditor, pero con el mismo azul
class _DashboardAppBar extends StatelessWidget {
  const _DashboardAppBar();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      toolbarHeight: 56,
      titleSpacing: 16,
      title: const Text(
        'Panel de control',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      centerTitle: false,
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Hola, cocina 👋',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Resumen rápido de hoy',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final DashboardViewModel vm;

  const _DashboardContent({required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (vm.error != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Text(
          vm.error!,
          style: const TextStyle(
            color: AppColors.danger,
          ),
        ),
      );
    }

    return Column(
      children: [
        _TodayRevenueCard(
          revenue: vm.todayRevenue,
          orders: vm.todayOrdersCount,
        ),
        const SizedBox(height: 16),
        _StatusRow(
          pending: vm.pendingCount,
          inPreparation: vm.inPreparationCount,
          ready: vm.readyCount,
        ),
      ],
    );
  }
}

class _TodayRevenueCard extends StatelessWidget {
  final double revenue;
  final int orders;

  const _TodayRevenueCard({
    required this.revenue,
    required this.orders,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(24),
      shadowColor: Colors.black.withOpacity(0.08),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.1),
              ),
              child: const Icon(
                Icons.insights_rounded,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ventas de hoy',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${revenue.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$orders pedido(s) hoy',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final int pending;
  final int inPreparation;
  final int ready;

  const _StatusRow({
    required this.pending,
    required this.inPreparation,
    required this.ready,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatusCard(
            label: 'Pendientes',
            value: pending,
            color: Colors.amber,
            icon: Icons.schedule_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatusCard(
            label: 'En preparación',
            value: inPreparation,
            color: Colors.orange,
            icon: Icons.local_fire_department_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatusCard(
            label: 'Listos',
            value: ready,
            color: Colors.green,
            icon: Icons.check_circle_rounded,
          ),
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;

  const _StatusCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(20),
      shadowColor: Colors.black.withOpacity(0.05),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: color,
                  ),
                ),
                const Spacer(),
                Text(
                  '$value',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}