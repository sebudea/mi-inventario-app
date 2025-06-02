// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shared_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SharedUser _$SharedUserFromJson(Map<String, dynamic> json) {
  return _SharedUser.fromJson(json);
}

/// @nodoc
mixin _$SharedUser {
  String get userId => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  bool get canEdit => throw _privateConstructorUsedError;

  /// Serializes this SharedUser to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SharedUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SharedUserCopyWith<SharedUser> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SharedUserCopyWith<$Res> {
  factory $SharedUserCopyWith(
          SharedUser value, $Res Function(SharedUser) then) =
      _$SharedUserCopyWithImpl<$Res, SharedUser>;
  @useResult
  $Res call({String userId, String email, bool canEdit});
}

/// @nodoc
class _$SharedUserCopyWithImpl<$Res, $Val extends SharedUser>
    implements $SharedUserCopyWith<$Res> {
  _$SharedUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SharedUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? email = null,
    Object? canEdit = null,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      canEdit: null == canEdit
          ? _value.canEdit
          : canEdit // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SharedUserImplCopyWith<$Res>
    implements $SharedUserCopyWith<$Res> {
  factory _$$SharedUserImplCopyWith(
          _$SharedUserImpl value, $Res Function(_$SharedUserImpl) then) =
      __$$SharedUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String userId, String email, bool canEdit});
}

/// @nodoc
class __$$SharedUserImplCopyWithImpl<$Res>
    extends _$SharedUserCopyWithImpl<$Res, _$SharedUserImpl>
    implements _$$SharedUserImplCopyWith<$Res> {
  __$$SharedUserImplCopyWithImpl(
      _$SharedUserImpl _value, $Res Function(_$SharedUserImpl) _then)
      : super(_value, _then);

  /// Create a copy of SharedUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? email = null,
    Object? canEdit = null,
  }) {
    return _then(_$SharedUserImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      canEdit: null == canEdit
          ? _value.canEdit
          : canEdit // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SharedUserImpl implements _SharedUser {
  const _$SharedUserImpl(
      {required this.userId, required this.email, this.canEdit = false});

  factory _$SharedUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$SharedUserImplFromJson(json);

  @override
  final String userId;
  @override
  final String email;
  @override
  @JsonKey()
  final bool canEdit;

  @override
  String toString() {
    return 'SharedUser(userId: $userId, email: $email, canEdit: $canEdit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SharedUserImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.canEdit, canEdit) || other.canEdit == canEdit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, userId, email, canEdit);

  /// Create a copy of SharedUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SharedUserImplCopyWith<_$SharedUserImpl> get copyWith =>
      __$$SharedUserImplCopyWithImpl<_$SharedUserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SharedUserImplToJson(
      this,
    );
  }
}

abstract class _SharedUser implements SharedUser {
  const factory _SharedUser(
      {required final String userId,
      required final String email,
      final bool canEdit}) = _$SharedUserImpl;

  factory _SharedUser.fromJson(Map<String, dynamic> json) =
      _$SharedUserImpl.fromJson;

  @override
  String get userId;
  @override
  String get email;
  @override
  bool get canEdit;

  /// Create a copy of SharedUser
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SharedUserImplCopyWith<_$SharedUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
