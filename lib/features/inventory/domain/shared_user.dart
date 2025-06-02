import 'package:freezed_annotation/freezed_annotation.dart';

part 'shared_user.freezed.dart';
part 'shared_user.g.dart';

@freezed
class SharedUser with _$SharedUser {
  const factory SharedUser({
    required String userId,
    required String email,
    @Default(false) bool canEdit,
  }) = _SharedUser;

  factory SharedUser.fromJson(Map<String, dynamic> json) =>
      _$SharedUserFromJson(json);
}
