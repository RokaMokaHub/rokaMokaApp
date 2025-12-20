import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:roka_moka_app/domain/services/user_service.dart';
import 'dart:convert';
import 'auth_service.dart';
import 'package:roka_moka_app/constants/webservice.dart';

//Classe responsavel pelo login via banco do usuario
class LoginService {
  final AuthService _authService = AuthService();

  Future<void> login(String nome, String password) async {
    final deviceId = await getDeviceId();
    final url = Uri.parse(loginEndpoint);
    final credentials = base64Encode(utf8.encode('$nome:$password'));

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Basic $credentials',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['body']?['jwt'] != null) {
      final token = data['body']['jwt'];

      await _authService.saveAuthData(
        token: token,
        email: '',
        userName: nome,
        deviceId: deviceId,
        firstName: '',
        lastName: '',
        password: password
      );

      final userInfo = await UserService().getUserInfo();
      final firstName = userInfo['body']?['firstName'] ?? userInfo['firstName'] ?? nome;
      final lastName = userInfo['body']?['lastName'] ?? userInfo['lastName'] ?? '';
      final email = userInfo['body']?['email'] ?? userInfo['email'] ?? nome;


      // 🔹 Atualiza os dados salvos com os nomes corretos
      await _authService.saveAuthData(
        token: token,
        email: email,
        userName: nome,
        deviceId: deviceId,
        firstName: firstName,
        lastName: lastName,
        password: password
      );
    } else {
      final errorMessage = data['error'] ?? 'Erro ao fazer login.';
      throw errorMessage;
    }
  }

  Future<String> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id; // ou androidId
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? 'ios-unknown';
    }

    return 'unsupported-platform';
  }
}
