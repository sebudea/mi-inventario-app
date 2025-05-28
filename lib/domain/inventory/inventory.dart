import 'package:freezed_annotation/freezed_annotation.dart';
import '../item/item.dart';
import 'shared_user.dart';

part 'inventory.freezed.dart';
part 'inventory.g.dart';

@freezed
class Inventory with _$Inventory {
  const factory Inventory({
    required String id,
    required String name,
    required String adminId, // ID del usuario creador (admin)

    // Atributos extra definidos para los items
    @Default([]) List<String> extraAttributes,
    @Default([]) List<Item> items, // Lista de items del inventario
    @Default([]) List<SharedUser> sharedUsers, // Usuarios con acceso compartido
  }) = _Inventory;

  factory Inventory.fromJson(Map<String, dynamic> json) =>
      _$InventoryFromJson(json);
}
