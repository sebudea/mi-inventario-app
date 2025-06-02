// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SharedUserImpl _$$SharedUserImplFromJson(Map<String, dynamic> json) =>
    _$SharedUserImpl(
      userId: json['userId'] as String,
      email: json['email'] as String,
      canEdit: json['canEdit'] as bool? ?? false,
    );

Map<String, dynamic> _$$SharedUserImplToJson(_$SharedUserImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'email': instance.email,
      'canEdit': instance.canEdit,
    };
