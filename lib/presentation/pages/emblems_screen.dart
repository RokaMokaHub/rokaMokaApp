import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roka_moka_app/domain/services/user_service.dart';
import 'package:roka_moka_app/presentation/widgets/snack_bar_neutro.dart';

class EmblemsScreen extends StatefulWidget {
  const EmblemsScreen({Key? key}) : super(key: key);

  @override
  _EmblemsScreenState createState() => _EmblemsScreenState();
}

class _EmblemsScreenState extends State<EmblemsScreen> {
  final UserService _userService = UserService();

  List<Map<String, dynamic>> _emblemas = [];
  bool _isLoading = true;
  String? _errorMessage;
  DateTime? _lastRefresh;

  static const Duration _refreshCooldown = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _loadEmblemas();
  }

  Future<void> _loadEmblemas({bool fromRefresh = false}) async {
    if (fromRefresh && _lastRefresh != null) {
      final elapsed = DateTime.now().difference(_lastRefresh!);
      if (elapsed < _refreshCooldown) {
        final remaining = _refreshCooldown - elapsed;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBarNeutro(
            titulo: 'Aguarde um momento',
            subtitulo:
                'Tente novamente em ${remaining.inSeconds}s.',
          ).buildSnackBar(context),
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _userService.getUserInfo();
      final mokaDex = data['body']?['mokaDex'];
      final emblemSet = mokaDex?['emblemSet'];

      final emblemas = <Map<String, dynamic>>[];
      if (emblemSet is List) {
        for (final e in emblemSet) {
          if (e is Map<String, dynamic>) {
            emblemas.add(e);
          }
        }
      }

      if (mounted) {
        setState(() {
          _emblemas = emblemas;
          _isLoading = false;
          _lastRefresh = DateTime.now();
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
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFB23F1A), Color(0xFFE94C19)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            padding: const EdgeInsets.only(top: 60, bottom: 20),
            alignment: Alignment.center,
            child: const Text(
              'Emblemas',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            const Text(
              'Erro ao carregar emblemas',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadEmblemas,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_emblemas.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) => RefreshIndicator(
          onRefresh: () => _loadEmblemas(fromRefresh: true),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.workspace_premium_outlined,
                        size: 64, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      'Nenhum emblema conquistado ainda.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Colete todas as obras de uma exposição\npara ganhar seu emblema!',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadEmblemas(fromRefresh: true),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GridView.builder(
          itemCount: _emblemas.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemBuilder: (context, index) {
            final emblema = _emblemas[index];
            final String nome = emblema['nome'] as String? ?? '';
            final exhibition = emblema['exhibition'];
            final String exposicao =
                exhibition is Map ? (exhibition['name'] as String? ?? '') : '';

            return GestureDetector(
              onTap: () => _showEmblemDetail(emblema),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.orange[100],
                    child: const Icon(
                      Icons.emoji_events,
                      size: 40,
                      color: Color(0xFFE94C19),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    nome,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                  if (exposicao.isNotEmpty)
                    Text(
                      exposicao,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showEmblemDetail(Map<String, dynamic> emblema) {
    final String nome = emblema['nome'] as String? ?? '';
    final String descricao = emblema['descricao'] as String? ?? '';
    final exhibition = emblema['exhibition'];
    final String exposicao =
        exhibition is Map ? (exhibition['name'] as String? ?? '') : '';

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header com gradiente
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFB23F1A), Color(0xFFE94C19)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(51),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Emblema',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            // Conteúdo
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Column(
                children: [
                  Text(
                    nome,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFD1572A),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (exposicao.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.collections_outlined,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            exposicao,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (descricao.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    const Divider(height: 1),
                    const SizedBox(height: 14),
                    Text(
                      descricao,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
            // Botão fechar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFB23F1A), Color(0xFFE94C19)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Center(
                      child: Text(
                        'Fechar',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
