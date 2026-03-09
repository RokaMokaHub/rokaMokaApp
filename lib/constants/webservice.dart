// SERVERS
import 'package:flutter/foundation.dart';

const String devServer = 'http://10.0.2.2:8080';
const String servidorRokaMoka = 'http://rokamoka.inf.ufpel.edu.br';
const String activeserver = kReleaseMode ? servidorRokaMoka : devServer;

// LOGIN
const String loginEndpoint = '$activeserver/auth/login';
// RESET PASSWORD
const String resetPasswordEndpoint = '$activeserver/auth/reset-password';
// CREATE NORMAL USER
const String createUserEndpoint = '$activeserver/user/normal/create';
// CREATE ANON USER
const String createAnonUserEndpoint = '$activeserver/user/anonymous/create';
// RECUPERA INFORMAÇÕES DO USUÁRIO
const String getUserInfoEndpoint = '$activeserver/user/me';
// GET ARTWORK BY ID
String getArtworkByIdEndpoint(String artworkId) =>
    '$activeserver/artwork/$artworkId';
// CREATE ARTWORK
String createArtworkEndpoint(String exhibitionId) =>
    '$activeserver/artwork/$exhibitionId';
// CREATE EXHIBITION
const String createExhibitionEndpoint = '$activeserver/exhibition';
// LOCATIONS
const String listLocationsEndpoint = '$activeserver/location/all';
const String createLocationEndpoint = '$activeserver/location';
const String updateLocationEndpoint = '$activeserver/location';
// requests access as a researcher
const String requestAccessResearcherEndpoint =
    '$activeserver/request/permission/researcher';
// requests access as a curator
const String requestAccessCuratorEndpoint =
    '$activeserver/request/permission/curator';
// status request access
const statusRequestAccessEndpoint =
    '$activeserver/request/permission/me/status';
// lista de permissao para o admin
const listPermissionsEndPoint = '$activeserver/evaluation/permission/list';
// admin accept permission
String acceptPermissionEndpoint(int permissionId) =>
    '$activeserver/evaluation/permission/accept/$permissionId';
// admin reject permission
String rejectPermissionEndpoint(int permissionId) =>
    '$activeserver/evaluation/permission/deny/$permissionId';
// send email forgot password
String sendEmailForgotPasswordEndpoint(String email) =>
    '$activeserver/auth/forgot-password/send?email=$email';
// forgot password
const forgotPasswordEndpoint = '$activeserver/auth/forgot-password/reset';
