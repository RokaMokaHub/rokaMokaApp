// SERVERS
import 'package:flutter/foundation.dart';

const String devServer = 'http://10.0.2.2:8080';
const String servidorRokaMoka = 'https://rokamoka.inf.ufpel.edu.br';
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
// GET ARTWORK BY QRCODE
String getArtworkByQrcodeEndpoint(String qrcode) =>
    '$activeserver/artwork/qrcode/$qrcode';
// COLLECT STAR (mokadex)
String collectStarEndpoint(String qrcode) =>
    '$activeserver/mokadex/collect/$qrcode';
// CREATE ARTWORK
String createArtworkEndpoint(String exhibitionId) =>
    '$activeserver/artwork/$exhibitionId';
// CREATE EXHIBITION
const String createExhibitionEndpoint = '$activeserver/exhibition';
// UPDATE EXHIBITION
const String updateExhibitionEndpoint = '$activeserver/exhibition';
// UPDATE ARTWORK
const String updateArtworkEndpoint = '$activeserver/artwork';
// LIST EXHIBITIONS
const String listExhibitionsEndpoint = '$activeserver/exhibition/all';
// GET EXHIBITION BY ID
String getExhibitionByIdEndpoint(String id) => '$activeserver/exhibition/$id';
// DELETE EXHIBITION
String deleteExhibitionEndpoint(String id) => '$activeserver/exhibition/$id';
// DELETE ARTWORK
String deleteArtworkEndpoint(String id) => '$activeserver/artwork/$id';
// LIST ARTWORKS BY EXHIBITION
String listArtworksByExhibitionEndpoint(String exhibitionId) =>
    '$activeserver/artwork/exposicao/$exhibitionId';
// GET MISSING ARTWORKS (mokadex)
String getMissingArtworksEndpoint(String exhibitionId) =>
    '$activeserver/mokadex/missing/$exhibitionId';
// LOCATIONS
const String listLocationsEndpoint = '$activeserver/location/all';
const String createLocationEndpoint = '$activeserver/location';
const String updateLocationEndpoint = '$activeserver/location';
const String deleteLocationEndpoint = '$activeserver/location';
// REQUEST ACCESS
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
Uri sendEmailForgotPasswordEndpoint(String email) => Uri.parse(
  '$activeserver/auth/forgot-password/send',
).replace(queryParameters: {'email': email});
// forgot password
const forgotPasswordEndpoint = '$activeserver/auth/forgot-password/reset';
// MOKADEX SUMMARY
const String mokadexSummaryEndpoint = '$activeserver/mokadex/summary';
// EMBLEM
const String createEmblemEndpoint = '$activeserver/emblem/create';

String getEmblemByIdEndpoint(String id) => '$activeserver/emblem/$id';

String deleteEmblemEndpoint(String id) => '$activeserver/emblem/$id';
