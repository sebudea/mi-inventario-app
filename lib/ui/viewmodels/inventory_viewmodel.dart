import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../domain/inventory/inventory.dart';
import '../../domain/item/item.dart';
import 'user_viewmodel.dart';

class InventoryViewModel extends ChangeNotifier {
  List<Inventory> _inventories = [];

  List<Inventory> get inventories => List.unmodifiable(_inventories);

  // Simula la carga de inventarios a partir de una lista de IDs
  Future<void> loadInventories(List<String> ownedInventories) async {
    _inventories.clear();
    if (ownedInventories.isNotEmpty) {
      // Simulación: crea inventarios de ejemplo con los IDs recibidos
      _inventories = ownedInventories.map((id) {
        return Inventory(
          id: id,
          name: 'Inventario $id',
          adminId: 'adminId',
        );
      }).toList();
    }
    notifyListeners();
  }

  // Agrega un nuevo inventario con nombre y adminId
  void addInventory(BuildContext context, String name, String adminId) {
    final String uniqueId = const Uuid().v4();
    final Inventory newInventory = Inventory(
      id: uniqueId,
      name: name,
      adminId: adminId,
    );

    _inventories.add(newInventory);

    // Accede al UserViewModel y agrega el ID del inventario
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    userViewModel.addOwnedInventory(uniqueId);

    notifyListeners();
  }

  void removeInventory(BuildContext context, String id) {
    _inventories.removeWhere((inv) => inv.id == id);

    // También puedes actualizar el UserViewModel si lo deseas:
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    userViewModel.removeOwnedInventory(id);

    notifyListeners();
  }

  void addItemToInventory(String inventoryId, Item item) {
    final index = _inventories.indexWhere((inv) => inv.id == inventoryId);
    if (index != -1) {
      final inventory = _inventories[index];
      final updatedItems = List<Item>.from(inventory.items ?? []);
      updatedItems.add(item);
      _inventories[index] = inventory.copyWith(items: updatedItems);
      notifyListeners();
    }
  }

  void updateItems(String inventoryId, List<Item> newItems) {
    final index = _inventories.indexWhere((inv) => inv.id == inventoryId);
    if (index != -1) {
      final inventory = _inventories[index];
      _inventories[index] = inventory.copyWith(items: newItems);
      notifyListeners();
    }
  }

  void removeItemFromInventory(String inventoryId, int itemIndex) {
    final index = _inventories.indexWhere((inv) => inv.id == inventoryId);
    if (index != -1) {
      final inventory = _inventories[index];
      final updatedItems = List<Item>.from(inventory.items ?? []);
      if (itemIndex >= 0 && itemIndex < updatedItems.length) {
        updatedItems.removeAt(itemIndex);
        _inventories[index] = inventory.copyWith(items: updatedItems);
        notifyListeners();
      }
    }
  }

  void addExtraAttribute(String inventoryId, String attribute) {
    final index = _inventories.indexWhere((inv) => inv.id == inventoryId);
    if (index != -1) {
      final inventory = _inventories[index];
      final updatedAttributes = List<String>.from(inventory.extraAttributes);
      if (!updatedAttributes.contains(attribute)) {
        updatedAttributes.add(attribute);
        _inventories[index] =
            inventory.copyWith(extraAttributes: updatedAttributes);
        notifyListeners();
      }
    }
  }
}
