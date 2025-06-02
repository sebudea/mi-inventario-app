import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mi_inventario/features/inventory/domain/inventory.dart';
import 'package:mi_inventario/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:mi_inventario/features/auth/presentation/providers/auth_provider.dart';
import 'package:mi_inventario/features/auth/domain/user_model.dart';

class InventoryListScreen extends ConsumerWidget {
  const InventoryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final inventoriesAsync = user != null
        ? ref.watch(userInventoriesProvider(user.id))
        : const AsyncValue<List<Inventory>>.data([]);

    return Scaffold(
      appBar: _buildAppBar(context, ref),
      body: inventoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _ErrorView(error: error),
        data: (inventories) => _InventoryListView(
          inventories: inventories,
          user: user,
        ),
      ),
      floatingActionButton: user != null
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateInventoryDialog(context, ref, user),
              icon: const Icon(Icons.add),
              label: const Text('Nuevo Inventario'),
              tooltip: 'Crear nuevo inventario',
            )
          : null,
    );
  }

  AppBar _buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: const Text('Mi Inventario'),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline),
          tooltip: 'Ayuda',
          onPressed: () => _showHelp(context),
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Cerrar sesión',
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Cerrar Sesión'),
                content:
                    const Text('¿Estás seguro de que deseas cerrar sesión?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      ref.read(authProvider.notifier).signOut();
                    },
                    child: const Text('Cerrar Sesión'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ayuda'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• Toca el botón "+" para crear un nuevo inventario'),
              SizedBox(height: 8),
              Text('• Toca un inventario para ver y editar sus items'),
              SizedBox(height: 8),
              Text('• Desliza un inventario hacia los lados para eliminarlo'),
              SizedBox(height: 8),
              Text('• Los cambios se guardan automáticamente'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateInventoryDialog(
    BuildContext context,
    WidgetRef ref,
    UserModel user,
  ) async {
    final TextEditingController controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo Inventario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Nombre del inventario',
                hintText: 'Ej: Cocina, Garage, Oficina...',
                prefixIcon: Icon(Icons.inventory_2),
              ),
              textCapitalization: TextCapitalization.words,
              autofocus: true,
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  Navigator.of(context).pop(value);
                }
              },
            ),
            const SizedBox(height: 16),
            Text(
              'El nombre debe ser descriptivo y único.',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.of(context).pop(name);
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await ref.read(inventoryNotifierProvider.notifier).createInventory(
            name: result,
            user: user,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Inventario "$result" creado'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

class _ErrorView extends ConsumerWidget {
  final Object error;

  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            SelectableText.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Error: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  TextSpan(text: error.toString()),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                // Invalidar providers para forzar actualización
                ref.invalidate(authProvider);
                ref.invalidate(userInventoriesProvider);
                // Redirigir a la pantalla principal
                context.go('/');
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InventoryListView extends StatelessWidget {
  final List<Inventory> inventories;
  final dynamic user;

  const _InventoryListView({
    required this.inventories,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    if (inventories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No tienes inventarios aún',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Toca el botón "+" para crear uno nuevo',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: inventories.length,
      itemBuilder: (context, index) {
        final inventory = inventories[index];
        return _InventoryCard(inventory: inventory);
      },
    );
  }
}

class _InventoryCard extends ConsumerWidget {
  final Inventory inventory;

  const _InventoryCard({required this.inventory});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(inventory.id),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) => _confirmDelete(context),
      onDismissed: (_) {
        ref
            .read(inventoryNotifierProvider.notifier)
            .deleteInventory(inventory.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Inventario "${inventory.name}" eliminado'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      background: Container(
        color: Theme.of(context).colorScheme.error,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Icon(Icons.delete, color: Theme.of(context).colorScheme.onError),
      ),
      secondaryBackground: Container(
        color: Theme.of(context).colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Icon(Icons.delete, color: Theme.of(context).colorScheme.onError),
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        elevation: 2,
        child: ListTile(
          leading: Icon(
            Icons.inventory_2,
            color: Theme.of(context).colorScheme.primary,
            size: 32,
          ),
          title: Text(
            inventory.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            '${inventory.items.length} items',
            style: TextStyle(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            context.push(
              '/inventory/${Uri.encodeComponent(inventory.name)}',
              extra: inventory,
            );
          },
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Inventario'),
        content: Text(
          '¿Estás seguro de que deseas eliminar el inventario "${inventory.name}"?\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
