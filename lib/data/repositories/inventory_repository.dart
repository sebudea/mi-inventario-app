import 'package:flutter/material.dart';
import 'package:mi_inventario/data/services/inventory_firestore_service.dart';
import 'package:mi_inventario/domain/inventory/inventory.dart';

class InventoryRepository {
  final InventoryFirestoreService _inventoryFirestoreService;
  InventoryRepository(this._inventoryFirestoreService);

  Future<bool> createInventory(Inventory inventory) async {
    bool result = false;
    try {
      final Map<String, dynamic> inventoryData = inventory.toJson();
      final String inventoryId = inventory.id;
      result = await _inventoryFirestoreService.createInventory(
          inventoryData, inventoryId);
      if (result) {
        debugPrint("Inventario creado exitosamente: $inventoryData");
      } else {
        debugPrint("Error al crear inventario: $inventoryData");
      }
    } catch (e) {
      debugPrint("Error al crear inventario: $e");
    }
    return result;
  }

  Future<Inventory?> getInventory(String inventoryId) async {
    try {
      final Map<String, dynamic>? inventoryData =
          await _inventoryFirestoreService.getInventory(inventoryId);

      if (inventoryData != null) {
        Inventory inventory = Inventory.fromJson(inventoryData);
        debugPrint("Inventario obtenido exitosamente: ${inventory.toJson()}");
        return inventory;
      } else {
        debugPrint("Inventario no encontrado para el ID: $inventoryId");
      }
    } catch (e) {
      debugPrint("Error al obtener inventario: $e");
    }
    return null;
  }

  Future<bool> updateInventory(Inventory inventory) async {
    bool result = false;
    try {
      final Map<String, dynamic> inventoryData = inventory.toJson();
      final String inventoryId = inventory.id;
      result = await _inventoryFirestoreService.updateInventory(
          inventoryData, inventoryId);
      if (result) {
        debugPrint("Inventario actualizado exitosamente: $inventoryData");
      } else {
        debugPrint("Error al actualizar inventario: $inventoryData");
      }
    } catch (e) {
      debugPrint("Error al actualizar inventario: $e");
    }
    return result;
  }

  Future<bool> deleteInventory(String inventoryId) async {
    bool result = false;
    try {
      result = await _inventoryFirestoreService.deleteInventory(inventoryId);
      if (result) {
        debugPrint("Inventario eliminado exitosamente: $inventoryId");
      } else {
        debugPrint("Error al eliminar inventario: $inventoryId");
      }
    } catch (e) {
      debugPrint("Error al eliminar inventario: $e");
    }
    return result;
  }

  Future<List<Inventory>?> getInventoriesByIds(
      List<String> inventoryIds) async {
    try {
      final List<Map<String, dynamic>>? inventoriesData =
          await _inventoryFirestoreService.getInventoriesByIds(inventoryIds);

      if (inventoriesData != null) {
        List<Inventory> inventories =
            inventoriesData.map((data) => Inventory.fromJson(data)).toList();
        debugPrint("Inventarios obtenidos exitosamente: ${inventories.length}");
        return inventories;
      } else {
        debugPrint("No se encontraron inventarios para los IDs: $inventoryIds");
      }
    } catch (e) {
      debugPrint("Error al obtener inventarios: $e");
    }
    return null;
  }
}
