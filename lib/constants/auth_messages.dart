// Mensagens de autenticação/autorização compartilhadas.

/// Exibida quando o servidor recusa uma ação privilegiada com 403 porque o JWT
/// ainda carrega um `scope` anterior à atualização do perfil do usuário. Como a
/// senha não é persistida, a única forma de renovar o token é fazer login de novo.
const String permissionChangedMessage =
    'Suas permissões mudaram. Faça login novamente para concluir esta ação.';
