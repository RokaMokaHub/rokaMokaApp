import 'package:flutter/material.dart';
import 'package:roka_moka_app/constants/routes.dart';
import 'package:roka_moka_app/domain/services/artwork_service.dart';
import 'package:roka_moka_app/domain/services/exposure_service.dart';

class CollectionsScreen extends StatefulWidget {
  const CollectionsScreen({Key? key}) : super(key: key);

  @override
  _CollectionsScreenState createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  final ExposureService _exposureService = ExposureService();
  final ArtworkService _artworkService = ArtworkService();

  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _colecoes = [];

  @override
  void initState() {
    super.initState();
    _loadExhibitions();
  }

  Future<void> _loadExhibitions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final exhibitions = await _exposureService.listExhibitions();

      final missingResults = await Future.wait(
        exhibitions.map(
          (e) => _artworkService
              .getMissingArtworks(e['id'] as int)
              .catchError((_) => <Map<String, dynamic>>[]),
        ),
      );

      final colecoes = List.generate(exhibitions.length, (i) {
        final e = exhibitions[i];
        final total = (e['numberOfArtworks'] as int?) ?? 0;
        final missing = missingResults[i].length;
        final progresso = total - missing;
        return {
          'id': e['id'],
          'titulo': e['name'] ?? '',
          'museu': e['location'] ?? '',
          'total': total,
          'progresso': progresso,
          'completo': missing == 0 && total > 0,
        };
      });

      // Exposições completas vão para o final
      colecoes.sort((a, b) {
        final aCompleto = a['completo'] as bool;
        final bCompleto = b['completo'] as bool;
        if (aCompleto == bCompleto) return 0;
        return aCompleto ? 1 : -1;
      });

      if (mounted) {
        setState(() {
          _colecoes = colecoes;
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
              'Coleções',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 32),
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
            Text(
              'Erro ao carregar coleções',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadExhibitions,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_colecoes.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma exposição disponível.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadExhibitions,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _colecoes.length,
        itemBuilder: (context, index) {
          final colecao = _colecoes[index];
          final int total = colecao['total'] as int;
          final int progresso = colecao['progresso'] as int;
          final double progressoPercentual =
              total > 0 ? progresso / total : 0.0;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFB9B9B9)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    colecao['titulo'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE94C19),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Stack(
                    children: [
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: const Color(0xFFB9B9B9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: progressoPercentual.clamp(0.0, 1.0),
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE94C19),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$progresso/$total',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.location_on_outlined,
                            size: 32,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 4),
                        ],
                      ),
                      Expanded(
                        child: Text(
                          colecao['museu'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                          softWrap: true,
                          maxLines: null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () async {
                          final novoProgresso = await Navigator.pushNamed(
                            context,
                            collectionInfoRoute,
                            arguments: colecao['id'],
                          );

                          if (novoProgresso != null && mounted) {
                            setState(() {
                              _colecoes[index]['progresso'] = novoProgresso;
                              final t = _colecoes[index]['total'] as int;
                              final completo = (novoProgresso as int) >= t;
                              _colecoes[index]['completo'] = completo;
                              if (completo) {
                                final completada = _colecoes.removeAt(index);
                                _colecoes.add(completada);
                              }
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: colecao['completo'] as bool
                                ? Colors.grey
                                : null,
                            gradient: colecao['completo'] as bool
                                ? null
                                : const LinearGradient(
                                    colors: [
                                      Color(0xFFB23F1A),
                                      Color(0xFFE94C19),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            progresso >= total ? 'Completa' : 'Visualizar',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
