import 'package:admin_app/theme/app_theme.dart';
import 'package:admin_app/viewmodels/menu_editor_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_logic/models/product.dart';

class MenuEditorScreen extends StatelessWidget {
  const MenuEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MenuEditorViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Editor de menú'),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _openProductSheet(context),
            child: const Icon(Icons.add),
          ),
          backgroundColor: AppColors.background,
          body: vm.isLoading
              ? const Center(child: CircularProgressIndicator())
              : vm.error != null
                  ? Center(child: Text(vm.error!))
                  : RefreshIndicator(
                      onRefresh: vm.refresh,
                      child: vm.products.isEmpty
                          ? const Center(
                              child: Text(
                                'No hay productos en el menú.',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 16, 16, 80),
                              itemCount: vm.products.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (_, index) {
                                final product = vm.products[index];
                                return _ProductTile(
                                  product: product,
                                  onEdit: () =>
                                      _openProductSheet(context, product),
                                  onDelete: () =>
                                      _confirmDelete(context, product),
                                );
                              },
                            ),
                    ),
        );
      },
    );
  }

  void _openProductSheet(BuildContext context, [Product? product]) {
    final vm = context.read<MenuEditorViewModel>();

    final nameCtrl = TextEditingController(text: product?.name ?? '');
    final descCtrl =
        TextEditingController(text: product?.description ?? '');
    final priceCtrl = TextEditingController(
        text: product != null ? product.price.toString() : '');
    final categoryCtrl =
        TextEditingController(text: product?.category ?? '');
    final imageCtrl =
        TextEditingController(text: product?.imageUrl ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                top: 12,
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          product == null
                              ? 'Nuevo producto'
                              : 'Editar producto',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: priceCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Precio',
                        prefixText: '\$ ',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: categoryCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Categoría',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: imageCtrl,
                      decoration: const InputDecoration(
                        labelText: 'URL de imagen (opcional)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () async {
                          final name = nameCtrl.text.trim();
                          final priceText = priceCtrl.text.trim();

                          if (name.isEmpty || priceText.isEmpty) return;

                          final price =
                              double.tryParse(priceText.replaceAll(',', '.')) ??
                                  0;

                          final newProduct = Product(
                            id: product?.id ?? '',
                            name: name,
                            description: descCtrl.text.trim(),
                            price: price,
                            category: categoryCtrl.text.trim(),
                            imageUrl: imageCtrl.text.trim(),
                          );

                          if (product == null) {
                            await vm.addProduct(newProduct);
                          } else {
                            await vm.updateProduct(
                              newProduct.copyWith(id: product.id),
                            );
                          }

                          if (context.mounted) Navigator.pop(context);
                        },
                        child: Text(product == null ? 'Crear' : 'Guardar'),
                      ),
                    ),
                    if (product != null) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.danger,
                            side: const BorderSide(color: AppColors.danger),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          onPressed: () async {
                            await vm.deleteProduct(product);
                            if (context.mounted) Navigator.pop(context);
                          },
                          child: const Text('Eliminar producto'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, Product product) async {
    final vm = context.read<MenuEditorViewModel>();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text('¿Seguro que quieres eliminar "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );

    if (ok == true) {
      await vm.deleteProduct(product);
    }
  }
}

class _ProductTile extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductTile({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onEdit,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.primary.withOpacity(0.06),
                ),
                child: product.imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.fastfood_rounded,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.fastfood_rounded,
                        color: AppColors.primary,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (product.description.isNotEmpty)
                      Text(
                        product.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    const SizedBox(height: 4),
                    if (product.category.isNotEmpty)
                      Text(
                        product.category,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit_rounded,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: onEdit,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: AppColors.danger,
                        ),
                        onPressed: onDelete,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}