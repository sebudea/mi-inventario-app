import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_inventario/features/inventory/domain/inventory.dart';
import 'package:mi_inventario/features/inventory/domain/item.dart';

final inventoryRepositoryProvider =
    Provider<FirestoreInventoryRepository>((ref) {
  debugPrint('🏭 Creando instancia de FirestoreInventoryRepository');
  final repository = FirestoreInventoryRepository(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  );
  debugPrint('✅ FirestoreInventoryRepository creado exitosamente');
  return repository;
});

class FirestoreInventoryRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final String _collection = 'inventories';

  FirestoreInventoryRepository(this._firestore, this._auth);

  // Verificar autenticación
  void _checkAuth() {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('🚫 Error: Usuario no autenticado');
      throw FirebaseException(
        plugin: 'firestore',
        message: 'Must be logged in to perform this operation',
      );
    }
    debugPrint('✅ Usuario autenticado: ${user.email}');
  }

  // Create a new inventory
  Future<void> createInventory(Inventory inventory) async {
    try {
      _checkAuth();
      debugPrint('📝 Creando inventario: ${inventory.name}');
      debugPrint('📄 Datos: ${inventory.toJson()}');

      await _firestore.collection(_collection).doc(inventory.id).set(
            inventory.toJson(),
          );
      debugPrint('✅ Inventario creado exitosamente');
    } catch (e) {
      debugPrint('🚫 Error creando inventario: $e');
      rethrow;
    }
  }

  // Get a single inventory by ID
  Stream<Inventory> watchInventory(String id) {
    _checkAuth();
    debugPrint('👀 Observando inventario: $id');

    return _firestore.collection(_collection).doc(id).snapshots().map((doc) {
      if (!doc.exists) {
        debugPrint('🚫 Inventario no encontrado: $id');
        throw FirebaseException(
          plugin: 'firestore',
          message: 'Inventory not found',
        );
      }
      debugPrint('📥 Datos de inventario recibidos: ${doc.data()}');
      return Inventory.fromJson(doc.data()!);
    });
  }

  // Get all inventories for a user (either as admin or shared)
  Stream<List<Inventory>> watchUserInventories(String userId) {
    _checkAuth();
    debugPrint('👀 Observando inventarios del usuario: $userId');

    return _firestore
        .collection(_collection)
        .where('adminId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final inventories =
          snapshot.docs.map((doc) => Inventory.fromJson(doc.data())).toList();
      debugPrint('📥 ${inventories.length} inventarios encontrados');
      return inventories;
    });
  }

  // Update an inventory
  Future<void> updateInventory(Inventory inventory) async {
    debugPrint('📝 Actualizando inventario: ${inventory.name}');
    try {
      _checkAuth();

      final docRef = _firestore.collection(_collection).doc(inventory.id);
      final doc = await docRef.get();

      if (!doc.exists) {
        debugPrint('❌ Inventario no encontrado: ${inventory.id}');
        throw Exception('Inventario no encontrado');
      }

      // Convertimos el inventario a JSON y aseguramos que los items se serialicen correctamente
      final data = inventory.toJson();
      data['items'] = inventory.items.map((item) => item.toJson()).toList();

      debugPrint('📄 Datos a actualizar: $data');
      await docRef.update(data);
      debugPrint('✅ Inventario actualizado exitosamente');
    } catch (e) {
      debugPrint('🚫 Error actualizando inventario: $e');
      rethrow;
    }
  }

  // Delete an inventory
  Future<void> deleteInventory(String id) async {
    try {
      _checkAuth();
      debugPrint('🗑️ Eliminando inventario: $id');

      await _firestore.collection(_collection).doc(id).delete();
      debugPrint('✅ Inventario eliminado exitosamente');
    } catch (e) {
      debugPrint('🚫 Error eliminando inventario: $e');
      rethrow;
    }
  }

  // Add an item to an inventory
  Future<void> addItem(String inventoryId, Item item) async {
    try {
      _checkAuth();
      debugPrint('📝 Agregando item a inventario: $inventoryId');
      debugPrint('📄 Datos del item: ${item.toJson()}');

      final inventoryRef = _firestore.collection(_collection).doc(inventoryId);

      await _firestore.runTransaction((transaction) async {
        final inventoryDoc = await transaction.get(inventoryRef);
        if (!inventoryDoc.exists) {
          debugPrint('🚫 Inventario no encontrado: $inventoryId');
          throw FirebaseException(
            plugin: 'firestore',
            message: 'Inventory not found',
          );
        }
        final inventory = Inventory.fromJson(inventoryDoc.data()!);
        final updatedItems = [...inventory.items, item];

        transaction.update(inventoryRef, {
          'items': updatedItems.map((item) => item.toJson()).toList(),
        });
      });
      debugPrint('✅ Item agregado exitosamente');
    } catch (e) {
      debugPrint('🚫 Error agregando item: $e');
      rethrow;
    }
  }

  // Update an item in an inventory
  Future<void> updateItem(String inventoryId, Item updatedItem) async {
    try {
      _checkAuth();
      debugPrint('📝 Actualizando item en inventario: $inventoryId');
      debugPrint('📄 Nuevos datos del item: ${updatedItem.toJson()}');

      final inventoryRef = _firestore.collection(_collection).doc(inventoryId);

      await _firestore.runTransaction((transaction) async {
        final inventoryDoc = await transaction.get(inventoryRef);
        if (!inventoryDoc.exists) {
          debugPrint('🚫 Inventario no encontrado: $inventoryId');
          throw FirebaseException(
            plugin: 'firestore',
            message: 'Inventory not found',
          );
        }
        final inventory = Inventory.fromJson(inventoryDoc.data()!);
        final updatedItems = inventory.items.map((item) {
          return item.id == updatedItem.id ? updatedItem : item;
        }).toList();

        transaction.update(inventoryRef, {
          'items': updatedItems.map((item) => item.toJson()).toList(),
        });
      });
      debugPrint('✅ Item actualizado exitosamente');
    } catch (e) {
      debugPrint('🚫 Error actualizando item: $e');
      rethrow;
    }
  }

  // Delete an item from an inventory
  Future<void> deleteItem(String inventoryId, String itemId) async {
    try {
      _checkAuth();
      debugPrint('🗑️ Eliminando item $itemId del inventario: $inventoryId');

      final inventoryRef = _firestore.collection(_collection).doc(inventoryId);

      await _firestore.runTransaction((transaction) async {
        final inventoryDoc = await transaction.get(inventoryRef);
        if (!inventoryDoc.exists) {
          debugPrint('🚫 Inventario no encontrado: $inventoryId');
          throw FirebaseException(
            plugin: 'firestore',
            message: 'Inventory not found',
          );
        }
        final inventory = Inventory.fromJson(inventoryDoc.data()!);
        final updatedItems =
            inventory.items.where((item) => item.id != itemId).toList();

        transaction.update(inventoryRef, {
          'items': updatedItems.map((item) => item.toJson()).toList(),
        });
      });
      debugPrint('✅ Item eliminado exitosamente');
    } catch (e) {
      debugPrint('🚫 Error eliminando item: $e');
      rethrow;
    }
  }
}
