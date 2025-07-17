// SERVERS
import 'package:flutter/foundation.dart';

const String devServer = 'http://10.0.2.2:8080';
const String servidorRokaMoka = 'http://rokamoka.inf.ufpel.edu.br';
const String activeserver = servidorRokaMoka;

// LOGIN
const String loginEndpoint = '$activeserver/user/login';
// RESET PASSWORD
const String resetPasswordEndpoint = '$activeserver/user/reset-password';
// CREATE NORMAL USER
const String createUserEndpoint = '$activeserver/user/normal/create';
// CREATE ANON USER
const String createAnonUserEndpoint = '$activeserver/user/anonymous/create';
// RECUPERA INFORMAÇÕES DO USUÁRIO
const String getUserInfoEndpoint = '$activeserver/user/me';
// GET ARTWORK BY ID
String getArtworkByIdEndpoint(String artworkId) => '$activeserver/artwork/$artworkId';
// CREATE ARTWORK
String createArtworkEndpoint(String exhibitionId) => '$activeserver/artwork/$exhibitionId';
// CREATE EXHIBITION
const String createExhibitionEndpoint = '$activeserver/exhibition';
