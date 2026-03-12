import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roka_moka_app/constants/colors.dart';
import 'package:roka_moka_app/domain/services/location_service.dart';
import 'package:roka_moka_app/domain/services/via_cep_service.dart';
import 'package:roka_moka_app/presentation/widgets/snack_bar_aceita.dart';
import 'package:roka_moka_app/presentation/widgets/snack_bar_rejeitada.dart';

enum _CreateStep { name, address }

class LocationFormScreen extends StatefulWidget {
  final LocationService locationService;
  final Location? location;

  const LocationFormScreen({
    super.key,
    required this.locationService,
    this.location,
  });

  bool get isEditing => location != null;

  @override
  State<LocationFormScreen> createState() => _LocationFormScreenState();
}

class _LocationFormScreenState extends State<LocationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _streetController;
  late final TextEditingController _numberController;
  late final TextEditingController _zipCodeController;

  final ViaCepService _viaCepService = ViaCepService();
  bool _isSaving = false;
  bool _isFetchingCep = false;
  _CreateStep _createStep = _CreateStep.name;

  @override
  void initState() {
    super.initState();
    final location = widget.location;
    _nameController = TextEditingController(text: location?.name ?? '');
    _streetController = TextEditingController(text: location?.street ?? '');
    _numberController = TextEditingController(text: location?.number ?? '');
    _zipCodeController = TextEditingController(text: location?.zipCode ?? '');
    _zipCodeController.addListener(_onCepChanged);
    if (widget.isEditing) {
      _createStep = _CreateStep.address;
    }
  }

  void _onCepChanged() {
    final digits = _zipCodeController.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 8) {
      _fetchAddressByCep(digits);
    }
  }

  Future<void> _fetchAddressByCep(String cep) async {
    if (_isFetchingCep) return;
    setState(() => _isFetchingCep = true);
    try {
      final address = await _viaCepService.fetchAddress(cep);
      if (!mounted) return;
      setState(() {
        _streetController.text = address.logradouro;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBarRejeitada(titulo: 'CEP não encontrado', subtitulo: e.toString())
            .buildSnackBar(context),
      );
    } finally {
      if (mounted) setState(() => _isFetchingCep = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isEditing ? 'Editar local' : 'Adicionar novo local';

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        toolbarHeight: 90,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _isSaving ? null : _handleBack,
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(primaryColorGradient),
                Color(secondaryColorGradient),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!widget.isEditing && _createStep == _CreateStep.name) ...[
                  const Padding(
                    padding: EdgeInsets.only(bottom: 18),
                    child: Text(
                      'Insira o nome do local e toque em "próximo" para adicionar um novo local.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(greySubtitleColor),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  _buildTextField(
                    fieldKey: const Key('location_name_field'),
                    controller: _nameController,
                    hintText: 'Nome do local (Ex: Museu de Artes)',
                  ),
                  const SizedBox(height: 18),
                  _buildPrimaryButton(
                    label: 'Próximo',
                    onTap: _isSaving ? null : _goToAddressStep,
                  ),
                ] else ...[
                  if (widget.isEditing) ...[
                    _buildTextField(
                      fieldKey: const Key('location_name_field'),
                      controller: _nameController,
                      hintText: 'Nome do local (Ex: Museu de Artes)',
                    ),
                    const SizedBox(height: 14),
                  ],
                  _buildTextField(
                    fieldKey: const Key('location_zip_code_field'),
                    controller: _zipCodeController,
                    hintText: 'CEP',
                    suffixIcon:
                        _isFetchingCep
                            ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                            : null,
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    fieldKey: const Key('location_street_field'),
                    controller: _streetController,
                    hintText: 'Endereço (Ex: Rua Afonso Pena)',
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    fieldKey: const Key('location_number_field'),
                    controller: _numberController,
                    hintText: 'Número',
                  ),
                  const SizedBox(height: 20),
                  _buildPrimaryButton(
                    label: 'Salvar',
                    onTap: _isSaving ? null : _submit,
                    isLoading: _isSaving,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    Key? fieldKey,
    required TextEditingController controller,
    required String hintText,
    Widget? suffixIcon,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(28),
      borderSide: const BorderSide(
        color: Color(focusedBorderColor),
        width: 1.5,
      ),
    );

    return TextFormField(
      key: fieldKey,
      controller: controller,
      style: const TextStyle(fontSize: 15, color: Color(darkerGreyButton)),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 15),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        suffixIcon: suffixIcon,
        border: border,
        enabledBorder: border.copyWith(
          borderSide: const BorderSide(
            color: Color(focusedBorderColor),
            width: 1.5,
          ),
        ),
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(
            color: Color(focusedBorderColor),
            width: 2,
          ),
        ),
        errorBorder: border.copyWith(
          borderSide: const BorderSide(
            color: Color(errorBorderColor),
            width: 1.5,
          ),
        ),
        focusedErrorBorder: border.copyWith(
          borderSide: const BorderSide(
            color: Color(errorBorderColor),
            width: 2,
          ),
        ),
      ),
      validator: (_) => _validateField(controller, hintText),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                onTap == null
                    ? const [Color(greyButton), Color(greyButton)]
                    : const [
                      Color(primaryColorGradient),
                      Color(secondaryColorGradient),
                    ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Center(
          child:
              isLoading
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : Text(
                    label,
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

  String? _validateField(TextEditingController controller, String hintText) {
    if (_fieldIsRequired(controller) && controller.text.trim().isEmpty) {
      return 'Campo obrigatório';
    }
    return null;
  }

  bool _fieldIsRequired(TextEditingController controller) {
    if (widget.isEditing) {
      return true;
    }

    switch (_createStep) {
      case _CreateStep.name:
        return identical(controller, _nameController);
      case _CreateStep.address:
        return identical(controller, _streetController) ||
            identical(controller, _numberController) ||
            identical(controller, _zipCodeController);
    }
  }

  void _goToAddressStep() {
    if (_nameController.text.trim().isEmpty) {
      _formKey.currentState!.validate();
      return;
    }

    setState(() {
      _createStep = _CreateStep.address;
    });
  }

  void _handleBack() {
    if (!widget.isEditing && _createStep == _CreateStep.address) {
      setState(() {
        _createStep = _CreateStep.name;
      });
      return;
    }

    Navigator.of(context).pop();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final payload = LocationPayload(
      name: _nameController.text.trim(),
      street: _streetController.text.trim(),
      number: _numberController.text.trim(),
      zipCode: _zipCodeController.text.trim(),
      complement: widget.location?.complement ?? '',
    );

    try {
      if (widget.isEditing) {
        await widget.locationService.updateLocation(
          widget.location!.id,
          payload,
        );
      } else {
        await widget.locationService.createLocation(payload);
      }

      if (!mounted) {
        return;
      }

      final snackBar = SnackBarAceita(
        titulo: widget.isEditing ? 'Local atualizado!' : 'Local criado!',
        subtitulo:
            widget.isEditing
                ? 'As alterações foram salvas com sucesso.'
                : 'O novo local foi cadastrado com sucesso.',
      ).buildSnackBar(context);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      final snackBar = SnackBarRejeitada(
        titulo: 'Erro ao salvar local',
        subtitulo: e.toString(),
      ).buildSnackBar(context);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  void dispose() {
    _zipCodeController.removeListener(_onCepChanged);
    _nameController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }
}
