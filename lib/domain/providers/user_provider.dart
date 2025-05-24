import 'package:flutter/material.dart';

enum UserRole { comum, administrador, curador, pesquisador }

class UserProvider with ChangeNotifier {
  UserRole _role = UserRole.comum;

  UserRole get role => _role;

  void setRole(UserRole role) {
    _role = role;
    notifyListeners();
  }
}
