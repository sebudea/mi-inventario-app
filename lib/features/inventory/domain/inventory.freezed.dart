// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inventory.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Inventory _$InventoryFromJson(Map<String, dynamic> json) {
  return _Inventory.fromJson(json);
}

/// @nodoc
mixin _$Inventory {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get adminId => throw _privateConstructorUsedError;
  List<String> get extraAttributes => throw _privateConstructorUsedError;
  List<Item> get items => throw _privateConstructorUsedError;
  List<SharedUser> get sharedUsers => throw _privateConstructorUsedError;

  /// Serializes this Inventory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Inventory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InventoryCopyWith<Inventory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InventoryCopyWith<$Res> {
  factory $InventoryCopyWith(Inventory value, $Res Function(Inventory) then) =
      _$InventoryCopyWithImpl<$Res, Inventory>;
  @useResult
  $Res call(
      {String id,
      String name,
      String adminId,
      List<String> extraAttributes,
      List<Item> items,
      List<SharedUser> sharedUsers});
}

/// @nodoc
class _$InventoryCopyWithImpl<$Res, $Val extends Inventory>
    implements $InventoryCopyWith<$Res> {
  _$InventoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Inventory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? adminId = null,
    Object? extraAttributes = null,
    Object? items = null,
    Object? sharedUsers = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      adminId: null == adminId
          ? _value.adminId
          : adminId // ignore: cast_nullable_to_non_nullable
              as String,
      extraAttributes: null == extraAttributes
          ? _value.extraAttributes
          : extraAttributes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<Item>,
      sharedUsers: null == sharedUsers
          ? _value.sharedUsers
          : sharedUsers // ignore: cast_nullable_to_non_nullable
              as List<SharedUser>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InventoryImplCopyWith<$Res>
    implements $InventoryCopyWith<$Res> {
  factory _$$InventoryImplCopyWith(
          _$InventoryImpl value, $Res Function(_$InventoryImpl) then) =
      __$$InventoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String adminId,
      List<String> extraAttributes,
      List<Item> items,
      List<SharedUser> sharedUsers});
}

/// @nodoc
class __$$InventoryImplCopyWithImpl<$Res>
    extends _$InventoryCopyWithImpl<$Res, _$InventoryImpl>
    implements _$$InventoryImplCopyWith<$Res> {
  __$$InventoryImplCopyWithImpl(
      _$InventoryImpl _value, $Res Function(_$InventoryImpl) _then)
      : super(_value, _then);

  /// Create a copy of Inventory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? adminId = null,
    Object? extraAttributes = null,
    Object? items = null,
    Object? sharedUsers = null,
  }) {
    return _then(_$InventoryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      adminId: null == adminId
          ? _value.adminId
          : adminId // ignore: cast_nullable_to_non_nullable
              as String,
      extraAttributes: null == extraAttributes
          ? _value._extraAttributes
          : extraAttributes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<Item>,
      sharedUsers: null == sharedUsers
          ? _value._sharedUsers
          : sharedUsers // ignore: cast_nullable_to_non_nullable
              as List<SharedUser>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$InventoryImpl implements _Inventory {
  const _$InventoryImpl(
      {required this.id,
      required this.name,
      required this.adminId,
      final List<String> extraAttributes = const [],
      final List<Item> items = const [],
      final List<SharedUser> sharedUsers = const []})
      : _extraAttributes = extraAttributes,
        _items = items,
        _sharedUsers = sharedUsers;

  factory _$InventoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$InventoryImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String adminId;
  final List<String> _extraAttributes;
  @override
  @JsonKey()
  List<String> get extraAttributes {
    if (_extraAttributes is EqualUnmodifiableListView) return _extraAttributes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_extraAttributes);
  }

  final List<Item> _items;
  @override
  @JsonKey()
  List<Item> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  final List<SharedUser> _sharedUsers;
  @override
  @JsonKey()
  List<SharedUser> get sharedUsers {
    if (_sharedUsers is EqualUnmodifiableListView) return _sharedUsers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sharedUsers);
  }

  @override
  String toString() {
    return 'Inventory(id: $id, name: $name, adminId: $adminId, extraAttributes: $extraAttributes, items: $items, sharedUsers: $sharedUsers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InventoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.adminId, adminId) || other.adminId == adminId) &&
            const DeepCollectionEquality()
                .equals(other._extraAttributes, _extraAttributes) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            const DeepCollectionEquality()
                .equals(other._sharedUsers, _sharedUsers));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      adminId,
      const DeepCollectionEquality().hash(_extraAttributes),
      const DeepCollectionEquality().hash(_items),
      const DeepCollectionEquality().hash(_sharedUsers));

  /// Create a copy of Inventory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InventoryImplCopyWith<_$InventoryImpl> get copyWith =>
      __$$InventoryImplCopyWithImpl<_$InventoryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InventoryImplToJson(
      this,
    );
  }
}

abstract class _Inventory implements Inventory {
  const factory _Inventory(
      {required final String id,
      required final String name,
      required final String adminId,
      final List<String> extraAttributes,
      final List<Item> items,
      final List<SharedUser> sharedUsers}) = _$InventoryImpl;

  factory _Inventory.fromJson(Map<String, dynamic> json) =
      _$InventoryImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get adminId;
  @override
  List<String> get extraAttributes;
  @override
  List<Item> get items;
  @override
  List<SharedUser> get sharedUsers;

  /// Create a copy of Inventory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InventoryImplCopyWith<_$InventoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
