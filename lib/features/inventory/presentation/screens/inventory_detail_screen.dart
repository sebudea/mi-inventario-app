import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_inventario/features/inventory/domain/inventory.dart';
import 'package:mi_inventario/features/inventory/domain/item.dart';
import 'package:mi_inventario/features/inventory/presentation/providers/inventory_providers.dart';
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
  String? selectedItemId;
  final Map<String, FocusNode> _focusNodes = {};
  List<Item> _localItems = [];
  List<String> _localExtraAttributes = [];
  bool _hasUnsavedChanges = false;

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
    final inventoryAsync =
        ref.watch(selectedInventoryProvider(widget.inventory.id));

    return Scaffold(
      appBar: _buildAppBar(),
      body: inventoryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _ErrorView(error: error),
        data: (inventory) {
          // Inicializar items y atributos locales si es necesario
          if (_localItems.isEmpty) {
            _localItems = List.from(inventory.items);
            _localExtraAttributes = List.from(inventory.extraAttributes);
          }
          return _InventoryDetailView(
            inventory: inventory,
            localItems: _localItems,
            localExtraAttributes: _localExtraAttributes,
            verticalScrollController: _verticalScrollController,
            selectedItemId: selectedItemId,
            focusNodes: _focusNodes,
            onItemSelected: (itemId) => setState(() => selectedItemId = itemId),
            onItemsChanged: (items) {
              setState(() {
                _localItems = items;
                _hasUnsavedChanges = true;
              });
            },
            onAttributesChanged: (attributes) {
              setState(() {
                _localExtraAttributes = attributes;
                _hasUnsavedChanges = true;
              });
            },
          );
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text("Inventario ${widget.inventory.name}"),
      centerTitle: true,
      leading: _hasUnsavedChanges
          ? IconButton(
              icon: const Icon(Icons.save_rounded),
              onPressed: () => _showSaveConfirmationDialog(),
              tooltip: 'Guardar y Volver',
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                foregroundColor:
                    Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            )
          : IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Volver',
            ),
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline),
          onPressed: () => _showHelp(context),
          tooltip: 'Ayuda',
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
              Text('• Haz clic en cualquier celda para editar su contenido'),
              SizedBox(height: 8),
              Text('• Usa el botón "+" para agregar nuevos atributos'),
              SizedBox(height: 8),
              Text('• Selecciona una fila y usa el botón rojo para eliminarla'),
              SizedBox(height: 8),
              Text(
                  '• Los cambios deben guardarse manualmente al salir de la pantalla'),
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

  Future<void> _showSaveConfirmationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Guardar Cambios'),
        content:
            const Text('¿Deseas guardar los cambios y volver al inventario?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.save),
            label: const Text('Guardar'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      await _saveChanges();
      if (!mounted) return;
      Navigator.of(context).pop(); // Volver a la pantalla anterior
    }
  }

  Future<void> _saveChanges() async {
    if (!_hasUnsavedChanges) return;

    try {
      // Creamos una versión actualizada del inventario con todos los cambios locales
      final updatedInventory = widget.inventory.copyWith(
        items: _localItems,
        extraAttributes: _localExtraAttributes,
      );

      await ref
          .read(inventoryNotifierProvider.notifier)
          .updateInventory(updatedInventory);

      setState(() {
        _hasUnsavedChanges = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle,
                  color: Theme.of(context).colorScheme.onPrimary),
              const SizedBox(width: 8),
              Text('Cambios guardados correctamente'),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.primary,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Theme.of(context).colorScheme.onError),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Error al guardar: ${e.toString()}',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onError),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 4),
        ),
      );
    }
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
  final List<Item> localItems;
  final List<String> localExtraAttributes;
  final ScrollController verticalScrollController;
  final String? selectedItemId;
  final Map<String, FocusNode> focusNodes;
  final ValueChanged<String?> onItemSelected;
  final ValueChanged<List<Item>> onItemsChanged;
  final ValueChanged<List<String>> onAttributesChanged;

  const _InventoryDetailView({
    required this.inventory,
    required this.localItems,
    required this.localExtraAttributes,
    required this.verticalScrollController,
    required this.selectedItemId,
    required this.focusNodes,
    required this.onItemSelected,
    required this.onItemsChanged,
    required this.onAttributesChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final columns = _getAllColumns(localItems, localExtraAttributes);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (localItems.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  'No hay items en este inventario, agrega uno para empezar',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            Expanded(
              child: _buildDataTable(context, ref, localItems, columns),
            ),
          const SizedBox(height: 16),
          _buildBottomActions(context, ref, localItems),
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
          columns: _buildColumns(context, columns),
          rows: _buildRows(items, columns, ref),
          showCheckboxColumn: true,
        ),
      ),
    );
  }

  Widget _buildBottomActions(
      BuildContext context, WidgetRef ref, List<Item> items) {
    final selectedItem = selectedItemId != null
        ? items.firstWhere(
            (item) => item.id == selectedItemId,
            orElse: () =>
                Item(id: '', name: '', quantity: null, extraAttributes: {}),
          )
        : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Agregar Item'),
          onPressed: () => _addRow(ref),
        ),
        if (selectedItem != null && selectedItem.id.isNotEmpty)
          ElevatedButton.icon(
            icon: const Icon(Icons.delete),
            label: const Text('Eliminar Item'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => _deleteItem(context, selectedItem),
          ),
      ],
    );
  }

  void _deleteItem(BuildContext context, Item itemToDelete) {
    if (itemToDelete.id.isEmpty) return;

    final updatedItems = List<Item>.from(localItems)
      ..removeWhere((item) => item.id == itemToDelete.id);

    onItemsChanged(updatedItems);
    onItemSelected(null);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item eliminado'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  List<String> _getAllColumns(List<Item> items, List<String> extraAttributes) {
    final Set<String> columns = {"article", "quantity"};
    columns.addAll(extraAttributes);
    for (final item in items) {
      columns.addAll(item.extraAttributes.keys);
    }
    return columns.toList();
  }

  List<DataColumn> _buildColumns(BuildContext context, List<String> columns) {
    final cols = columns.map((col) {
      final isExtra = localExtraAttributes.contains(col);
      return DataColumn(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getColumnTitle(col),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (isExtra && col != "article" && col != "quantity")
              IconButton(
                icon:
                    const Icon(Icons.delete, size: 18, color: Colors.redAccent),
                tooltip: 'Eliminar atributo',
                onPressed: () => _showDeleteAttributeDialog(context, col),
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
          onPressed: () => _showAddAttributeDialog(context),
        ),
      ),
    );

    return cols;
  }

  List<DataRow> _buildRows(
      List<Item> items, List<String> columns, WidgetRef ref) {
    return items.map((item) {
      return DataRow(
        key: ValueKey(item.id),
        selected: item.id == selectedItemId,
        onSelectChanged: (selected) {
          onItemSelected(selected == true ? item.id : null);
        },
        cells: [
          ...columns.map((col) {
            String initialValue;
            if (col == "article") {
              initialValue = item.name;
            } else if (col == "quantity") {
              initialValue = item.quantity?.toString() ?? '';
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
                  focusNode: focusNodes['${item.id}-$col'] ??= FocusNode(),
                  child: TextFormField(
                    key: ValueKey('${item.id}-$col'),
                    initialValue: initialValue,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: _getColumnHint(col),
                    ),
                    keyboardType: col == "quantity"
                        ? TextInputType.number
                        : TextInputType.text,
                    onChanged: (value) => _updateCell(col, value, item),
                  ),
                ),
              ),
            );
          }).toList(),
          DataCell(Container()),
        ],
      );
    }).toList();
  }

  void _updateCell(String column, String value, Item item) {
    Item updatedItem;
    if (column == "article") {
      updatedItem = item.copyWith(name: value);
    } else if (column == "quantity") {
      final quantity = value.trim().isEmpty ? null : int.tryParse(value);
      updatedItem = item.copyWith(quantity: quantity);
    } else {
      final updatedExtra = Map<String, dynamic>.from(item.extraAttributes);
      updatedExtra[column] = value;
      updatedItem = item.copyWith(extraAttributes: updatedExtra);
    }

    final items = List<Item>.from(localItems);
    final index = items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      items[index] = updatedItem;
      onItemsChanged(items);
    }
  }

  void _addRow(WidgetRef ref) {
    final newItem = Item(
      id: const Uuid().v4(),
      name: '',
      quantity: null,
      extraAttributes: {},
    );

    final updatedItems = [...localItems, newItem];
    onItemsChanged(updatedItems);

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

  void _removeAttribute(String attribute) {
    // Primero actualizamos los items para eliminar el atributo de cada uno
    final updatedItems = localItems.map((item) {
      final newAttributes = Map<String, dynamic>.from(item.extraAttributes);
      newAttributes.remove(attribute);
      return item.copyWith(extraAttributes: newAttributes);
    }).toList();

    // Actualizamos los atributos extra
    final updatedAttributes =
        localExtraAttributes.where((a) => a != attribute).toList();

    // Notificamos los cambios
    onItemsChanged(updatedItems);
    onAttributesChanged(updatedAttributes);
  }

  Future<void> _showAddAttributeDialog(BuildContext context) async {
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
          FilledButton(
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
      // Agregamos el nuevo atributo a la lista local
      final updatedAttributes = [...localExtraAttributes, result];
      onAttributesChanged(updatedAttributes);
    }
  }

  Future<void> _showDeleteAttributeDialog(
      BuildContext context, String attribute) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Atributo'),
        content: Text(
          '¿Estás seguro de que deseas eliminar el atributo "$attribute"?\n\n'
          'Esta acción eliminará este campo de todos los items y no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (result == true) {
      _removeAttribute(attribute);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Atributo "$attribute" eliminado'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _getColumnHint(String column) {
    switch (column) {
      case "article":
        return "Artículo";
      case "quantity":
        return "Cantidad";
      default:
        return "Valor";
    }
  }

  String _getColumnTitle(String column) {
    switch (column) {
      case "article":
        return "Artículo";
      case "quantity":
        return "Cantidad";
      default:
        return column[0].toUpperCase() + column.substring(1);
    }
  }
}
