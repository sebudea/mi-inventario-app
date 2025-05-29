import 'package:flutter/material.dart';
import 'package:mi_inventario/data/repositories/inventory_repository.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../domain/inventory/inventory.dart';
import '../../domain/item/item.dart';
import 'user_viewmodel.dart';

class InventoryViewModel extends ChangeNotifier {
  final InventoryRepository _inventoryRepository;
  InventoryViewModel(this._inventoryRepository);

  List<Inventory> _inventories = [];

  List<Inventory> get inventories => List.unmodifiable(_inventories);

  // Carga los inventarios propios del usuario
  Future<void> loadInventories(List<String> ownedInventories) async {
    _inventories.clear();
    if (ownedInventories.isNotEmpty) {
      try {
        final loadedInventories =
            await _inventoryRepository.getInventoriesByIds(ownedInventories);
        if (loadedInventories != null) {
          _inventories = loadedInventories;
        } else {
          debugPrint(
              'No se encontraron inventarios para los IDs proporcionados.');
        }
      } catch (e) {
        // Manejo de errores, podrías lanzar una excepción o registrar el error
        debugPrint('Error al cargar inventarios: $e');
      }
    }
    notifyListeners();
  }

  // Agrega un nuevo inventario con nombre y adminId
  Future<void> addInventory(
      BuildContext context, String name, String adminId) async {
    final String uniqueId = const Uuid().v4();
    final Inventory newInventory = Inventory(
      id: uniqueId,
      name: name,
      adminId: adminId,
    );

    try {
      // Guarda el inventario en la base de datos
      await _inventoryRepository.createInventory(newInventory);

      _inventories.add(newInventory);

      // Accede al UserViewModel y agrega el ID del inventario (esto ya actualiza la base de datos)
      final userViewModel = Provider.of<UserViewModel>(context, listen: false);
      await userViewModel.addOwnedInventory(uniqueId);

      notifyListeners();
    } catch (e) {
      debugPrint('Error al crear inventario: $e');
      // Aquí puedes manejar el error, mostrar un mensaje, etc.
    }
  }

  Future<void> removeInventory(BuildContext context, String id) async {
    try {
      // Elimina el inventario de la base de datos
      await _inventoryRepository.deleteInventory(id);

      _inventories.removeWhere((inv) => inv.id == id);

      // También actualiza el UserViewModel en la base de datos
      final userViewModel = Provider.of<UserViewModel>(context, listen: false);
      await userViewModel.removeOwnedInventory(id);

      notifyListeners();
    } catch (e) {
      debugPrint('Error al eliminar inventario: $e');
      // Aquí puedes manejar el error, mostrar un mensaje, etc.
    }
  }

  Future<void> addItemToInventory(String inventoryId, Item item) async {
    final index = _inventories.indexWhere((inv) => inv.id == inventoryId);
    if (index != -1) {
      final inventory = _inventories[index];
      final updatedItems = List<Item>.from(inventory.items ?? []);
      updatedItems.add(item);
      final updatedInventory = inventory.copyWith(items: updatedItems);

      // Actualiza en la base de datos
      try {
        await _inventoryRepository.updateInventory(updatedInventory);
        _inventories[index] = updatedInventory;
        notifyListeners();
      } catch (e) {
        debugPrint('Error al agregar item al inventario: $e');
        // Aquí puedes manejar el error, mostrar un mensaje, etc.
      }
    }
  }

  Future<void> updateItems(String inventoryId, List<Item> newItems) async {
    final index = _inventories.indexWhere((inv) => inv.id == inventoryId);
    if (index != -1) {
      final inventory = _inventories[index];
      final updatedInventory = inventory.copyWith(items: newItems);
      try {
        await _inventoryRepository.updateInventory(updatedInventory);
        _inventories[index] = updatedInventory;
        notifyListeners();
      } catch (e) {
        debugPrint('Error al actualizar items del inventario: $e');
      }
    }
  }

  Future<void> removeItemFromInventory(
      String inventoryId, int itemIndex) async {
    final index = _inventories.indexWhere((inv) => inv.id == inventoryId);
    if (index != -1) {
      final inventory = _inventories[index];
      final updatedItems = List<Item>.from(inventory.items ?? []);
      if (itemIndex >= 0 && itemIndex < updatedItems.length) {
        updatedItems.removeAt(itemIndex);
        final updatedInventory = inventory.copyWith(items: updatedItems);
        try {
          await _inventoryRepository.updateInventory(updatedInventory);
          _inventories[index] = updatedInventory;
          notifyListeners();
        } catch (e) {
          debugPrint('Error al eliminar item del inventario: $e');
        }
      }
    }
  }

  Future<void> addExtraAttribute(String inventoryId, String attribute) async {
    final index = _inventories.indexWhere((inv) => inv.id == inventoryId);
    if (index != -1) {
      final inventory = _inventories[index];
      final updatedAttributes = List<String>.from(inventory.extraAttributes);
      if (!updatedAttributes.contains(attribute)) {
        updatedAttributes.add(attribute);
        final updatedInventory =
            inventory.copyWith(extraAttributes: updatedAttributes);
        try {
          await _inventoryRepository.updateInventory(updatedInventory);
          _inventories[index] = updatedInventory;
          notifyListeners();
        } catch (e) {
          debugPrint('Error al agregar atributo extra: $e');
        }
      }
    }
  }

  Future<void> removeExtraAttribute(
      String inventoryId, String attribute) async {
    final index = _inventories.indexWhere((inv) => inv.id == inventoryId);
    if (index != -1) {
      final inventory = _inventories[index];
      final updatedAttributes = List<String>.from(inventory.extraAttributes);
      updatedAttributes.remove(attribute);

      // Limpia ese atributo de todos los items
      final updatedItems = (inventory.items ?? []).map((item) {
        final updatedExtra = Map<String, dynamic>.from(item.extraAttributes);
        updatedExtra.remove(attribute);
        return item.copyWith(extraAttributes: updatedExtra);
      }).toList();

      final updatedInventory = inventory.copyWith(
        extraAttributes: updatedAttributes,
        items: updatedItems,
      );
      try {
        await _inventoryRepository.updateInventory(updatedInventory);
        _inventories[index] = updatedInventory;
        notifyListeners();
      } catch (e) {
        debugPrint('Error al eliminar atributo extra: $e');
      }
    }
  }
}
