import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

//Classe usada para setar a role do usuario ao entrar no app
enum UserRole { anon, comum, administrador, curador, pesquisador }

class UserProvider with ChangeNotifier {
  UserRole _role = UserRole.comum;

  UserRole get role => _role;

  Future<void> loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    final roleString = prefs.getString('user_role') ?? 'comum'; // padrão: anon
    _role = _parseRole(roleString);
    notifyListeners();
  }

  Future<void> setRole(UserRole role) async {
    _role = role;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', role.name);
    notifyListeners();
  }

  Future<void> setRoleByName(String roleName) async {
    await setRole(_parseRole(roleName));
  }

  UserRole _parseRole(String roleName) {
    final normalizedRole = roleName.trim().toLowerCase();
    return UserRole.values.firstWhere(
      (e) => e.name.toLowerCase() == normalizedRole,
      orElse: () => UserRole.comum,
    );
  }
}
