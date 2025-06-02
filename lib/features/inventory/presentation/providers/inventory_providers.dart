import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_inventario/features/auth/domain/user_model.dart';
import 'package:mi_inventario/features/inventory/data/repositories/firestore_inventory_repository.dart';
import 'package:mi_inventario/features/inventory/domain/inventory.dart';
import 'package:mi_inventario/features/inventory/domain/item.dart';
import 'package:uuid/uuid.dart';

final currentInventoryProvider = StateProvider<Inventory?>((ref) => null);

final userInventoriesProvider = StreamProvider.family<List<Inventory>, String>(
  (ref, userId) {
    debugPrint('🔍 Intentando obtener inventarios para usuario: $userId');
    final repository = ref.watch(inventoryRepositoryProvider);
    return repository.watchUserInventories(userId);
  },
);

final selectedInventoryProvider = StreamProvider.family<Inventory, String>(
  (ref, inventoryId) {
    debugPrint('🔍 Intentando obtener inventario: $inventoryId');
    final repository = ref.watch(inventoryRepositoryProvider);
    return repository.watchInventory(inventoryId);
  },
);

final inventoryNotifierProvider =
    AsyncNotifierProvider<InventoryNotifier, void>(() {
  return InventoryNotifier();
});

class InventoryNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> createInventory({
    required String name,
    required UserModel user,
    List<String> extraAttributes = const [],
  }) async {
    debugPrint(
        '📝 Intentando crear inventario: $name para usuario: ${user.email}');
    final repository = ref.read(inventoryRepositoryProvider);

    final inventory = Inventory(
      id: const Uuid().v4(),
      name: name,
      adminId: user.id,
      extraAttributes: extraAttributes,
      items: const [],
      sharedUsers: const [],
    );

    state = const AsyncLoading();
    state = await AsyncValue.guard(() => repository.createInventory(inventory));
  }

  Future<void> updateInventory(Inventory inventory) async {
    final repository = ref.read(inventoryRepositoryProvider);

    state = const AsyncLoading();
    state = await AsyncValue.guard(() => repository.updateInventory(inventory));
  }

  Future<void> deleteInventory(String id) async {
    final repository = ref.read(inventoryRepositoryProvider);

    state = const AsyncLoading();
    state = await AsyncValue.guard(() => repository.deleteInventory(id));
  }

  Future<void> addItem({
    required String inventoryId,
    required String name,
    required int quantity,
    Map<String, dynamic> extraAttributes = const {},
  }) async {
    final repository = ref.read(inventoryRepositoryProvider);

    final item = Item(
      id: const Uuid().v4(),
      name: name,
      quantity: quantity,
      extraAttributes: extraAttributes,
    );

    state = const AsyncLoading();
    state = await AsyncValue.guard(() => repository.addItem(inventoryId, item));
  }

  Future<void> updateItem(String inventoryId, Item item) async {
    final repository = ref.read(inventoryRepositoryProvider);

    state = const AsyncLoading();
    state =
        await AsyncValue.guard(() => repository.updateItem(inventoryId, item));
  }

  Future<void> deleteItem(String inventoryId, String itemId) async {
    final repository = ref.read(inventoryRepositoryProvider);

    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => repository.deleteItem(inventoryId, itemId));
  }

  Future<void> addItemToInventory(String inventoryId, Item item) async {
    debugPrint('📝 Agregando item a inventario: $inventoryId');
    final repository = ref.read(inventoryRepositoryProvider);

    state = const AsyncLoading();
    state = await AsyncValue.guard(() => repository.addItem(inventoryId, item));
  }

  Future<void> updateItems(String inventoryId, List<Item> items) async {
    debugPrint('📝 Actualizando items en inventario: $inventoryId');
    final repository = ref.read(inventoryRepositoryProvider);

    // Primero obtenemos el inventario actual
    final inventoryStream = repository.watchInventory(inventoryId);
    final currentInventory = await inventoryStream.first;

    // Creamos una nueva versión del inventario con los items actualizados
    final updatedInventory = currentInventory.copyWith(items: items);

    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      return repository.updateInventory(updatedInventory);
    });
  }

  Future<void> addExtraAttribute(String inventoryId, String attribute) async {
    debugPrint('📝 Agregando atributo a inventario: $inventoryId');
    final repository = ref.read(inventoryRepositoryProvider);
    final inventoryStream = repository.watchInventory(inventoryId);

    final inventory = await inventoryStream.first;
    final updatedAttributes = [...inventory.extraAttributes, attribute];

    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      return repository.updateInventory(
        inventory.copyWith(extraAttributes: updatedAttributes),
      );
    });
  }

  Future<void> removeExtraAttribute(
      String inventoryId, String attribute) async {
    debugPrint('🗑️ Eliminando atributo de inventario: $inventoryId');
    final repository = ref.read(inventoryRepositoryProvider);
    final inventoryStream = repository.watchInventory(inventoryId);

    final inventory = await inventoryStream.first;

    // Eliminamos el atributo de la lista de atributos extra
    final updatedAttributes =
        inventory.extraAttributes.where((a) => a != attribute).toList();

    // Eliminamos el atributo de todos los items
    final updatedItems = inventory.items.map((item) {
      final newAttributes = Map<String, dynamic>.from(item.extraAttributes);
      newAttributes.remove(attribute);
      return item.copyWith(extraAttributes: newAttributes);
    }).toList();

    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      return repository.updateInventory(
        inventory.copyWith(
          extraAttributes: updatedAttributes,
          items: updatedItems,
        ),
      );
    });
  }
}
