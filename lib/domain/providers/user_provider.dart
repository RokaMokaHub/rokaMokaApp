import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UserRole { anon, comum, administrador, curador, pesquisador }

class UserProvider with ChangeNotifier {
  UserRole _role = UserRole.comum;

  UserRole get role => _role;

  Future<void> loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    final roleString = prefs.getString('user_role') ?? 'comum'; // padrão: anon
    _role = UserRole.values.firstWhere(
          (e) => e.name == roleString,
      orElse: () => UserRole.comum,
    );
    notifyListeners();
  }


  Future<void> setRole(UserRole role) async {
    _role = role;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', role.name);
    notifyListeners();
  }
}
