import 'package:freezed_annotation/freezed_annotation.dart';

part 'shared_user.freezed.dart';
part 'shared_user.g.dart';

@freezed
class SharedUser with _$SharedUser {
  const factory SharedUser({
    required String userId, // ID del usuario compartido
    required bool canAddItems, // true: puede agregar items, false: solo ver
  }) = _SharedUser;

  factory SharedUser.fromJson(Map<String, dynamic> json) =>
      _$SharedUserFromJson(json);
}
