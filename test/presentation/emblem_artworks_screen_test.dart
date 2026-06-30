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
    // Nome da exposição aparece na testa laranja e no cartão de informações.
    expect(find.text('Exposição Teste'), findsNWidgets(2));
    expect(find.text('Uma exposição de teste'), findsOneWidget);
    expect(find.text('Museu de Pelotas'), findsOneWidget);
    expect(find.text('2 obras'), findsOneWidget);
    // Não deve existir botão de coletar estrela nesta tela somente-leitura.
    expect(find.text('Coletar Estrela'), findsNothing);

    // Obra B está abaixo da dobra (ListView lazy); rola até ela.
    await tester.scrollUntilVisible(find.text('Obra B'), 300);
    expect(find.text('Obra B'), findsOneWidget);
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
