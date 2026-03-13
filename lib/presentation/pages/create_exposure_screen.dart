import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:roka_moka_app/constants/colors.dart';
import 'package:roka_moka_app/domain/services/location_service.dart';
import 'package:roka_moka_app/presentation/pages/location_form_screen.dart';
import 'package:roka_moka_app/presentation/pages/review_exposure_screen.dart';
import 'package:roka_moka_app/presentation/widgets/snack_bar_rejeitada.dart';

// Classe principal da tela de criação de exposição
class CreateExposureScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback? onConfirmed;

  const CreateExposureScreen({
    super.key,
    required this.onBack,
    this.onConfirmed,
  });

  @override
  State<CreateExposureScreen> createState() => _CreateExposureScreenState();
}

class _CreateExposureScreenState extends State<CreateExposureScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomeExposicaoController =
      TextEditingController();
  final TextEditingController _descricaoExposicaoController =
      TextEditingController();

  final LocationService _locationService = LocationService();

  String? _localSelecionadoId;
  List<Location> _locais = const [];
  bool _isLoadingLocais = true;

  final List<Obra> _obras = [Obra()];

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Dados da exposição'),
              const SizedBox(height: 16),
              _buildTextField(
                _nomeExposicaoController,
                'Nome da exposição',
                true,
              ),
              const SizedBox(height: 16),
              _buildDropdownMuseus(),
              const SizedBox(height: 12),
              _buildAddLocationButton(),
              const SizedBox(height: 16),
              _buildTextField(
                _descricaoExposicaoController,
                'Descrição da exposição',
                false,
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              _buildObras(),
              const SizedBox(height: 32),
              _buildSalvarButton(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      toolbarHeight: 90,
      title: const Text(
        'Inserir Exposição',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: widget.onBack,
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
    return Row(
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
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    bool required, {
    int maxLines = 1,
    int? maxLength,
  }) {
    final double borderRadiusValue = 30.0;

    final OutlineInputBorder roundedInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(borderRadiusValue)),
      borderSide: const BorderSide(
        color: Color(focusedBorderColor),
        width: 2.0,
      ),
    );

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Color(darkerGreyButton)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 12.0,
        ),
        border: roundedInputBorder,
        enabledBorder: roundedInputBorder,
        focusedBorder: roundedInputBorder,
        alignLabelWithHint: maxLines > 1 ? true : false,
      ),
      validator: (value) {
        if (required && (value == null || value.isEmpty)) {
          return 'Por favor, insira $label';
        }
        return null;
      },
    );
  }

  Widget _buildDropdownMuseus() {
    final double borderRadiusValue = 30.0;
    final OutlineInputBorder roundedInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(borderRadiusValue)),
      borderSide: const BorderSide(
        color: Color(focusedBorderColor),
        width: 2.0,
      ),
    );

    final hasSelectedLocation = _locais.any(
      (location) => location.id == _localSelecionadoId,
    );

    return DropdownButtonFormField<String>(
      isExpanded: true,
      dropdownColor: Colors.white,
      decoration: InputDecoration(
        labelText: 'Selecione o local',
        labelStyle: TextStyle(color: Color(darkerGreyButton)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 12.0,
        ),
        border: roundedInputBorder,
        enabledBorder: roundedInputBorder,
        focusedBorder: roundedInputBorder,
      ),
      initialValue: hasSelectedLocation ? _localSelecionadoId : null,
      items:
          _locais
              .map(
                (location) => DropdownMenuItem(
                  value: location.id,
                  child: Text(location.name),
                ),
              )
              .toList(),
      onChanged:
          _isLoadingLocais
              ? null
              : (newValue) => setState(() => _localSelecionadoId = newValue),
      hint:
          _isLoadingLocais
              ? const Text('Carregando locais...')
              : const Text('Escolha um local'),
      validator:
          (value) =>
              value == null || value.isEmpty
                  ? 'Por favor, selecione um local'
                  : null,
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

  Widget _buildObras() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                _buildObraForm(_obras, index),
              ],
            );
          },
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => setState(() => _obras.add(Obra())),
            icon: Icon(Icons.add, color: Color(titleColor)),
            label: Text(
              'Adicionar obra',
              style: TextStyle(color: Color(titleColor)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildObraForm(List<Obra> obras, int index) {
    final obra = obras[index];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          if (obras.length > 1)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () => setState(() => obras.removeAt(index)),
                icon: const Icon(Icons.delete),
                label: const Text('Excluir obra'),
              ),
            ),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Imagem da obra',
                style: TextStyle(
                  color: Color(greySubtitleColor),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  if (obra.imagem != null) {
                    setState(() => obra.imagem = null);
                  } else {
                    final picked = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                    );
                    if (picked != null) {
                      setState(() => obra.imagem = picked);
                    }
                  }
                },
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      color: Color(focusedBorderColor),
                      width: 2.0,
                    ),
                    color: Colors.white,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (obra.imagem != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14.0),
                          child: Image.file(
                            File(obra.imagem!.path),
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Icon(
                          Icons.attachment,
                          color: Color(darkerGreyButton),
                          size: 40,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSalvarButton() {
    return GestureDetector(
      onTap: _salvarExposicao,
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
          child: Text(
            'Salvar exposição',
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

  Widget _buildQrCodeScanner(Obra obra) {
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
              border: Border.all(color: Color(focusedBorderColor), width: 2.0),
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

  Future<void> _scanQrCode(Obra obra) async {
    final controller = MobileScannerController();
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: SizedBox(
            width: 300,
            height: 300,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: MobileScanner(
                controller: controller,
                onDetect: (capture) {
                  final rawValue = capture.barcodes.first.rawValue;
                  if (rawValue != null) {
                    setState(() => obra.qrCodeValue = rawValue);
                    controller.dispose();
                    Navigator.of(ctx).pop();
                  }
                },
              ),
            ),
          ),
          title: const Text('Escanear QR Code', textAlign: TextAlign.center),
          actions: [
            TextButton(
              onPressed: () {
                controller.dispose();
                Navigator.of(ctx).pop();
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _salvarExposicao() async {
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

    final locationName = _locais
        .firstWhere((l) => l.id == _localSelecionadoId)
        .name;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReviewExposureScreen(
          exhibitionName: _nomeExposicaoController.text,
          locationName: locationName,
          artworksCount: _obras.length,
          description: _descricaoExposicaoController.text,
          locationId: int.parse(_localSelecionadoId!),
          obras: _obras,
          onBack: widget.onConfirmed ?? widget.onBack,
        ),
      ),
    );
  }

  Future<void> _openAddLocationForm() async {
    final shouldReload = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => LocationFormScreen(locationService: _locationService),
      ),
    );

    if (shouldReload == true) {
      await _loadLocations();
    }
  }

  Future<void> _loadLocations() async {
    setState(() {
      _isLoadingLocais = true;
    });

    try {
      final locations = await _locationService.listLocations();
      if (!mounted) {
        return;
      }

      setState(() {
        _locais = locations;
        _isLoadingLocais = false;
        if (!_locais.any((location) => location.id == _localSelecionadoId)) {
          _localSelecionadoId = null;
        }
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _locais = const [];
        _isLoadingLocais = false;
        _localSelecionadoId = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBarRejeitada(
          titulo: 'Erro ao carregar locais',
          subtitulo: e.toString(),
        ).buildSnackBar(context),
      );
    }
  }

  @override
  void dispose() {
    _nomeExposicaoController.dispose();
    _descricaoExposicaoController.dispose();
    for (var obra in _obras) {
      obra.dispose();
    }
    super.dispose();
  }
}

class Obra {
  final TextEditingController artistaController = TextEditingController();
  final TextEditingController tituloController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();
  final TextEditingController linkController = TextEditingController();
  XFile? imagem;
  String? qrCodeValue;

  void dispose() {
    artistaController.dispose();
    tituloController.dispose();
    descricaoController.dispose();
    linkController.dispose();
  }
}
