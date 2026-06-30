import 'package:flutter/material.dart';
import 'package:roka_moka_app/constants/auth_messages.dart';
import 'package:roka_moka_app/constants/routes.dart';
import 'package:roka_moka_app/domain/services/auth_service.dart';
import 'package:roka_moka_app/presentation/widgets/urgent_alert_dialog.dart';

/// Oferece re-login quando o servidor recusa uma ação privilegiada por
/// permissões defasadas (JWT com `scope` anterior à atualização de cargo).
///
/// Mostra o diálogo "Perfil atualizado" e, se o usuário confirmar, limpa a
/// sessão e navega para a tela de login para renovar o token com o `scope`
/// correto. Reutilizado pelas telas que executam ações privilegiadas
/// (cadastro e edição de exposição/obras).
Future<void> promptPermissionChangedReLogin(BuildContext context) async {
  final deveRelogar = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const UrgentAlertDialog(
      title: 'Perfil atualizado',
      content: permissionChangedMessage,
      confirmText: 'Fazer login',
      cancelText: 'Fechar',
      confirmTextColor: Colors.white,
    ),
  );

  if (deveRelogar != true || !context.mounted) return;

  await AuthService().clearAuthData();
  if (!context.mounted) return;

  Navigator.of(context, rootNavigator: true)
      .pushNamedAndRemoveUntil(connectRoute, (route) => false);
}
