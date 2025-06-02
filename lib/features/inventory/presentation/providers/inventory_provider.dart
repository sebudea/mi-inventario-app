import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mi_inventario/features/inventory/domain/inventory.dart';
import 'package:mi_inventario/features/inventory/domain/item.dart';
import 'package:uuid/uuid.dart';

part 'inventory_provider.g.dart';

@riverpod
class InventoryNotifier extends _$InventoryNotifier {
  @override
  FutureOr<List<Inventory>> build() {
    return [];
  }

  void addInventory(String name, String adminId) {
    final String uniqueId = const Uuid().v4();
    final initialItem = Item(
      id: const Uuid().v4(),
      name: '',
      quantity: null,
      extraAttributes: {},
    );
    final newInventory = Inventory(
      id: uniqueId,
      name: name,
      adminId: adminId,
      items: [initialItem],
    );

    state.whenData((inventories) {
      state = AsyncData([...inventories, newInventory]);
    });
  }

  void removeInventory(String id) {
    state.whenData((inventories) {
      state = AsyncData(inventories.where((inv) => inv.id != id).toList());
    });
  }

  void updateInventory(String id, Inventory inventory) {
    state.whenData((inventories) {
      final index = inventories.indexWhere((inv) => inv.id == id);
      if (index != -1) {
        final updatedInventories = List<Inventory>.from(inventories);
        updatedInventories[index] = inventory;
        state = AsyncData(updatedInventories);
      }
    });
  }

  void addItemToInventory(String inventoryId, Item item) {
    state.whenData((inventories) {
      final index = inventories.indexWhere((inv) => inv.id == inventoryId);
      if (index != -1) {
        final inventory = inventories[index];
        final updatedItems = List<Item>.from(inventory.items)..add(item);
        final updatedInventory = inventory.copyWith(items: updatedItems);
        final updatedInventories = List<Inventory>.from(inventories);
        updatedInventories[index] = updatedInventory;
        state = AsyncData(updatedInventories);
      }
    });
  }

  void updateItems(String inventoryId, List<Item> newItems) {
    state.whenData((inventories) {
      final index = inventories.indexWhere((inv) => inv.id == inventoryId);
      if (index != -1) {
        final inventory = inventories[index];
        final updatedInventory = inventory.copyWith(items: newItems);
        final updatedInventories = List<Inventory>.from(inventories);
        updatedInventories[index] = updatedInventory;
        state = AsyncData(updatedInventories);
      }
    });
  }

  void addExtraAttribute(String inventoryId, String attribute) {
    state.whenData((inventories) {
      final index = inventories.indexWhere((inv) => inv.id == inventoryId);
      if (index != -1) {
        final inventory = inventories[index];
        final updatedAttributes = List<String>.from(inventory.extraAttributes);
        if (!updatedAttributes.contains(attribute)) {
          updatedAttributes.add(attribute);
          final updatedInventory =
              inventory.copyWith(extraAttributes: updatedAttributes);
          final updatedInventories = List<Inventory>.from(inventories);
          updatedInventories[index] = updatedInventory;
          state = AsyncData(updatedInventories);
        }
      }
    });
  }

  void removeExtraAttribute(String inventoryId, String attribute) {
    state.whenData((inventories) {
      final index = inventories.indexWhere((inv) => inv.id == inventoryId);
      if (index != -1) {
        final inventory = inventories[index];
        final updatedAttributes = List<String>.from(inventory.extraAttributes)
          ..remove(attribute);

        final updatedItems = inventory.items.map((item) {
          final updatedExtra = Map<String, dynamic>.from(item.extraAttributes)
            ..remove(attribute);
          return item.copyWith(extraAttributes: updatedExtra);
        }).toList();

        final updatedInventory = inventory.copyWith(
          extraAttributes: updatedAttributes,
          items: updatedItems,
        );
        final updatedInventories = List<Inventory>.from(inventories);
        updatedInventories[index] = updatedInventory;
        state = AsyncData(updatedInventories);
      }
    });
  }
}
