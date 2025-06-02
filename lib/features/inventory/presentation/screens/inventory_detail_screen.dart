import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_inventario/features/inventory/domain/inventory.dart';
import 'package:mi_inventario/features/inventory/domain/item.dart';
import 'package:mi_inventario/features/inventory/presentation/providers/inventory_provider.dart';
import 'package:mi_inventario/features/auth/presentation/providers/auth_provider.dart';
import 'package:uuid/uuid.dart';

class InventoryDetailScreen extends ConsumerStatefulWidget {
  final Inventory inventory;

  const InventoryDetailScreen({
    super.key,
    required this.inventory,
  });

  @override
  ConsumerState<InventoryDetailScreen> createState() =>
      _InventoryDetailScreenState();
}

class _InventoryDetailScreenState extends ConsumerState<InventoryDetailScreen> {
  late ScrollController _verticalScrollController;
  int? editingRow;
  final Map<String, FocusNode> _focusNodes = {};

  @override
  void initState() {
    super.initState();
    _verticalScrollController = ScrollController();
  }

  @override
  void dispose() {
    _verticalScrollController.dispose();
    for (var node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inventoriesAsync = ref.watch(inventoryNotifierProvider);

    return Scaffold(
      appBar: _buildAppBar(),
      body: inventoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _ErrorView(error: error),
        data: (inventories) {
          final inventory = _getCurrentInventory(inventories);
          if (inventory == null) {
            return const Center(
              child: Text('Inventario no encontrado'),
            );
          }
          return _InventoryDetailView(
            inventory: inventory,
            verticalScrollController: _verticalScrollController,
            editingRow: editingRow,
            focusNodes: _focusNodes,
            onEditingRowChanged: (index) => setState(() => editingRow = index),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text("Inventario ${widget.inventory.name}"),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline),
          onPressed: () => _showHelp(context),
        ),
      ],
    );
  }

  Inventory? _getCurrentInventory(List<Inventory> inventories) {
    try {
      return inventories.firstWhere((inv) => inv.id == widget.inventory.id);
    } catch (e) {
      return null;
    }
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
              Text('• Haz clic en cualquier celda para editar su contenido'),
              SizedBox(height: 8),
              Text('• Usa el botón "+" para agregar nuevos atributos'),
              SizedBox(height: 8),
              Text('• Selecciona una fila y usa el botón rojo para eliminarla'),
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
}

class _ErrorView extends StatelessWidget {
  final Object error;

  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            SelectableText.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Error: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: error.toString()),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InventoryDetailView extends ConsumerWidget {
  final Inventory inventory;
  final ScrollController verticalScrollController;
  final int? editingRow;
  final Map<String, FocusNode> focusNodes;
  final ValueChanged<int?> onEditingRowChanged;

  const _InventoryDetailView({
    required this.inventory,
    required this.verticalScrollController,
    required this.editingRow,
    required this.focusNodes,
    required this.onEditingRowChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = List<Item>.from(inventory.items);
    final columns = _getAllColumns(items, inventory.extraAttributes);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (items.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  'No hay items en este inventario',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
          else
            Expanded(
              child: _buildDataTable(context, ref, items, columns),
            ),
          const SizedBox(height: 16),
          _buildBottomActions(context, ref),
        ],
      ),
    );
  }

  Widget _buildDataTable(
    BuildContext context,
    WidgetRef ref,
    List<Item> items,
    List<String> columns,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        controller: verticalScrollController,
        scrollDirection: Axis.vertical,
        child: DataTable(
          columns: _buildColumns(context, ref, columns),
          rows: _buildRows(items, columns, ref),
        ),
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Agregar Item'),
          onPressed: () => _addRow(ref),
        ),
        if (editingRow != null)
          ElevatedButton.icon(
            icon: const Icon(Icons.delete),
            label: const Text('Eliminar Item'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => _deleteCurrentRow(context, ref),
          ),
      ],
    );
  }

  List<String> _getAllColumns(List<Item> items, List<String> extraAttributes) {
    final Set<String> columns = {"name", "quantity"};
    columns.addAll(extraAttributes);
    for (final item in items) {
      columns.addAll(item.extraAttributes.keys);
    }
    return columns.toList();
  }

  List<DataColumn> _buildColumns(
      BuildContext context, WidgetRef ref, List<String> columns) {
    final cols = columns.map((col) {
      final isExtra = inventory.extraAttributes.contains(col);
      return DataColumn(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              col[0].toUpperCase() + col.substring(1),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (isExtra)
              Padding(
                padding: const EdgeInsets.only(left: 2),
                child: IconButton(
                  icon: const Icon(Icons.delete,
                      size: 18, color: Colors.redAccent),
                  tooltip: 'Eliminar atributo',
                  onPressed: () => _removeAttribute(ref, col),
                ),
              ),
          ],
        ),
      );
    }).toList();

    cols.add(
      DataColumn(
        label: IconButton(
          icon: const Icon(Icons.add),
          tooltip: 'Agregar atributo',
          onPressed: () => _showAddAttributeDialog(ref, context),
        ),
      ),
    );

    return cols;
  }

  List<DataRow> _buildRows(
      List<Item> items, List<String> columns, WidgetRef ref) {
    return List<DataRow>.generate(
      items.length,
      (rowIndex) => DataRow(
        selected: editingRow == rowIndex,
        onSelectChanged: (selected) {
          onEditingRowChanged(selected == true ? rowIndex : null);
        },
        cells: [
          ...columns.map((col) {
            String initialValue;
            final item = items[rowIndex];
            if (col == "name") {
              initialValue = item.name;
            } else if (col == "quantity") {
              initialValue = item.quantity.toString();
            } else {
              initialValue = item.extraAttributes[col]?.toString() ?? '';
            }
            return DataCell(
              ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 40,
                  maxWidth: 120,
                ),
                child: Focus(
                  focusNode: focusNodes['$rowIndex-$col'] ??= FocusNode(),
                  child: TextFormField(
                    initialValue: initialValue,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: col == "name" ? "Nombre" : "Valor",
                    ),
                    keyboardType: col == "quantity"
                        ? TextInputType.number
                        : TextInputType.text,
                    onChanged: (value) => _updateCell(ref, col, value, item),
                  ),
                ),
              ),
            );
          }).toList(),
          DataCell(Container()),
        ],
      ),
    );
  }

  void _updateCell(WidgetRef ref, String column, String value, Item item) {
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

    final items = List<Item>.from(inventory.items);
    final index = items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      items[index] = updatedItem;
      ref
          .read(inventoryNotifierProvider.notifier)
          .updateItems(inventory.id, items);
    }
  }

  void _addRow(WidgetRef ref) {
    final newItem = Item(
      id: const Uuid().v4(),
      name: '',
      quantity: 0,
      extraAttributes: {},
    );

    ref.read(inventoryNotifierProvider.notifier).addItemToInventory(
          inventory.id,
          newItem,
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (verticalScrollController.hasClients) {
        verticalScrollController.animateTo(
          verticalScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _deleteCurrentRow(BuildContext context, WidgetRef ref) {
    if (editingRow != null) {
      final items = List<Item>.from(inventory.items);
      items.removeAt(editingRow!);
      ref
          .read(inventoryNotifierProvider.notifier)
          .updateItems(inventory.id, items);
      onEditingRowChanged(null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item eliminado'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _removeAttribute(WidgetRef ref, String attribute) {
    ref.read(inventoryNotifierProvider.notifier).removeExtraAttribute(
          inventory.id,
          attribute,
        );
  }

  Future<void> _showAddAttributeDialog(
      WidgetRef ref, BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo atributo'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nombre del atributo',
            hintText: 'Ej: color, tamaño, marca...',
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
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
      ref.read(inventoryNotifierProvider.notifier).addExtraAttribute(
            inventory.id,
            result,
          );
    }
  }
}
