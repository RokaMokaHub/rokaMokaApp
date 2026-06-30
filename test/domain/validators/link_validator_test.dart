import 'package:flutter_test/flutter_test.dart';
import 'package:roka_moka_app/domain/validators/link_validator.dart';

void main() {
  group('LinkValidator - Regra 1: validação de e-mail', () {
    test('rejeita e-mail simples (contato@email.com)', () {
      final result = LinkValidator.validate('contato@email.com');

      expect(result.isValid, isFalse);
      expect(result.normalizedLink, isNull);
      expect(result.errorMessage, 'O campo aceita apenas links válidos.');
      expect(result.errorMessage, LinkValidator.invalidLinkMessage);
    });

    test('rejeita e-mail com subdomínio (nome.sobrenome@mail.empresa.com.br)', () {
      final result = LinkValidator.validate('nome.sobrenome@mail.empresa.com.br');

      expect(result.isValid, isFalse);
      expect(result.errorMessage, LinkValidator.invalidLinkMessage);
    });

    test('rejeita endereço com prefixo mailto:', () {
      final result = LinkValidator.validate('mailto:contato@email.com');

      expect(result.isValid, isFalse);
      expect(result.errorMessage, LinkValidator.invalidLinkMessage);
    });

    test('NÃO trata como e-mail uma URL com userinfo (https://user@site.com)', () {
      final result = LinkValidator.validate('https://user@site.com');

      expect(result.isValid, isTrue);
      expect(result.normalizedLink, 'https://user@site.com');
    });
  });

  group('LinkValidator - Regra 2: tratamento de protocolos', () {
    test('http://site.com -> http://site.com (mantém http)', () {
      final result = LinkValidator.validate('http://site.com');

      expect(result.isValid, isTrue);
      expect(result.normalizedLink, 'http://site.com');
    });

    test('https://site.com -> https://site.com (mantém https)', () {
      final result = LinkValidator.validate('https://site.com');

      expect(result.isValid, isTrue);
      expect(result.normalizedLink, 'https://site.com');
    });

    test('site.com -> https://site.com (adiciona https quando ausente)', () {
      final result = LinkValidator.validate('site.com');

      expect(result.isValid, isTrue);
      expect(result.normalizedLink, 'https://site.com');
    });
  });

  group('LinkValidator - Regra 3: tratamento de prefixos', () {
    test('https://www.site.com -> mantém intacto', () {
      final result = LinkValidator.validate('https://www.site.com');

      expect(result.isValid, isTrue);
      expect(result.normalizedLink, 'https://www.site.com');
    });

    test('www.site.com -> https://www.site.com (adiciona https mantendo www)', () {
      final result = LinkValidator.validate('www.site.com');

      expect(result.isValid, isTrue);
      expect(result.normalizedLink, 'https://www.site.com');
    });

    test('https://http://site.com -> http://site.com (corrige protocolo empilhado)', () {
      final result = LinkValidator.validate('https://http://site.com');

      expect(result.isValid, isTrue);
      expect(result.normalizedLink, 'http://site.com');
    });

    test('https://https://site.com -> https://site.com (remove duplicidade)', () {
      final result = LinkValidator.validate('https://https://site.com');

      expect(result.isValid, isTrue);
      expect(result.normalizedLink, 'https://site.com');
    });

    test('https://www.www.site.com -> https://www.site.com (colapsa www repetido)', () {
      final result = LinkValidator.validate('https://www.www.site.com');

      expect(result.isValid, isTrue);
      expect(result.normalizedLink, 'https://www.site.com');
    });
  });

  group('LinkValidator - casos de robustez (entrada do usuário)', () {
    test('aplica trim em espaços ao redor antes de normalizar', () {
      final result = LinkValidator.validate('   site.com   ');

      expect(result.isValid, isTrue);
      expect(result.normalizedLink, 'https://site.com');
    });

    test('normaliza esquema em maiúsculas (HTTP://Site.com)', () {
      final result = LinkValidator.validate('HTTP://Site.com');

      expect(result.isValid, isTrue);
      expect(result.normalizedLink, 'http://Site.com');
    });

    test('preserva caminho e query string', () {
      final result = LinkValidator.validate('www.site.com/obra?id=10');

      expect(result.isValid, isTrue);
      expect(result.normalizedLink, 'https://www.site.com/obra?id=10');
    });

    test('combinação extrema: https://https://www.www.site.com', () {
      final result = LinkValidator.validate('https://https://www.www.site.com');

      expect(result.isValid, isTrue);
      expect(result.normalizedLink, 'https://www.site.com');
    });

    test('campo vazio é válido e retorna link vazio (campo opcional)', () {
      final result = LinkValidator.validate('');

      expect(result.isValid, isTrue);
      expect(result.normalizedLink, '');
    });

    test('apenas espaços é tratado como vazio (válido, link vazio)', () {
      final result = LinkValidator.validate('     ');

      expect(result.isValid, isTrue);
      expect(result.normalizedLink, '');
    });

    test('null é válido e retorna link vazio', () {
      final result = LinkValidator.validate(null);

      expect(result.isValid, isTrue);
      expect(result.normalizedLink, '');
    });

    test('rejeita texto sem ponto/host (ex.: "obra qualquer")', () {
      final result = LinkValidator.validate('obra qualquer');

      expect(result.isValid, isFalse);
      expect(result.errorMessage, LinkValidator.invalidLinkMessage);
    });

    test('rejeita palavra única sem domínio (ex.: "site")', () {
      final result = LinkValidator.validate('site');

      expect(result.isValid, isFalse);
      expect(result.errorMessage, LinkValidator.invalidLinkMessage);
    });

    test('rejeita host com rótulo vazio (ex.: "site..com")', () {
      final result = LinkValidator.validate('site..com');

      expect(result.isValid, isFalse);
      expect(result.errorMessage, LinkValidator.invalidLinkMessage);
    });
  });

  group('LinkValidator.normalizeOrNull - atalho de conveniência', () {
    test('retorna a URL normalizada para entrada válida', () {
      expect(LinkValidator.normalizeOrNull('site.com'), 'https://site.com');
      expect(
        LinkValidator.normalizeOrNull('https://http://site.com'),
        'http://site.com',
      );
    });

    test('retorna null para e-mail (entrada inválida)', () {
      expect(LinkValidator.normalizeOrNull('contato@email.com'), isNull);
    });

    test('retorna string vazia para entrada vazia', () {
      expect(LinkValidator.normalizeOrNull(''), '');
    });
  });
}
