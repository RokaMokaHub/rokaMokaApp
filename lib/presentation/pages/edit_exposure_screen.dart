import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';
import 'package:roka_moka_app/constants/colors.dart';
import 'package:roka_moka_app/domain/services/artwork_service.dart';
import 'package:roka_moka_app/domain/services/exposure_service.dart';
import 'package:roka_moka_app/domain/services/location_service.dart';
import 'package:roka_moka_app/presentation/pages/location_form_screen.dart';
import 'package:roka_moka_app/presentation/widgets/snack_bar_aceita.dart';
import 'package:roka_moka_app/presentation/widgets/snack_bar_rejeitada.dart';
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

  final ExposureService _exposureService = ExposureService();
  final ArtworkService _artworkService = ArtworkService();
  final LocationService _locationService = LocationService();

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

  // ── Etapa 0: carregar lista de exposições ──────────────────────────────────

  Future<void> _loadExhibitions() async {
    setState(() {
      _isLoadingExhibitions = true;
      _loadExhibitionsError = null;
    });
    try {
      final list = await _exposureService.listExhibitions();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBarRejeitada(
          titulo: 'Erro ao atualizar exposição',
          subtitulo: e.toString(),
        ).buildSnackBar(context),
      );
      return;
    }

    for (final obra in _obras) {
      try {
        await _artworkService.updateArtwork(
          id: obra.id,
          nome: obra.tituloController.text,
          nomeArtista: obra.artistaController.text,
          descricao: obra.descricaoController.text,
          link: obra.linkController.text,
          qrCode: obra.qrCodeValue,
          imagem: obra.imagemNova,
        );
      } catch (e) {
        if (!mounted) return;
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBarRejeitada(
            titulo: 'Erro ao atualizar obra',
            subtitulo: e.toString(),
          ).buildSnackBar(context),
        );
        return;
      }
    }

    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBarAceita(
        titulo: 'Exposição atualizada!',
        subtitulo: 'As alterações foram salvas com sucesso.',
      ).buildSnackBar(context),
    );
    widget.onBack();
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
      widget.onBack();
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
