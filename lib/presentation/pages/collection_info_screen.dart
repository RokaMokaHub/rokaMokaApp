import 'package:flutter/material.dart';
import 'package:roka_moka_app/constants/routes.dart';
import 'package:roka_moka_app/domain/services/artwork_service.dart';
import 'package:roka_moka_app/domain/services/exposure_service.dart';

class CollectionInfoScreen extends StatefulWidget {
  final dynamic id;

  const CollectionInfoScreen({super.key, required this.id});

  @override
  State<CollectionInfoScreen> createState() => _CollectionInfoScreenState();
}

class _CollectionInfoScreenState extends State<CollectionInfoScreen> {
  final ExposureService _exposureService = ExposureService();
  final ArtworkService _artworkService = ArtworkService();

  bool _isLoading = true;
  String? _errorMessage;

  Map<String, dynamic>? _exhibition;
  List<Map<String, dynamic>> _artworks = [];
  List<Map<String, dynamic>> _missingArtworks = [];

  int get _totalStars => (_exhibition?['numberOfArtworks'] as int?) ?? 0;
  int get _collectedStars => _totalStars - _missingArtworks.length;
  bool get _emblemUnlocked => _missingArtworks.isEmpty && _totalStars > 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final id = int.parse(widget.id.toString());
      final results = await Future.wait([
        _exposureService.getExhibitionById(id),
        _artworkService.listArtworksByExhibition(id),
        _artworkService.getMissingArtworks(id),
      ]);

      if (mounted) {
        setState(() {
          _exhibition = results[0] as Map<String, dynamic>;
          _artworks = results[1] as List<Map<String, dynamic>>;
          _missingArtworks = results[2] as List<Map<String, dynamic>>;
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

  bool _isArtworkMissing(Map<String, dynamic> artwork) {
    return _missingArtworks.any((m) => m['id'] == artwork['id']);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Stack(
          children: [
            _buildHeader(context),
            const Center(child: CircularProgressIndicator()),
          ],
        ),
      );
    }

    if (_errorMessage != null || _exhibition == null) {
      return Scaffold(
        body: Stack(
          children: [
            _buildHeader(context),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text('Erro ao carregar exposição'),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _loadData,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final exhibition = _exhibition!;
    final String title = exhibition['name'] ?? '';
    final String museum = exhibition['location'] ?? '';
    final String description = exhibition['description'] ?? '';
    final String? headerImageUrl =
        _artworks.isNotEmpty ? _artworks.first['image'] as String? : null;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: headerImageUrl != null && headerImageUrl.isNotEmpty
                ? Image.network(
                    headerImageUrl,
                    fit: BoxFit.cover,
                    height: MediaQuery.of(context).size.height * 0.28,
                    errorBuilder: (_, __, ___) => Image.asset(
                      'lib/presentation/assets/images/starry_night.jpg',
                      fit: BoxFit.cover,
                      height: MediaQuery.of(context).size.height * 0.28,
                    ),
                  )
                : Image.asset(
                    'lib/presentation/assets/images/starry_night.jpg',
                    fit: BoxFit.cover,
                    height: MediaQuery.of(context).size.height * 0.28,
                  ),
          ),
          _buildHeader(context),
          Positioned(
            top: 260,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Exposição',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD1572A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            museum,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Estrelas coletadas',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: _totalStars > 0
                                ? (_collectedStars / _totalStars).clamp(0.0, 1.0)
                                : 0,
                            minHeight: 6,
                            backgroundColor: Colors.grey[300],
                            color: const Color(0xFFD1572A),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$_collectedStars/$_totalStars',
                          style: const TextStyle(color: Color(0xFFD1572A)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Emblema',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: _emblemUnlocked
                              ? Colors.orange[100]
                              : Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _emblemUnlocked ? Icons.emoji_events : Icons.lock,
                          size: 60,
                          color: _emblemUnlocked ? Colors.orange : Colors.grey,
                        ),
                      ),
                    ),
                    if (_artworks.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Obras da exposição',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _artworks.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final artwork = _artworks[index];
                          final bool collected = !_isArtworkMissing(artwork);
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              collected ? Icons.star : Icons.star_border,
                              color: collected
                                  ? const Color(0xFFE94C19)
                                  : Colors.grey,
                            ),
                            title: Text(
                              artwork['nome'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              artwork['nomeArtista'] ?? '',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 24),
                    Container(
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFB23F1A), Color(0xFFE94C19)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          await Navigator.pushNamed(context, qrCodeRoute);
                          if (mounted) _loadData();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Coletar via QR Code',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB23F1A), Color(0xFFE94C19)],
            begin: Alignment.bottomLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Container(
          height: 70,
          width: double.infinity,
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0, left: 8.0),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context, _collectedStars),
            ),
          ),
        ),
      ),
    );
  }
}
