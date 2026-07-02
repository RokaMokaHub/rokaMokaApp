import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roka_moka_app/domain/services/emblem_service.dart';
import 'package:roka_moka_app/presentation/pages/emblem_artworks_screen.dart';

/// Fake do [EmblemService] para controlar a resposta de [getEmblemById] nos testes.
class _FakeEmblemService extends EmblemService {
  final Future<Map<String, dynamic>> Function(int id) onGetEmblemById;

  _FakeEmblemService(this.onGetEmblemById);

  @override
  Future<Map<String, dynamic>> getEmblemById(int id) => onGetEmblemById(id);
}

void main() {
  Widget wrap(EmblemService service) => MaterialApp(
    home: EmblemArtworksScreen(emblemId: 1, emblemService: service),
  );

  testWidgets('mostra indicador de carregamento enquanto busca o emblema', (
    tester,
  ) async {
    final completer = Completer<Map<String, dynamic>>();
    final service = _FakeEmblemService((_) => completer.future);

    await tester.pumpWidget(wrap(service));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete({'nome': 'Emblema', 'artworks': []});
    await tester.pumpAndSettle();
  });

  testWidgets('Cenário 1: lista as obras quando o usuário possui o emblema', (
    tester,
  ) async {
    final service = _FakeEmblemService(
      (_) async => {
        'id': 1,
        'nome': 'Emblema Teste',
        'descricao': 'Descrição do emblema',
        'exhibition': {
          'name': 'Exposição Teste',
          'description': 'Uma exposição de teste',
          'location': 'Museu de Pelotas',
          'numberOfArtworks': 2,
        },
        'artworks': [
          {
            'nome': 'Obra A',
            'nomeArtista': 'Artista A',
            'descricao': 'Detalhes da obra A',
            'image': '',
            'link': '',
          },
          {
            'nome': 'Obra B',
            'nomeArtista': 'Artista B',
            'descricao': '',
            'image': '',
            'link': '',
          },
        ],
      },
    );

    await tester.pumpWidget(wrap(service));
    await tester.pumpAndSettle();

    expect(find.text('Obra A'), findsOneWidget);
    expect(find.text('Artista A'), findsOneWidget);
    // Nome da exposição só aparece no cabeçalho laranja; o card de info fica no modal.
    expect(find.text('Exposição Teste'), findsOneWidget);
    // Detalhes da exposição estão ocultos até abrir o modal.
    expect(find.text('Uma exposição de teste'), findsNothing);
    expect(find.text('Museu de Pelotas'), findsNothing);
    // Indicador de posição do carrossel.
    expect(find.text('1 de 2'), findsOneWidget);
    // Não deve existir botão de coletar estrela nesta tela somente-leitura.
    expect(find.text('Coletar Estrela'), findsNothing);

    // Abre o modal de informações e verifica os detalhes da exposição.
    await tester.tap(find.text('Informações da exposição'));
    await tester.pumpAndSettle();
    expect(find.text('Uma exposição de teste'), findsOneWidget);
    expect(find.text('Museu de Pelotas'), findsOneWidget);
    expect(find.text('2 obras'), findsOneWidget);
    await tester.tapAt(const Offset(400, 100)); // fecha o modal
    await tester.pumpAndSettle();

    // Obra B está na próxima página do carrossel; desliza horizontalmente.
    await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('Obra B'), findsOneWidget);
    expect(find.text('2 de 2'), findsOneWidget);
  });

  testWidgets(
    'Cenário 2: bloqueia a visualização quando o backend retorna 403',
    (tester) async {
      final service = _FakeEmblemService(
        (_) async =>
            throw EmblemForbiddenException(
              'Usuário não possui o emblema solicitado',
            ),
      );

      await tester.pumpWidget(wrap(service));
      await tester.pumpAndSettle();

      expect(find.text('Obras bloqueadas'), findsOneWidget);
      expect(
        find.text('Usuário não possui o emblema solicitado'),
        findsOneWidget,
      );
    },
  );
}
