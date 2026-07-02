import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:roka_moka_app/constants/colors.dart';
import 'package:roka_moka_app/domain/services/emblem_service.dart';

/// Tela somente-leitura que lista todas as obras de uma exposição cujo emblema
/// já foi conquistado pelo usuário. O acesso é garantido pelo backend
/// (`GET /emblems/{id}` retorna 403 se o usuário não possui o emblema).
class EmblemArtworksScreen extends StatefulWidget {
  final int emblemId;
  final String? emblemNome;

  /// Opcional para facilitar testes; em produção usa o [EmblemService] padrão.
  final EmblemService? emblemService;

  const EmblemArtworksScreen({
    super.key,
    required this.emblemId,
    this.emblemNome,
    this.emblemService,
  });

  @override
  State<EmblemArtworksScreen> createState() => _EmblemArtworksScreenState();
}

class _EmblemArtworksScreenState extends State<EmblemArtworksScreen> {
  late final EmblemService _emblemService =
      widget.emblemService ?? EmblemService();

  Map<String, dynamic>? _emblema;
  bool _isLoading = true;
  bool _isForbidden = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEmblema();
  }

  Future<void> _loadEmblema() async {
    setState(() {
      _isLoading = true;
      _isForbidden = false;
      _errorMessage = null;
    });

    try {
      final emblema = await _emblemService.getEmblemById(widget.emblemId);
      if (mounted) {
        setState(() {
          _emblema = emblema;
          _isLoading = false;
        });
      }
    } on EmblemForbiddenException catch (e) {
      if (mounted) {
        setState(() {
          _isForbidden = true;
          _errorMessage = e.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _Header(
            titulo: _exhibitionName ?? widget.emblemNome ?? 'Obras',
            onBack: () => Navigator.pop(context),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  String? get _exhibitionName {
    final exhibition = _emblema?['exhibition'];
    if (exhibition is Map) {
      final name = exhibition['name'] as String?;
      if (name != null && name.isNotEmpty) return name;
    }
    return null;
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isForbidden) {
      return _buildMessageState(
        icon: Icons.lock_outline,
        titulo: 'Obras bloqueadas',
        mensagem:
            _errorMessage ??
            'Você ainda não conquistou este emblema. Colete todas as obras da '
                'exposição para liberar a visualização.',
      );
    }

    if (_errorMessage != null) {
      return _buildMessageState(
        icon: Icons.error_outline,
        titulo: 'Erro ao carregar obras',
        mensagem: _errorMessage!,
        onRetry: _loadEmblema,
      );
    }

    final artworks = _emblema?['artworks'];
    final List<Map<String, dynamic>> obras = [];
    if (artworks is List) {
      for (final a in artworks) {
        if (a is Map<String, dynamic>) obras.add(a);
      }
    }

    if (obras.isEmpty) {
      return _buildMessageState(
        icon: Icons.collections_outlined,
        titulo: 'Nenhuma obra encontrada',
        mensagem: 'Esta exposição ainda não possui obras cadastradas.',
      );
    }

    final exhibition = _emblema?['exhibition'];
    final Map<String, dynamic>? exposicao =
        exhibition is Map<String, dynamic> ? exhibition : null;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: _ExhibitionHeader(
            exposicao: exposicao,
            quantidadeObras: obras.length,
            emblemDescricao: (_emblema?['descricao'] as String?) ?? '',
          ),
        ),
        const SizedBox(height: 10),
        Expanded(child: _ArtworkCarousel(obras: obras)),
      ],
    );
  }

  Widget _buildMessageState({
    required IconData icon,
    required String titulo,
    required String mensagem,
    VoidCallback? onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Color(greySubtitleColor)),
            const SizedBox(height: 16),
            Text(
              titulo,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(titleColor),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              mensagem,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Color(greySubtitleColor),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: onRetry,
                child: const Text('Tentar novamente'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String titulo;
  final VoidCallback onBack;

  const _Header({required this.titulo, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(primaryColorGradient), Color(secondaryColorGradient)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: EdgeInsets.only(top: topPadding + 4, bottom: 12, right: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
            onPressed: onBack,
          ),
          const Icon(Icons.museum, color: Colors.white, size: 26),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              titulo,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Cabeçalho com as informações da exposição, exibido acima da lista de obras.
class _ExhibitionHeader extends StatelessWidget {
  final Map<String, dynamic>? exposicao;
  final int quantidadeObras;
  final String emblemDescricao;

  const _ExhibitionHeader({
    required this.exposicao,
    required this.quantidadeObras,
    required this.emblemDescricao,
  });

  @override
  Widget build(BuildContext context) {
    final String nome = (exposicao?['name'] as String?) ?? '';
    final String descricao = (exposicao?['description'] as String?) ?? '';
    final String local = (exposicao?['location'] as String?) ?? '';
    // Usa a contagem real das obras carregadas; o campo `numberOfArtworks`
    // do backend pode vir desatualizado (0).
    final int? quantidade = quantidadeObras > 0 ? quantidadeObras : null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3EE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x33E94C19)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.museum_outlined,
                size: 18,
                color: Color(primaryColor),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  nome.isNotEmpty ? nome : 'Exposição',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(titleColor),
                  ),
                ),
              ),
            ],
          ),
          if (descricao.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              descricao,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ],
          if (local.isNotEmpty) ...[
            const SizedBox(height: 6),
            _InfoLine(icon: Icons.place_outlined, texto: local),
          ],
          if (quantidade != null) ...[
            const SizedBox(height: 4),
            _InfoLine(
              icon: Icons.collections_outlined,
              texto: '$quantidade ${quantidade == 1 ? 'obra' : 'obras'}',
            ),
          ],
          if (emblemDescricao.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            _InfoLine(
              icon: Icons.emoji_events_outlined,
              texto: emblemDescricao,
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String texto;

  const _InfoLine({required this.icon, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Color(greySubtitleColor)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            texto,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Color(greySubtitleColor),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

/// Carrossel horizontal das obras: o usuário desliza para o lado, sem precisar
/// rolar a página verticalmente.
class _ArtworkCarousel extends StatefulWidget {
  final List<Map<String, dynamic>> obras;

  const _ArtworkCarousel({required this.obras});

  @override
  State<_ArtworkCarousel> createState() => _ArtworkCarouselState();
}

class _ArtworkCarouselState extends State<_ArtworkCarousel> {
  late final int _total = widget.obras.length;
  // Com mais de uma obra, iniciamos numa página bem no meio de um intervalo
  // "virtual" grande para permitir rolar infinitamente nos dois sentidos.
  late final int _initialPage = _total > 1 ? _total * 1000 : 0;
  late final PageController _controller = PageController(
    viewportFraction: 0.88,
    initialPage: _initialPage,
  );
  late int _current = _initialPage;

  int get _realIndex => _total == 0 ? 0 : _current % _total;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _controller,
            // itemCount nulo => carrossel infinito (loop) quando há >1 obra.
            itemCount: _total > 1 ? null : 1,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder:
                (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  child: _ArtworkCard(artwork: widget.obras[index % _total]),
                ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '${_realIndex + 1} de $_total',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(greySubtitleColor),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 6,
          runSpacing: 6,
          children: List.generate(_total, (i) {
            final active = i == _realIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: active ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color:
                    active
                        ? Color(secondaryColorGradient)
                        : const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

/// Card somente-leitura de uma obra (sem ações de coletar/editar).
/// Preenche a altura disponível na página do carrossel.
class _ArtworkCard extends StatelessWidget {
  final Map<String, dynamic> artwork;

  const _ArtworkCard({required this.artwork});

  @override
  Widget build(BuildContext context) {
    final String nome = (artwork['nome'] as String?) ?? 'Sem título';
    final String autor = (artwork['nomeArtista'] as String?) ?? 'Desconhecido';
    final String descricao = (artwork['descricao'] as String?) ?? '';
    final String image = (artwork['image'] as String?) ?? '';
    final String link = (artwork['link'] as String?) ?? '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Campo da imagem com altura fixa (proporção da altura do card),
              // padronizado em todas as obras: independe do tamanho da descrição.
              // A imagem usa `contain`, então aparece inteira sem cortar.
              SizedBox(
                height: constraints.maxHeight * 0.45,
                width: double.infinity,
                child: _ArtworkImage(image: image),
              ),
              const SizedBox(height: 12),
              // Texto em tamanho normal e completo. Fica numa área rolável
              // apenas como segurança: com descrições de até 255 caracteres e o
              // espaço disponível, ele aparece inteiro sem precisar rolar.
              Expanded(
                child: SingleChildScrollView(
                  child: SizedBox(
                    width: constraints.maxWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          nome,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: Color(titleColor),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          autor,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            color: Color(greySubtitleColor),
                          ),
                        ),
                        if (descricao.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            descricao,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              height: 1.45,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                        if (link.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          InkWell(
                            onTap: () async {
                              final uri = Uri.tryParse(link);
                              if (uri != null && await canLaunchUrl(uri)) {
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            },
                            child: Text(
                              link,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ArtworkImage extends StatelessWidget {
  final String image;

  const _ArtworkImage({required this.image});

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (image.isEmpty) {
      child = Center(
        child: Icon(
          Icons.image_outlined,
          size: 64,
          color: Color(greySubtitleColor),
        ),
      );
    } else {
      try {
        final bytes = base64Decode(image);
        child = Image.memory(
          bytes,
          fit: BoxFit.contain,
          errorBuilder:
              (context, error, stackTrace) => Center(
                child: Icon(
                  Icons.broken_image,
                  size: 64,
                  color: Color(greySubtitleColor),
                ),
              ),
        );
      } catch (_) {
        child = Center(
          child: Icon(
            Icons.broken_image,
            size: 64,
            color: Color(greySubtitleColor),
          ),
        );
      }
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
