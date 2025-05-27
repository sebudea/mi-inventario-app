import 'package:freezed_annotation/freezed_annotation.dart';

part 'item.freezed.dart';
part 'item.g.dart';

@freezed
class Item with _$Item {
  const factory Item({
    required String name, // Nombre del item
    required int quantity, // Cantidad del item
    // Atributos extra definidos por el inventario (ej: color, peso, marca)
    @Default({}) Map<String, dynamic> extraAttributes,
  }) = _Item;

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
}
