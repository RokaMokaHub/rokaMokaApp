import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roka_moka_app/domain/services/user_service.dart';
import 'package:roka_moka_app/presentation/pages/emblem_artworks_screen.dart';
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
            subtitulo: 'Tente novamente em ${remaining.inSeconds}s.',
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
        builder:
            (context, constraints) => RefreshIndicator(
              onRefresh: () => _loadEmblemas(fromRefresh: true),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.workspace_premium_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
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
              onTap: () => _openEmblemArtworks(emblema),
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

  void _openEmblemArtworks(Map<String, dynamic> emblema) {
    final dynamic rawId = emblema['id'];
    final int? emblemId =
        rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '');

    if (emblemId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBarNeutro(
          titulo: 'Emblema indisponível',
          subtitulo: 'Não foi possível identificar este emblema.',
        ).buildSnackBar(context),
      );
      return;
    }

    final String nome = emblema['nome'] as String? ?? '';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => EmblemArtworksScreen(
              emblemId: emblemId,
              emblemNome: nome.isNotEmpty ? nome : null,
            ),
      ),
    );
  }
}
