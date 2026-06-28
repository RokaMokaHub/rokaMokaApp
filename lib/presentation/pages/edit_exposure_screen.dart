import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:roka_moka_app/constants/auth_messages.dart';
import 'package:roka_moka_app/constants/colors.dart';
import 'package:roka_moka_app/domain/services/artwork_service.dart';
import 'package:roka_moka_app/domain/services/exposure_service.dart';
import 'package:roka_moka_app/domain/services/location_service.dart';
import 'package:roka_moka_app/presentation/pages/location_form_screen.dart';
import 'package:roka_moka_app/presentation/widgets/relogin_prompt.dart';
import 'package:roka_moka_app/presentation/widgets/snack_bar_aceita.dart';
import 'package:roka_moka_app/presentation/widgets/snack_bar_rejeitada.dart';
import 'package:roka_moka_app/domain/services/emblem_service.dart';
import 'package:roka_moka_app/presentation/widgets/urgent_alert_dialog.dart';

class EditExposureScreen extends StatefulWidget {
  final VoidCallback onBack;

  const EditExposureScreen({super.key, required this.onBack});

  @override
  State<EditExposureScreen> createState() => _EditExposureScreenState();
}

class _EditExposureScreenState extends State<EditExposureScreen> {
  // Etapa 0 = selecionar exposição; Etapa 1 = editar
  int _step = 0;

  // Dados da etapa 0
  List<Map<String, dynamic>> _exhibitions = [];
  bool _isLoadingExhibitions = true;
  String? _loadExhibitionsError;

  // Dados da etapa 1
  final _formKey = GlobalKey<FormState>();
  int? _selectedExhibitionId;
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  String? _localSelecionadoId;
  List<Location> _locais = const [];
  bool _isLoadingLocais = true;
  List<ObraEdit> _obras = [];
  bool _isLoadingObraData = true;
  String? _loadObraError;
  bool _isSaving = false;
  bool _isDeleting = false;
  bool _isCreatingEmblem = false;

  // Emblemas indexados por exhibitionId — carregados do SharedPreferences + API
  final Map<int, Map<String, dynamic>> _emblemByExhibitionId = {};

  static const String _emblemPrefsKey = 'emblem_ids_by_exhibition';

  final ExposureService _exposureService = ExposureService();
  final ArtworkService _artworkService = ArtworkService();
  final LocationService _locationService = LocationService();
  final EmblemService _emblemService = EmblemService();

  @override
  void initState() {
    super.initState();
    _loadExhibitions();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    for (final obra in _obras) {
      obra.dispose();
    }
    super.dispose();
  }

  // ── Persistência de emblem IDs via SharedPreferences ──────────────────────

  Future<Map<int, int>> _loadSavedEmblemIds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_emblemPrefsKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(int.parse(k), v as int));
    } catch (_) {
      return {};
    }
  }

  Future<void> _saveEmblemId(int exhibitionId, int emblemId) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await _loadSavedEmblemIds();
    current[exhibitionId] = emblemId;
    await prefs.setString(
      _emblemPrefsKey,
      jsonEncode(current.map((k, v) => MapEntry(k.toString(), v))),
    );
  }

  Future<void> _removeSavedEmblemId(int exhibitionId) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await _loadSavedEmblemIds();
    current.remove(exhibitionId);
    await prefs.setString(
      _emblemPrefsKey,
      jsonEncode(current.map((k, v) => MapEntry(k.toString(), v))),
    );
  }

  // ── Etapa 0: carregar lista de exposições ──────────────────────────────────

  Future<void> _loadExhibitions() async {
    setState(() {
      _isLoadingExhibitions = true;
      _loadExhibitionsError = null;
    });
    try {
      final list = await _exposureService.listExhibitions();
      if (!mounted) return;

      // Carrega emblemas salvos e busca cada um via getEmblemById
      final savedIds = await _loadSavedEmblemIds();
      for (final entry in savedIds.entries) {
        try {
          final emblem = await _emblemService.getEmblemById(entry.value);
          _emblemByExhibitionId[entry.key] = emblem;
        } catch (_) {
          // Emblema não existe mais — limpa do cache
          _removeSavedEmblemId(entry.key);
        }
      }

      if (!mounted) return;
      setState(() {
        _exhibitions = list;
        _isLoadingExhibitions = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingExhibitions = false;
        _loadExhibitionsError = e.toString();
      });
    }
  }

  void _selectExhibition(Map<String, dynamic> exhibition) {
    setState(() {
      _selectedExhibitionId = exhibition['id'] as int?;
      _step = 1;
      _isLoadingObraData = true;
      _loadObraError = null;
    });
    _loadExhibitionData(_selectedExhibitionId!);
  }

  // ── Etapa 1: carregar dados da exposição selecionada ──────────────────────

  Future<void> _loadExhibitionData(int id) async {
    try {
      final results = await Future.wait([
        _exposureService.getExhibitionById(id),
        _artworkService.listArtworksByExhibition(id),
        _locationService.listLocations(),
      ]);

      final exhibition = results[0] as Map<String, dynamic>;
      final artworks = results[1] as List<Map<String, dynamic>>;
      final locations = results[2] as List<Location>;

      if (!mounted) return;

      // Pré-preenche campos da exposição
      _nomeController.text = exhibition['name'] as String? ?? '';
      _descricaoController.text = exhibition['description'] as String? ?? '';

      // Tenta pré-selecionar o local pelo nome retornado (ExhibitionOutputDTO.location = nome)
      final locationName = exhibition['location'] as String?;
      Location? matchedLocation;
      if (locations.isNotEmpty) {
        try {
          matchedLocation = locations.firstWhere((l) => l.name == locationName);
        } catch (_) {
          matchedLocation = locations.first;
        }
      }

      // Converte artworks em ObraEdit
      final obras = artworks.map((a) {
        final o = ObraEdit(
          id: a['id'] as int,
          imagemBase64Atual: a['image'] as String?,
        );
        o.artistaController.text = a['nomeArtista'] as String? ?? '';
        o.tituloController.text = a['nome'] as String? ?? '';
        o.descricaoController.text = a['descricao'] as String? ?? '';
        o.linkController.text = a['link'] as String? ?? '';
        o.qrCodeValue = a['qrCode'] as String?;
        return o;
      }).toList();

      setState(() {
        _locais = locations;
        _isLoadingLocais = false;
        _localSelecionadoId = matchedLocation?.id;
        _obras = obras;
        _isLoadingObraData = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingObraData = false;
        _loadObraError = e.toString();
      });
    }
  }

  // ── Salvar ────────────────────────────────────────────────────────────────

  Future<void> _salvarEdicao() async {
    if (!_formKey.currentState!.validate()) return;

    if (_localSelecionadoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBarRejeitada(
          titulo: 'Local não selecionado',
          subtitulo: 'Por favor, selecione um local antes de salvar.',
        ).buildSnackBar(context),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _exposureService.updateExhibition(
        id: _selectedExhibitionId!,
        name: _nomeController.text,
        description: _descricaoController.text,
        locationId: int.parse(_localSelecionadoId!),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      await _tratarErroEdicao('Erro ao atualizar exposição', e);
      return;
    }

    // Quando a exposição tem um emblema ativo, o backend ignora os campos
    // estruturais (nome, artista, QR Code, imagem) e só persiste descrição/link.
    // Detectamos isso comparando o que foi enviado com o ArtworkOutputDTO de
    // resposta e avisamos o usuário ao final.
    var algumCampoEstruturalIgnorado = false;

    for (final obra in _obras) {
      try {
        final saved = await _artworkService.updateArtwork(
          id: obra.id,
          nome: obra.tituloController.text,
          nomeArtista: obra.artistaController.text,
          descricao: obra.descricaoController.text,
          link: obra.linkController.text,
          qrCode: obra.qrCodeValue,
          imagem: obra.imagemNova,
        );

        if (_campoEstruturalFoiIgnorado(obra, saved)) {
          algumCampoEstruturalIgnorado = true;
        }
        _reconciliarObra(obra, saved);
      } catch (e) {
        if (!mounted) return;
        setState(() => _isSaving = false);
        await _tratarErroEdicao('Erro ao atualizar obra', e);
        return;
      }
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (algumCampoEstruturalIgnorado) {
      await _avisarEmblemaAtivo();
      if (!mounted) return;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBarAceita(
          titulo: 'Exposição atualizada!',
          subtitulo: 'As alterações foram salvas com sucesso.',
        ).buildSnackBar(context),
      );
    }
    widget.onBack();
  }

  /// Detecta, comparando o enviado com o `ArtworkOutputDTO` retornado, se algum
  /// campo estrutural foi ignorado pelo backend (indício de emblema ativo).
  /// A imagem não entra na comparação por não ser confiável de forma reativa.
  bool _campoEstruturalFoiIgnorado(ObraEdit obra, Map<String, dynamic> saved) {
    if (saved.isEmpty) return false;
    final nomeSalvo = (saved['nome'] ?? '').toString();
    final artistaSalvo = (saved['nomeArtista'] ?? '').toString();
    final qrCodeSalvo = (saved['qrCode'] ?? '').toString();
    return nomeSalvo != obra.tituloController.text ||
        artistaSalvo != obra.artistaController.text ||
        qrCodeSalvo != (obra.qrCodeValue ?? '');
  }

  /// Atualiza os controllers da obra com o estado realmente persistido pelo
  /// servidor, para que a UI não exiba valores que não foram salvos.
  void _reconciliarObra(ObraEdit obra, Map<String, dynamic> saved) {
    if (saved.isEmpty) return;
    obra.tituloController.text = (saved['nome'] ?? '').toString();
    obra.artistaController.text = (saved['nomeArtista'] ?? '').toString();
    obra.descricaoController.text = (saved['descricao'] ?? '').toString();
    obra.linkController.text = (saved['link'] ?? '').toString();
    obra.qrCodeValue = saved['qrCode']?.toString();
    obra.imagemNova = null;
  }

  Future<void> _avisarEmblemaAtivo() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Emblema ativo'),
        content: const Text(
          'Esta exposição possui um emblema ativo. Por isso, apenas a descrição e o '
          'link das obras foram atualizados — nome, artista, QR Code e imagem não '
          'podem mais ser alterados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  /// Exibe o erro de salvamento. Se o servidor recusou por permissões defasadas
  /// (403 → [permissionChangedMessage]), oferece re-login em vez do snackbar.
  Future<void> _tratarErroEdicao(String titulo, Object e) async {
    final msg = e.toString().startsWith('Exception: ')
        ? e.toString().substring('Exception: '.length)
        : e.toString();
    if (msg == permissionChangedMessage) {
      await promptPermissionChangedReLogin(context);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBarRejeitada(titulo: titulo, subtitulo: msg).buildSnackBar(context),
    );
  }

  // ── Excluir exposição ─────────────────────────────────────────────────────

  Future<void> _excluirExposicao(int exhibitionId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const UrgentAlertDialog(
        title: 'Excluir exposição',
        content:
            'Tem certeza que deseja excluir esta exposição? Esta ação não pode ser desfeita.',
        confirmText: 'Excluir',
        cancelText: 'Cancelar',
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);
    try {
      await _exposureService.deleteExhibition(exhibitionId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBarAceita(
          titulo: 'Exposição excluída!',
          subtitulo: 'A exposição foi removida com sucesso.',
        ).buildSnackBar(context),
      );
      setState(() {
        _isDeleting = false;
        _step = 0;
      });
      _loadExhibitions();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBarRejeitada(
          titulo: 'Erro ao excluir exposição',
          subtitulo: e.toString(),
        ).buildSnackBar(context),
      );
    }
  }

  // ── Excluir obra ──────────────────────────────────────────────────────────

  Future<void> _excluirObra(int index) async {
    if (_obras.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBarRejeitada(
          titulo: 'Não é possível excluir',
          subtitulo: 'A exposição deve ter ao menos uma obra.',
        ).buildSnackBar(context),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const UrgentAlertDialog(
        title: 'Excluir obra',
        content:
            'Tem certeza que deseja excluir esta obra? Esta ação não pode ser desfeita.',
        confirmText: 'Excluir',
        cancelText: 'Cancelar',
      ),
    );

    if (confirmed != true || !mounted) return;

    final obra = _obras[index];
    try {
      await _artworkService.deleteArtwork(obra.id);
      if (!mounted) return;
      setState(() {
        _obras.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBarAceita(
          titulo: 'Obra excluída!',
          subtitulo: 'A obra foi removida com sucesso.',
        ).buildSnackBar(context),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBarRejeitada(
          titulo: 'Erro ao excluir obra',
          subtitulo: e.toString(),
        ).buildSnackBar(context),
      );
    }
  }

  // ── Dialog de detalhes do emblema ─────────────────────────────────────────

  Future<void> _showEmblemDetailDialog(
    Map<String, dynamic> emblem,
    Map<String, dynamic> exhibition,
  ) async {
    final String nome = emblem['nome'] as String? ?? '';
    final String descricao = emblem['descricao'] as String? ?? '';
    final String exposicaoNome = exhibition['name'] as String? ?? '';
    final int exId = exhibition['id'] as int;
    final int? emblemId = emblem['id'] as int?;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                  colors: [Color(primaryColorGradient), Color(secondaryColorGradient)],
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
                      color: Color(titleColor),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (exposicaoNome.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.collections_outlined,
                            size: 14, color: Color(greySubtitleColor)),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            exposicaoNome,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Color(greySubtitleColor),
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
            // Botão excluir emblema
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(ctx, true),
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                  label: Text(
                    'Excluir emblema',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            // Botão fechar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () => Navigator.pop(ctx, false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(primaryColorGradient),
                          Color(secondaryColorGradient),
                        ],
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
            const SizedBox(height: 12),
          ],
        ),
      ),
    );

    if (shouldDelete != true || emblemId == null || !mounted) return;

    // Confirmação antes de excluir
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const UrgentAlertDialog(
        title: 'Excluir emblema',
        content: 'Tem certeza que deseja excluir este emblema? Esta ação não pode ser desfeita.',
        confirmText: 'Excluir',
        cancelText: 'Cancelar',
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _emblemService.deleteEmblem(emblemId);
      if (!mounted) return;
      _removeSavedEmblemId(exId);
      setState(() => _emblemByExhibitionId.remove(exId));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBarAceita(
          titulo: 'Emblema excluído!',
          subtitulo: 'O emblema foi removido com sucesso.',
        ).buildSnackBar(context),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBarRejeitada(
          titulo: 'Erro ao excluir emblema',
          subtitulo: e.toString(),
        ).buildSnackBar(context),
      );
    }
  }

  // ── Gerenciar emblema ─────────────────────────────────────────────────────

  Future<void> _gerenciarEmblema(Map<String, dynamic> exhibition) async {
    final exId = exhibition['id'] as int;
    final emblemExistente = _emblemByExhibitionId[exId];

    if (emblemExistente != null) {
      await _showEmblemDetailDialog(emblemExistente, exhibition);
      return;
    }

    // Formulário para criar novo emblema
    final nomeController = TextEditingController();
    final descricaoController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Adicionar Emblema',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(titleColor),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    exhibition['name'] as String? ?? '',
                    style: TextStyle(
                        fontSize: 13, color: Color(greySubtitleColor)),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    nomeController,
                    'Nome do emblema',
                    true,
                    maxLength: 30,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    descricaoController,
                    'Descrição (opcional)',
                    false,
                    maxLines: 3,
                    maxLength: 255,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: _isCreatingEmblem
                          ? null
                          : () async {
                              if (!formKey.currentState!.validate()) return;
                              setModalState(() {});
                              setState(() => _isCreatingEmblem = true);
                              final nav = Navigator.of(sheetCtx);
                              final scaffold = ScaffoldMessenger.of(context);
                              try {
                                final emblem =
                                    await _emblemService.createEmblem(
                                  exhibitionId: exId,
                                  nome: nomeController.text,
                                  descricao: descricaoController.text,
                                );
                                if (!mounted) return;
                                final emblemId = emblem['id'] as int?;
                                if (emblemId != null) {
                                  _saveEmblemId(exId, emblemId);
                                }
                                setState(() {
                                  _emblemByExhibitionId[exId] = emblem;
                                  _isCreatingEmblem = false;
                                });
                                nav.pop();
                                scaffold.showSnackBar(
                                  SnackBarAceita(
                                    titulo: 'Emblema criado!',
                                    subtitulo:
                                        'O emblema foi cadastrado com sucesso.',
                                  ).buildSnackBar(context),
                                );
                              } catch (e) {
                                if (!mounted) return;
                                setState(() => _isCreatingEmblem = false);
                                nav.pop();
                                scaffold.showSnackBar(
                                  SnackBarRejeitada(
                                    titulo: 'Erro ao criar emblema',
                                    subtitulo: e.toString(),
                                  ).buildSnackBar(context),
                                );
                              }
                            },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(primaryColorGradient),
                              Color(secondaryColorGradient),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Center(
                          child: _isCreatingEmblem
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  'Criar Emblema',
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
                ],
              ),
            ),
          );
        },
      ),
    );
    // Não chamar dispose() aqui: o sheet ainda pode estar animando o fechamento
    // quando o await retorna, e o Flutter continuaria reconstruindo os TextFormFields
    // referenciando controllers já descartados. Eles serão coletados pelo GC naturalmente.
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _step == 0 ? _buildSelectStep() : _buildEditStep(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      toolbarHeight: 90,
      title: Text(
        _step == 0 ? 'Editar Exposição' : 'Editar Exposição',
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          if (_step == 1) {
            setState(() => _step = 0);
          } else {
            widget.onBack();
          }
        },
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(primaryColorGradient),
              Color(secondaryColorGradient),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
    );
  }

  // ── Etapa 0: lista de exposições ──────────────────────────────────────────

  Widget _buildSelectStep() {
    if (_isLoadingExhibitions) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadExhibitionsError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Erro ao carregar exposições',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_loadExhibitionsError!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadExhibitions,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }
    if (_exhibitions.isEmpty) {
      return const Center(child: Text('Nenhuma exposição cadastrada.'));
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            children: [
              Text(
                'Selecione a exposição\nque deseja editar',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(titleColor),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: _exhibitions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final ex = _exhibitions[index];
              final exId = ex['id'] as int;
              return Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                elevation: 2,
                shadowColor: Colors.black12,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(primaryColorGradient),
                              Color(secondaryColorGradient),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.image_outlined,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ex['name'] as String? ?? '',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            if (ex['description'] != null &&
                                (ex['description'] as String).isNotEmpty)
                              Text(
                                ex['description'] as String,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Color(greySubtitleColor),
                                  fontSize: 13,
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.edit_outlined,
                          color: Color(titleColor),
                        ),
                        tooltip: 'Editar exposição',
                        onPressed: () => _selectExhibition(ex),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.workspace_premium_outlined,
                          color: _emblemByExhibitionId.containsKey(exId)
                              ? const Color(0xFFE94C19)
                              : Color(titleColor),
                        ),
                        tooltip: 'Gerenciar emblema',
                        onPressed: () => _gerenciarEmblema(ex),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        tooltip: 'Excluir exposição',
                        onPressed: _isDeleting
                            ? null
                            : () => _excluirExposicao(exId),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ── Etapa 1: formulário de edição ─────────────────────────────────────────

  Widget _buildEditStep() {
    if (_isLoadingObraData) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadObraError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Erro ao carregar dados',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_loadObraError!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadExhibitionData(_selectedExhibitionId!),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Dados da exposição'),
            const SizedBox(height: 16),
            _buildTextField(_nomeController, 'Nome da exposição', true),
            const SizedBox(height: 16),
            _buildDropdownLocais(),
            const SizedBox(height: 12),
            _buildAddLocationButton(),
            const SizedBox(height: 16),
            _buildTextField(
              _descricaoController,
              'Descrição da exposição',
              false,
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            if (_obras.isNotEmpty) ...[
              _buildSectionHeader('Obras da exposição'),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _obras.length,
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildObraHeader(index),
                      _buildObraForm(_obras[index]),
                    ],
                  );
                },
              ),
            ],
            const SizedBox(height: 32),
            _buildSalvarButton(),
            const SizedBox(height: 24),
            _buildEmblemaSectionStep1(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Widgets auxiliares ────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 22,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(primaryColorGradient),
                  Color(secondaryColorGradient),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(titleColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObraHeader(int index) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(primaryColorGradient),
                  Color(secondaryColorGradient),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Obra ${index + 1} de ${_obras.length}',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: 'Excluir obra',
            onPressed: () => _excluirObra(index),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    bool required, {
    int maxLines = 1,
    int? maxLength,
  }) {
    final OutlineInputBorder border = OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(30)),
      borderSide: const BorderSide(color: Color(focusedBorderColor), width: 2),
    );
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Color(darkerGreyButton)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: border,
        alignLabelWithHint: maxLines > 1,
      ),
      validator: (value) {
        if (required && (value == null || value.isEmpty)) {
          return 'Por favor, insira $label';
        }
        return null;
      },
    );
  }

  Widget _buildDropdownLocais() {
    final OutlineInputBorder border = OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(30)),
      borderSide: const BorderSide(color: Color(focusedBorderColor), width: 2),
    );
    final hasSelected = _locais.any((l) => l.id == _localSelecionadoId);

    return DropdownButtonFormField<String>(
      isExpanded: true,
      dropdownColor: Colors.white,
      decoration: InputDecoration(
        labelText: 'Selecione o local',
        labelStyle: TextStyle(color: Color(darkerGreyButton)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: border,
      ),
      value: hasSelected ? _localSelecionadoId : null,
      items: _locais
          .map((l) => DropdownMenuItem(value: l.id, child: Text(l.name)))
          .toList(),
      onChanged: _isLoadingLocais
          ? null
          : (v) => setState(() => _localSelecionadoId = v),
      hint: _isLoadingLocais
          ? const Text('Carregando locais...')
          : const Text('Escolha um local'),
      validator: (v) =>
          v == null || v.isEmpty ? 'Por favor, selecione um local' : null,
    );
  }

  Widget _buildAddLocationButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        onPressed: _openAddLocationForm,
        icon: Icon(Icons.add_location_alt_outlined, color: Color(titleColor)),
        label: Text(
          'Adicionar local',
          style: TextStyle(color: Color(titleColor)),
        ),
      ),
    );
  }

  Widget _buildObraForm(ObraEdit obra) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          _buildTextField(obra.artistaController, 'Nome do artista', true),
          const SizedBox(height: 16),
          _buildTextField(obra.tituloController, 'Título da obra', false),
          const SizedBox(height: 16),
          _buildTextField(
            obra.descricaoController,
            'Texto sobre a obra',
            false,
            maxLines: 4,
            maxLength: 400,
          ),
          const SizedBox(height: 16),
          _buildTextField(obra.linkController, 'Link da obra', false),
          const SizedBox(height: 16),
          _buildQrCodeScanner(obra),
          const SizedBox(height: 16),
          _buildImagePicker(obra),
        ],
      ),
    );
  }

  Widget _buildQrCodeScanner(ObraEdit obra) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QR Code Vinculado',
          style: TextStyle(color: Color(greySubtitleColor), fontSize: 16),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _scanQrCode(obra),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Color(focusedBorderColor), width: 2),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Icon(
                  obra.qrCodeValue != null
                      ? Icons.qr_code
                      : Icons.qr_code_scanner,
                  color: Color(
                    obra.qrCodeValue != null ? titleColor : darkerGreyButton,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    obra.qrCodeValue ?? 'Toque para escanear o QR Code',
                    style: TextStyle(
                      color: Color(
                        obra.qrCodeValue != null
                            ? titleColor
                            : darkerGreyButton,
                      ),
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (obra.qrCodeValue != null)
                  GestureDetector(
                    onTap: () => setState(() => obra.qrCodeValue = null),
                    child: Icon(Icons.close, color: Color(darkerGreyButton)),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker(ObraEdit obra) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Imagem da obra',
          style: TextStyle(color: Color(greySubtitleColor), fontSize: 16),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            if (obra.imagemNova != null) {
              setState(() => obra.imagemNova = null);
            } else {
              final picked = await ImagePicker().pickImage(
                source: ImageSource.gallery,
              );
              if (picked != null) setState(() => obra.imagemNova = picked);
            }
          },
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Color(focusedBorderColor), width: 2),
              color: Colors.white,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: _buildImagePreview(obra),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview(ObraEdit obra) {
    // Prioridade: nova imagem selecionada > base64 atual
    if (obra.imagemNova != null) {
      return Image.file(
        File(obra.imagemNova!.path),
        width: 120,
        height: 120,
        fit: BoxFit.cover,
      );
    }
    if (obra.imagemBase64Atual != null && obra.imagemBase64Atual!.isNotEmpty) {
      try {
        final bytes = base64Decode(obra.imagemBase64Atual!);
        return Image.memory(bytes, width: 120, height: 120, fit: BoxFit.cover);
      } catch (_) {}
    }
    return Center(
      child: Icon(Icons.attachment, color: Color(darkerGreyButton), size: 40),
    );
  }

  Widget _buildEmblemaSectionStep1() {
    final emblem = _emblemByExhibitionId[_selectedExhibitionId];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Emblema da exposição'),
        const SizedBox(height: 12),
        if (emblem != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.orange[100],
                  child: const Icon(Icons.emoji_events,
                      size: 28, color: Color(0xFFE94C19)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        emblem['nome'] as String? ?? '',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Color(titleColor),
                        ),
                      ),
                      if ((emblem['descricao'] as String?)?.isNotEmpty ??
                          false)
                        Text(
                          emblem['descricao'] as String,
                          style: TextStyle(
                              fontSize: 12, color: Color(greySubtitleColor)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          Row(
            children: [
              Icon(Icons.workspace_premium_outlined,
                  color: Color(greySubtitleColor)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Nenhum emblema cadastrado. Adicione um usando o ícone  na lista de exposições.',
                  style: TextStyle(
                      fontSize: 13, color: Color(greySubtitleColor)),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildSalvarButton() {
    return GestureDetector(
      onTap: _isSaving ? null : _salvarEdicao,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(primaryColorGradient),
              Color(secondaryColorGradient),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Center(
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  'Salvar alterações',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _scanQrCode(ObraEdit obra) async {
    final result = await FlutterBarcodeScanner.scanBarcode(
      '#FF6600',
      'Cancelar',
      true,
      ScanMode.QR,
    );
    if (result != '-1' && mounted) {
      setState(() => obra.qrCodeValue = result);
    }
  }

  Future<void> _openAddLocationForm() async {
    final shouldReload = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => LocationFormScreen(locationService: _locationService),
      ),
    );
    if (shouldReload == true) {
      final locations = await _locationService.listLocations();
      if (!mounted) return;
      setState(() {
        _locais = locations;
        _isLoadingLocais = false;
      });
    }
  }
}

// ── Modelo interno ─────────────────────────────────────────────────────────

class ObraEdit {
  final int id;
  final String? imagemBase64Atual;

  final TextEditingController artistaController = TextEditingController();
  final TextEditingController tituloController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();
  final TextEditingController linkController = TextEditingController();
  String? qrCodeValue;
  XFile? imagemNova;

  ObraEdit({required this.id, this.imagemBase64Atual});

  void dispose() {
    artistaController.dispose();
    tituloController.dispose();
    descricaoController.dispose();
    linkController.dispose();
  }
}
