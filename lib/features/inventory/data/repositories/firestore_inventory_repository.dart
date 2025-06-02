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
      debugPrint('🚫 Firebase: Usuario no autenticado');
      throw FirebaseException(
        plugin: 'firestore',
        message: 'Must be logged in to perform this operation',
      );
    }
  }

  // Create a new inventory
  Future<void> createInventory(Inventory inventory) async {
    try {
      _checkAuth();
      debugPrint('📝 Firebase: Creando inventario ${inventory.id}');

      await _firestore.collection(_collection).doc(inventory.id).set(
            inventory.toJson(),
          );
    } catch (e) {
      debugPrint('❌ Firebase Error: Error al crear inventario - $e');
      rethrow;
    }
  }

  // Get a single inventory by ID
  Stream<Inventory> watchInventory(String id) {
    _checkAuth();
    debugPrint('👀 Firebase: Observando inventario $id');

    return _firestore.collection(_collection).doc(id).snapshots().map((doc) {
      if (!doc.exists) {
        debugPrint('❌ Firebase Error: Inventario no encontrado - $id');
        throw FirebaseException(
          plugin: 'firestore',
          message: 'Inventory not found',
        );
      }
      return Inventory.fromJson(doc.data()!);
    });
  }

  // Get all inventories for a user
  Stream<List<Inventory>> watchUserInventories(String userId) {
    _checkAuth();
    debugPrint('👀 Firebase: Observando inventarios del usuario $userId');

    return _firestore
        .collection(_collection)
        .where('adminId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Inventory.fromJson(doc.data()))
            .toList());
  }

  // Update an inventory
  Future<void> updateInventory(Inventory inventory) async {
    try {
      _checkAuth();
      debugPrint('📝 Firebase: Actualizando inventario ${inventory.id}');

      final docRef = _firestore.collection(_collection).doc(inventory.id);
      final doc = await docRef.get();

      if (!doc.exists) {
        throw Exception('Inventario no encontrado');
      }

      final data = inventory.toJson();
      data['items'] = inventory.items.map((item) => item.toJson()).toList();

      await docRef.update(data);
    } catch (e) {
      debugPrint('❌ Firebase Error: Error al actualizar inventario - $e');
      rethrow;
    }
  }

  // Delete an inventory
  Future<void> deleteInventory(String id) async {
    try {
      _checkAuth();
      debugPrint('🗑️ Firebase: Eliminando inventario $id');

      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      debugPrint('❌ Firebase Error: Error al eliminar inventario - $e');
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
