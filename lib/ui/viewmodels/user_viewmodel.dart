import 'package:flutter/material.dart';
import 'package:mi_inventario/data/repositories/user_repository.dart';
import '../../domain/user/user_model.dart';

class UserViewModel extends ChangeNotifier {
  UserViewModel(this._userRepository);

  final UserRepository _userRepository;

  UserModel? _userModel;

  bool _loading = false;
  String? _errorMessage;

  String get userId => _userModel?.id ?? '';
  String get userName => _userModel?.name ?? '';
  String get userEmail => _userModel?.email ?? '';
  List<String> get ownedInventories => _userModel?.ownedInventories ?? [];

  bool get loading => _loading;
  String? get errorMessage => _errorMessage;

  // Carga el usuario y sus datos relacionados (por ejemplo, inventarios)
  Future<void> loadUser(UserModel user) async {
    _loading = true;
    notifyListeners();
    try {
      await Future.delayed(const Duration(seconds: 1));
      UserModel? userloaded = await _userRepository.getUser(user.id);

      if (userloaded != null) {
        _userModel = userloaded;
        _errorMessage = null;
      } else {
        await _userRepository.createUser(
          UserModel(id: user.id, name: user.name, email: user.email),
        );
        _userModel = user;
      }
      // Aquí podrías cargar inventarios propios y compartidos en el futuro
    } catch (e) {
      _errorMessage = 'Error al cargar usuario';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Limpia el usuario (por ejemplo, al hacer logout)
  void clearUser() {
    _userModel = null;
    notifyListeners();
  }

  // Agrega un ID de inventario propio al usuario actual
  Future<void> addOwnedInventory(String inventoryId) async {
    if (_userModel != null &&
        !_userModel!.ownedInventories.contains(inventoryId)) {
      _userModel = _userModel!.copyWith(
        ownedInventories: [..._userModel!.ownedInventories, inventoryId],
      );
      notifyListeners();
      try {
        await _userRepository.updateUser(_userModel!);
      } catch (e) {
        // Maneja el error si falla la actualización remota
        debugPrint('Error al actualizar usuario en Firestore: $e');
      }
    }
  }

  // Elimina un ID de inventario propio del usuario actual
  Future<void> removeOwnedInventory(String inventoryId) async {
    if (_userModel != null &&
        _userModel!.ownedInventories.contains(inventoryId)) {
      _userModel = _userModel!.copyWith(
        ownedInventories: _userModel!.ownedInventories
            .where((id) => id != inventoryId)
            .toList(),
      );
      notifyListeners();
      try {
        await _userRepository.updateUser(_userModel!);
      } catch (e) {
        debugPrint('Error al actualizar usuario en Firestore: $e');
      }
    }
  }
}
