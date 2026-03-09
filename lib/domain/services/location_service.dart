import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:roka_moka_app/constants/webservice.dart';

import 'auth_service.dart';

class Location {
  final String id;
  final String name;
  final String street;
  final String number;
  final String zipCode;
  final String complement;

  const Location({
    required this.id,
    required this.name,
    required this.street,
    required this.number,
    required this.zipCode,
    required this.complement,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    final endereco =
        (json['endereco'] as Map<String, dynamic>?) ??
        (json['enderecoDTO'] as Map<String, dynamic>?) ??
        (json['address'] as Map<String, dynamic>?) ??
        <String, dynamic>{};

    return Location(
      id: '${json['id'] ?? json['locationId'] ?? ''}',
      name: '${json['name'] ?? json['nome'] ?? ''}',
      street: '${endereco['rua'] ?? endereco['street'] ?? json['rua'] ?? ''}',
      number:
          '${endereco['numero'] ?? endereco['number'] ?? json['numero'] ?? ''}',
      zipCode: '${endereco['cep'] ?? endereco['zipCode'] ?? json['cep'] ?? ''}',
      complement:
          '${endereco['complemento'] ?? endereco['complement'] ?? json['complemento'] ?? ''}',
    );
  }
}

class LocationPayload {
  final String name;
  final String street;
  final String number;
  final String zipCode;
  final String complement;

  const LocationPayload({
    required this.name,
    required this.street,
    required this.number,
    required this.zipCode,
    this.complement = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'nome': name,
      'endereco': {'rua': street, 'numero': number, 'cep': zipCode},
    };
  }

  Map<String, dynamic> toUpdateJson(String id) {
    return {
      'id': id,
      'nome': name,
      'endereco': {
        'rua': street,
        'numero': number,
        'cep': zipCode,
        'complemento': complement,
      },
    };
  }
}

class LocationService {
  final AuthService _authService;
  final http.Client _client;

  LocationService({AuthService? authService, http.Client? client})
    : _authService = authService ?? AuthService(),
      _client = client ?? http.Client();

  Future<List<Location>> listLocations() async {
    final response = await _authorizedGet(Uri.parse(listLocationsEndpoint));
    final body = _decodeResponse(response);
    final rawList = body['body'];

    if (rawList is! List) {
      throw Exception('Resposta inválida ao listar locais.');
    }

    return rawList
        .whereType<Map<String, dynamic>>()
        .map(Location.fromJson)
        .toList();
  }

  Future<Location> createLocation(LocationPayload payload) async {
    final response = await _authorizedWrite(
      Uri.parse(createLocationEndpoint),
      payload.toJson(),
      method: 'POST',
    );

    final body = _decodeResponse(response);
    final rawLocation = body['body'];

    if (rawLocation is! Map<String, dynamic>) {
      throw Exception('Resposta inválida ao criar local.');
    }

    return Location.fromJson(rawLocation);
  }

  Future<Location> updateLocation(String id, LocationPayload payload) async {
    final response = await _authorizedWrite(
      Uri.parse(updateLocationEndpoint),
      payload.toUpdateJson(id),
      method: 'PATCH',
    );

    final body = _decodeResponse(response);
    final rawLocation = body['body'];

    if (rawLocation is! Map<String, dynamic>) {
      throw Exception('Resposta inválida ao editar local.');
    }

    return Location.fromJson(rawLocation);
  }

  Future<http.Response> _authorizedGet(Uri uri) async {
    final token = await _authService.getToken();
    return _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
  }

  Future<http.Response> _authorizedWrite(
    Uri uri,
    Map<String, dynamic> body, {
    required String method,
  }) async {
    final token = await _authService.getToken();
    final headers = {
      'Content-Type': 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token',
    };
    final encodedBody = jsonEncode(body);

    switch (method) {
      case 'POST':
        return _client.post(uri, headers: headers, body: encodedBody);
      case 'PATCH':
        return _client.patch(uri, headers: headers, body: encodedBody);
      default:
        throw ArgumentError('Método HTTP não suportado: $method');
    }
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    final dynamic data =
        response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (data is Map<String, dynamic>) {
        return data;
      }
      throw Exception('Resposta inválida da API.');
    }

    if (data is Map<String, dynamic>) {
      throw Exception(
        data['error'] ?? data['exceptionMessage'] ?? 'Erro ao processar local.',
      );
    }

    throw Exception('Erro ao processar local.');
  }
}
