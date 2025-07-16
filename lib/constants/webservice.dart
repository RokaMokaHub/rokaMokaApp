// SERVERS
const String devServer = 'http://192.168.1.111:8080';
// LOGIN
const String loginEndpoint = '$devServer/user/login';
// RESET PASSWORD
const String resetPasswordEndpoint = '$devServer/user/reset-password';
// CREATE NORMAL USER
const String createUserEndpoint = '$devServer/user/normal/create';
// CREATE ANON USER
const String createAnonUserEndpoint = '$devServer/user/anonymous/create';

// GET ARTWORK BY ID (gera a URL)
String getArtworkByIdEndpoint(String artworkId) => '$devServer/artwork/$artworkId';


