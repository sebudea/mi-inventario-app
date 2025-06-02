import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mi_inventario/features/inventory/domain/item.dart';
import 'package:mi_inventario/features/inventory/domain/shared_user.dart';

part 'inventory.freezed.dart';
part 'inventory.g.dart';

@freezed
class Inventory with _$Inventory {
  const factory Inventory({
    required String id,
    required String name,
    required String adminId,
    @Default([]) List<String> extraAttributes,
    @Default([]) List<Item> items,
    @Default([]) List<SharedUser> sharedUsers,
  }) = _Inventory;

  factory Inventory.fromJson(Map<String, dynamic> json) =>
      _$InventoryFromJson(json);
}
