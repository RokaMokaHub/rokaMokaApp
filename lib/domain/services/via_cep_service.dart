import 'dart:convert';

import 'package:http/http.dart' as http;

class ViaCepAddress {
  final String logradouro;
  final String bairro;
  final String localidade;
  final String uf;

  ViaCepAddress({
    required this.logradouro,
    required this.bairro,
    required this.localidade,
    required this.uf,
  });

  factory ViaCepAddress.fromJson(Map<String, dynamic> json) {
    return ViaCepAddress(
      logradouro: json['logradouro'] as String? ?? '',
      bairro: json['bairro'] as String? ?? '',
      localidade: json['localidade'] as String? ?? '',
      uf: json['uf'] as String? ?? '',
    );
  }
}

class ViaCepService {
  final http.Client _client;

  ViaCepService({http.Client? client}) : _client = client ?? http.Client();

  Future<ViaCepAddress> fetchAddress(String cep) async {
    final digits = cep.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 8) {
      throw Exception('CEP inválido: deve conter exatamente 8 dígitos.');
    }

    final uri = Uri.parse('https://viacep.com.br/ws/$digits/json/');
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('CEP inválido ou serviço indisponível.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['erro'] == true || data['erro'] == 'true') {
      throw Exception('CEP não encontrado.');
    }

    return ViaCepAddress.fromJson(data);
  }
}
