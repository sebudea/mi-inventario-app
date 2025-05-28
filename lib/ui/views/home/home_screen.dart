import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mi_inventario/ui/viewmodels/inventory_viewmodel.dart';
import 'package:mi_inventario/ui/viewmodels/user_viewmodel.dart';
import 'package:provider/provider.dart';

import '../../../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final inventoryViewModel =
        Provider.of<InventoryViewModel>(context, listen: false);
    final userViewModel = Provider.of<UserViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi inventario'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await authService.signOut();
              userViewModel.clearUser();
            },
          ),
        ],
      ),
      body: Center(
        child: userViewModel.loading
            ? const CircularProgressIndicator()
            : Column(
                children: [
                  Text(
                    'Mis Inventarios',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Consumer<InventoryViewModel>(
                      builder: (context, inventoryViewModel, _) {
                        final inventories = inventoryViewModel.inventories;
                        if (inventories.isEmpty) {
                          return const Text('No tienes inventarios aún.');
                        }
                        return ListView.builder(
                          itemCount: inventories.length,
                          itemBuilder: (context, index) {
                            final inventory = inventories[index];
                            return Card(
                              clipBehavior: Clip.antiAlias,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              elevation: 2,
                              child: ListTile(
                                leading: const Icon(Icons.inventory_2,
                                    color: Colors.deepPurple),
                                title: Text(
                                  inventory.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text('ID: ${inventory.id}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.redAccent),
                                  onPressed: () {
                                    // Confirmación antes de eliminar el inventario
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title:
                                            const Text('Eliminar Inventario'),
                                        content: Text(
                                            '¿Estás seguro de que deseas eliminar el inventario "${inventory.name}"?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: const Text('Cancelar'),
                                          ),
                                          FilledButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              // Aquí puedes agregar lógica para eliminar el inventario
                                              inventoryViewModel
                                                  .removeInventory(
                                                      context, inventory.id);
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Inventario "${inventory.name}" eliminado.'),
                                                ),
                                              );
                                            },
                                            child: const Text('Eliminar'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                onTap: () {
                                  // Aquí puedes navegar a los detalles del inventario
                                  context.push(
                                    '/inventory/${Uri.encodeComponent(inventory.name)}',
                                    extra: inventory,
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final TextEditingController controller = TextEditingController();

          final result = await showDialog<String>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Nuevo Inventario'),
              content: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Nombre del inventario',
                ),
                autofocus: true,
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
            // Aquí puedes agregar la lógica para crear el inventario con el nombre ingresado
            inventoryViewModel.addInventory(
                context, result, userViewModel.userId);
            debugPrint('Nuevo inventario creado: $result');
          }
        },
        child: const Icon(Icons.add),
        tooltip: 'Agregar inventario',
      ),
    );
  }
}
