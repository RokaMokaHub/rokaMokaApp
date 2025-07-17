// SERVERS
const String devServer = 'http://10.0.2.2:8080';

// LOGIN
const String loginEndpoint = '$devServer/user/login';
// RESET PASSWORD
const String resetPasswordEndpoint = '$devServer/user/reset-password';
// CREATE NORMAL USER
const String createUserEndpoint = '$devServer/user/normal/create';
// CREATE ANON USER
const String createAnonUserEndpoint = '$devServer/user/anonymous/create';
// RECUPERA INFORMAÇÕES DO USUÁRIO
const String getUserInfoEndpoint = '$devServer/user/me';
// GET ARTWORK BY ID
String getArtworkByIdEndpoint(String artworkId) => '$devServer/artwork/$artworkId';
// CREATE ARTWORK
String createArtworkEndpoint(String exhibitionId) => '$devServer/artwork/$exhibitionId';
// CREATE EXHIBITION
const String createExhibitionEndpoint = '$devServer/exhibition';

