import 'package:flutter/foundation.dart';
import 'package:mi_inventario/data/services/user_firestore_service.dart';
import 'package:mi_inventario/domain/user/user_model.dart';

class UserRepository {
  final UserFirestoreService _userFirestoreService;
  UserRepository(this._userFirestoreService);

  Future<bool> createUser(UserModel user) async {
    bool result = false;
    try {
      final Map<String, dynamic> userData = user.toJson();
      final String userId = user.id;

      result = await _userFirestoreService.createUser(userData, userId);
      if (result) {
        debugPrint("Usuario creado exitosamente: $userData");
      } else {
        debugPrint("Error al crear usuario: $userData");
      }
    } catch (e) {
      debugPrint("Error al crear usuario: $e");
    }
    return result;
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      final Map<String, dynamic>? userData =
          await _userFirestoreService.getUser(userId);

      if (userData != null) {
        UserModel user = UserModel.fromJson(userData);
        debugPrint("Usuario obtenido exitosamente: ${user.toJson()}");
        return user;
      } else {
        debugPrint("Usuario no encontrado para el ID: $userId");
      }
    } catch (e) {
      debugPrint("Error al obtener usuario: $e");
    }
    return null;
  }

  Future<bool> updateUser(UserModel user) async {
    bool result = false;
    try {
      final Map<String, dynamic> userData = user.toJson();
      final String userId = user.id;

      result = await _userFirestoreService.updateUser(userData, userId);
      if (result) {
        debugPrint("Usuario actualizado exitosamente: $userData");
      } else {
        debugPrint("Error al actualizar usuario: $userData");
      }
    } catch (e) {
      debugPrint("Error al actualizar usuario: $e");
    }
    return result;
  }

  Future<bool> deleteUser(String userId) async {
    bool result = false;
    try {
      result = await _userFirestoreService.deleteUser(userId);
      if (result) {
        debugPrint("Usuario eliminado exitosamente con ID: $userId");
      } else {
        debugPrint("Error al eliminar usuario con ID: $userId");
      }
    } catch (e) {
      debugPrint("Error al eliminar usuario: $e");
    }
    return result;
  }
}
