import 'package:flutter/foundation.dart';
import 'package:mi_inventario/features/inventory/data/inventory_firestore_service.dart';
import 'package:mi_inventario/features/inventory/domain/inventory.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inventory_repository.g.dart';

@riverpod
InventoryRepository inventoryRepository(InventoryRepositoryRef ref) {
  return InventoryRepository(InventoryFirestoreService());
}

class InventoryRepository {
  final InventoryFirestoreService _service;
  InventoryRepository(this._service);

  Future<bool> createInventory(Inventory inventory) async {
    try {
      final Map<String, dynamic> inventoryData = inventory.toJson();
      final result =
          await _service.createInventory(inventoryData, inventory.id);
      if (result) {
        debugPrint("Inventario creado exitosamente: $inventoryData");
      } else {
        debugPrint("Error al crear inventario: $inventoryData");
      }
      return result;
    } catch (e) {
      debugPrint("Error al crear inventario: $e");
      return false;
    }
  }

  Future<Inventory?> getInventory(String inventoryId) async {
    try {
      final inventoryData = await _service.getInventory(inventoryId);
      if (inventoryData != null) {
        final inventory = Inventory.fromJson(inventoryData);
        debugPrint("Inventario obtenido exitosamente: ${inventory.toJson()}");
        return inventory;
      }
    } catch (e) {
      debugPrint("Error al obtener inventario: $e");
    }
    return null;
  }

  Future<bool> updateInventory(Inventory inventory) async {
    try {
      final inventoryData = inventory.toJson();
      final result =
          await _service.updateInventory(inventoryData, inventory.id);
      if (result) {
        debugPrint("Inventario actualizado exitosamente: $inventoryData");
      } else {
        debugPrint("Error al actualizar inventario: $inventoryData");
      }
      return result;
    } catch (e) {
      debugPrint("Error al actualizar inventario: $e");
      return false;
    }
  }

  Future<bool> deleteInventory(String inventoryId) async {
    try {
      final result = await _service.deleteInventory(inventoryId);
      if (result) {
        debugPrint("Inventario eliminado exitosamente: $inventoryId");
      } else {
        debugPrint("Error al eliminar inventario: $inventoryId");
      }
      return result;
    } catch (e) {
      debugPrint("Error al eliminar inventario: $e");
      return false;
    }
  }

  Future<List<Inventory>> getInventoriesByIds(List<String> inventoryIds) async {
    try {
      final inventoriesData = await _service.getInventoriesByIds(inventoryIds);
      if (inventoriesData != null) {
        final inventories =
            inventoriesData.map((data) => Inventory.fromJson(data)).toList();
        debugPrint("Inventarios obtenidos exitosamente: ${inventories.length}");
        return inventories;
      }
    } catch (e) {
      debugPrint("Error al obtener inventarios: $e");
    }
    return [];
  }
}
