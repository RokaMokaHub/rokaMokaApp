/// Resultado da validação/normalização de um link.
///
/// Quando [isValid] for `true`, [normalizedLink] conterá a URL já tratada
/// (pronta para persistir/abrir). Quando for `false`, [errorMessage] conterá
/// a mensagem a ser exibida no campo.
class LinkValidationResult {
  final bool isValid;
  final String? normalizedLink;
  final String? errorMessage;

  const LinkValidationResult._({
    required this.isValid,
    this.normalizedLink,
    this.errorMessage,
  });

  factory LinkValidationResult.valid(String link) =>
      LinkValidationResult._(isValid: true, normalizedLink: link);

  factory LinkValidationResult.invalid(String message) =>
      LinkValidationResult._(isValid: false, errorMessage: message);
}

/// Valida e normaliza o campo "Link da obra".
///
/// Regras de negócio cobertas:
///  - Regra 1: e-mails (puros ou `mailto:`) não são links aceitos.
///  - Regra 2: garante o protocolo, adicionando `https://` apenas quando ausente.
///  - Regra 3: corrige formatos duplicados/empilhados como `https://http://`,
///    `https://https://` e `https://www.www.`, e mantém URLs já corretas intactas.
class LinkValidator {
  LinkValidator._();

  /// Mensagem única usada para qualquer entrada que não seja um link válido.
  static const String invalidLinkMessage = 'O campo aceita apenas links válidos.';

  /// E-mail "puro": algo@algo.algo, sem espaços e sem protocolo.
  static final RegExp _emailRegExp = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  /// Esquema http/https no início da string (case-insensitive).
  static final RegExp _schemeRegExp =
      RegExp(r'^(https?):\/\/', caseSensitive: false);

  /// Uma ou mais ocorrências de "www." no início (case-insensitive).
  static final RegExp _wwwRegExp = RegExp(r'^(www\.)+', caseSensitive: false);

  /// Valida [rawInput] e retorna o resultado com a URL normalizada ou a
  /// mensagem de erro.
  ///
  /// Campo opcional: entrada vazia (ou só espaços) é considerada válida e
  /// retorna uma string vazia como link normalizado.
  static LinkValidationResult validate(String? rawInput) {
    final input = rawInput?.trim() ?? '';

    if (input.isEmpty) {
      return LinkValidationResult.valid('');
    }

    // Regra 1 — e-mail não é um link aceito.
    if (_isEmail(input)) {
      return LinkValidationResult.invalid(invalidLinkMessage);
    }

    final normalized = _normalize(input);

    // Robustez: se mesmo após o tratamento não for uma URL estruturalmente
    // válida (sem host, sem ponto, com espaços), trata como inválido.
    if (!_isStructurallyValid(normalized)) {
      return LinkValidationResult.invalid(invalidLinkMessage);
    }

    return LinkValidationResult.valid(normalized);
  }

  /// Conveniência para uso direto: retorna a URL normalizada, ou `null` se a
  /// entrada for inválida. Entrada vazia retorna `''`.
  static String? normalizeOrNull(String? rawInput) {
    final result = validate(rawInput);
    return result.isValid ? result.normalizedLink : null;
  }

  static bool _isEmail(String input) {
    if (input.toLowerCase().startsWith('mailto:')) return true;
    // Só consideramos e-mail quando NÃO há esquema (http/https). Isso evita
    // tratar URLs com userinfo (ex.: https://user@site.com) como e-mail.
    if (_schemeRegExp.hasMatch(input)) return false;
    return _emailRegExp.hasMatch(input);
  }

  static String _normalize(String input) {
    var rest = input;
    // Regra 2: padrão é https quando nenhum protocolo é informado.
    var scheme = 'https';

    // Regra 3: remove esquemas empilhados (ex.: https://http://...), mantendo
    // o esquema MAIS INTERNO — o mais próximo do host — que é o pretendido.
    var match = _schemeRegExp.firstMatch(rest);
    while (match != null) {
      scheme = match.group(1)!.toLowerCase();
      rest = rest.substring(match.end);
      match = _schemeRegExp.firstMatch(rest);
    }

    // Regra 3: colapsa "www." repetidos no início (www.www. -> www.).
    // Se não houver "www." no início, o regex não casa e nada muda.
    rest = rest.replaceFirst(_wwwRegExp, 'www.');

    return '$scheme://$rest';
  }

  static bool _isStructurallyValid(String url) {
    if (url.contains(' ')) return false;

    final uri = Uri.tryParse(url);
    if (uri == null) return false;

    final host = uri.host;
    if (host.isEmpty || !host.contains('.')) return false;

    // Rejeita hosts com rótulos vazios (ex.: "site..com" ou ".com").
    if (host.split('.').any((label) => label.isEmpty)) return false;

    return true;
  }
}
