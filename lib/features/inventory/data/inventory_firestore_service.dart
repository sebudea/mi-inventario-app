import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class InventoryFirestoreService {
  final _inventoryCollection =
      FirebaseFirestore.instance.collection('inventories');

  Future<bool> createInventory(
      Map<String, dynamic> inventoryData, String inventoryId) async {
    try {
      await _inventoryCollection.doc(inventoryId).set(inventoryData);
      return true;
    } catch (e) {
      debugPrint('Error createInventory: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getInventory(String inventoryId) async {
    try {
      DocumentSnapshot doc = await _inventoryCollection.doc(inventoryId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Error getInventory: $e');
    }
    return null;
  }

  Future<bool> updateInventory(
      Map<String, dynamic> inventoryData, String inventoryId) async {
    try {
      await _inventoryCollection.doc(inventoryId).update(inventoryData);
      return true;
    } catch (e) {
      debugPrint('Error updateInventory: $e');
      return false;
    }
  }

  Future<bool> deleteInventory(String inventoryId) async {
    try {
      await _inventoryCollection.doc(inventoryId).delete();
      return true;
    } catch (e) {
      debugPrint('Error deleteInventory: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>?> getInventoriesByIds(
      List<String> inventoryIds) async {
    try {
      List<Map<String, dynamic>> inventories = [];
      for (String id in inventoryIds) {
        DocumentSnapshot doc = await _inventoryCollection.doc(id).get();
        if (doc.exists) {
          inventories.add(doc.data() as Map<String, dynamic>);
        }
      }
      return inventories;
    } catch (e) {
      debugPrint('Error getInventoriesByIds: $e');
      return null;
    }
  }
}
