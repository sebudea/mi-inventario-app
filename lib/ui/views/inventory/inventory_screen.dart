import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/inventory/inventory.dart';
import '../../../domain/item/item.dart';
import '../../viewmodels/inventory_viewmodel.dart';

class InventoryScreen extends StatefulWidget {
  final Inventory inventory;

  const InventoryScreen({
    super.key,
    required this.inventory,
  });

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late ScrollController _verticalScrollController;

  // Obtiene todas las columnas dinámicamente
  List<String> getAllColumns(List<Item> items, List<String> extraAttributes) {
    final Set<String> columns = {"name", "quantity"};
    columns.addAll(extraAttributes);
    for (final item in items) {
      columns.addAll(item.extraAttributes.keys);
    }
    return columns.toList();
  }

  // Actualiza el valor de una celda localmente (puedes adaptar para guardar en el viewmodel si quieres persistencia)
  void updateCell(BuildContext context, int rowIndex, String column,
      String value, Inventory inventory) {
    final inventoryViewModel =
        Provider.of<InventoryViewModel>(context, listen: false);
    final items = List<Item>.from(inventory.items ?? []);
    final item = items[rowIndex];
    Item updatedItem;
    if (column == "name") {
      updatedItem = item.copyWith(name: value);
    } else if (column == "quantity") {
      updatedItem = item.copyWith(quantity: int.tryParse(value) ?? 0);
    } else {
      final updatedExtra = Map<String, dynamic>.from(item.extraAttributes);
      updatedExtra[column] = value;
      updatedItem = item.copyWith(extraAttributes: updatedExtra);
    }
    items[rowIndex] = updatedItem;
    inventoryViewModel.updateItems(inventory.id, items);
  }

  // Agrega una nueva fila vacía usando el viewmodel
  void addRow(BuildContext context, Inventory inventory) {
    final inventoryViewModel =
        Provider.of<InventoryViewModel>(context, listen: false);
    inventoryViewModel.addItemToInventory(
      inventory.id,
      Item(name: '', quantity: 0, extraAttributes: {}),
    );
    // Espera un frame y luego haz scroll al final
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verticalScrollController.animateTo(
        _verticalScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _verticalScrollController = ScrollController();
  }

  @override
  void dispose() {
    _verticalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryViewModel>(
      builder: (context, inventoryViewModel, _) {
        // Obtén el inventario actualizado por id
        final inventory = inventoryViewModel.inventories.firstWhere(
          (inv) => inv.id == widget.inventory.id,
          orElse: () => widget.inventory,
        );
        final items = List<Item>.from(inventory.items ?? []);
        final columns = getAllColumns(items, inventory.extraAttributes);

        return Scaffold(
          appBar: AppBar(
            title: Text("Inventario ${inventory.name}"),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  // <-- Esto permite el scroll vertical
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      controller: _verticalScrollController, // <-- aquí
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        columns: columns
                            .map((col) => DataColumn(
                                label: Text(
                                    col[0].toUpperCase() + col.substring(1))))
                            .toList(),
                        rows: List<DataRow>.generate(
                          items.length,
                          (rowIndex) => DataRow(
                            cells: columns.map((col) {
                              String initialValue;
                              final item = items[rowIndex];
                              if (col == "name") {
                                initialValue = item.name;
                              } else if (col == "quantity") {
                                initialValue = item.quantity.toString();
                              } else {
                                initialValue =
                                    item.extraAttributes[col]?.toString() ?? '';
                              }
                              return DataCell(
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    minWidth: 40,
                                    maxWidth: 80,
                                  ),
                                  child: TextFormField(
                                    initialValue: initialValue,
                                    decoration: const InputDecoration(
                                        border: InputBorder.none),
                                    onChanged: (value) => updateCell(context,
                                        rowIndex, col, value, inventory),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Agregar atributo'),
                      onPressed: () async {
                        final controller = TextEditingController();
                        final result = await showDialog<String>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Nuevo atributo'),
                            content: TextField(
                              controller: controller,
                              decoration: const InputDecoration(
                                labelText: 'Nombre del atributo',
                              ),
                              autofocus: true,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cancelar'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  final value = controller.text.trim();
                                  if (value.isNotEmpty) {
                                    Navigator.of(context).pop(value);
                                  }
                                },
                                child: const Text('Agregar'),
                              ),
                            ],
                          ),
                        );
                        if (result != null && result.isNotEmpty) {
                          Provider.of<InventoryViewModel>(context,
                                  listen: false)
                              .addExtraAttribute(inventory.id, result);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar fila'),
                  onPressed: () => addRow(context, inventory),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
