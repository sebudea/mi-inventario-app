// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InventoryImpl _$$InventoryImplFromJson(Map<String, dynamic> json) =>
    _$InventoryImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      adminId: json['adminId'] as String,
      extraAttributes: (json['extraAttributes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => Item.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      sharedUsers: (json['sharedUsers'] as List<dynamic>?)
              ?.map((e) => SharedUser.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$InventoryImplToJson(_$InventoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'adminId': instance.adminId,
      'extraAttributes': instance.extraAttributes,
      'items': instance.items,
      'sharedUsers': instance.sharedUsers,
    };
