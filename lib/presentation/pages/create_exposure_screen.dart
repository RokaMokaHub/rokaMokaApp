import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roka_moka_app/constants/colors.dart';
import 'package:roka_moka_app/domain/services/exposure_service.dart';
import 'package:roka_moka_app/domain/services/artwork_service.dart';

// Classe principal da tela de criação de exposição
class CreateExposureScreen extends StatefulWidget {
  final VoidCallback onBack;

  const CreateExposureScreen({Key? key, required this.onBack}) : super(key: key);

  @override
  State<CreateExposureScreen> createState() => _CreateExposureScreenState();
}

class _CreateExposureScreenState extends State<CreateExposureScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomeExposicaoController = TextEditingController();
  final TextEditingController _descricaoExposicaoController = TextEditingController();

  String? _museuSelecionado;

  final List<Obra> _obras = [Obra()];

  // Instâncias dos serviços: ExposureService e ArtworkService
  final ExposureService _exposureService = ExposureService();
  final ArtworkService _artworkService = ArtworkService();

  final Map<String, Map<String, String>> _museuEnderecoDTO = {
    'Museu da Baronesa': {
      'rua': 'Rua Baronesa',
      'numero': '100',
      'cep': '96000001',
      'complemento': 'Sala A',
    },
    'Museu de Arte Leopoldo Gotuzzo (MALG)': {
      'rua': 'Rua Leopoldo Gotuzzo',
      'numero': '50',
      'cep': '96000002',
      'complemento': 'Andar 2',
    },
    'Museu do Doce': {
      'rua': 'Rua Doce',
      'numero': '200',
      'cep': '96000003',
      'complemento': 'Entrada Principal',
    },
    'Museu de História Natural Carlos Ritter': {
      'rua': 'Rua Carlos Ritter',
      'numero': '75',
      'cep': '96000004',
      'complemento': 'Pavilhão B',
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(children: [
            const Text(
              'Preencha as informações para cadastrar uma nova exposição:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildTextField(_nomeExposicaoController, 'Nome da exposição', true),
            const SizedBox(height: 16),
            _buildDropdownMuseus(),
            const SizedBox(height: 16),
            _buildTextField(_descricaoExposicaoController, 'Descrição da exposição', false, maxLines: 4),
            const SizedBox(height: 24),
            _buildObras(),
            const SizedBox(height: 32),
            _buildSalvarButton(),
            const SizedBox(height: 32),
          ]),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      toolbarHeight: 90,
      title: const Text('Inserir Exposição', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: widget.onBack,
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(primaryColorGradient), Color(secondaryColorGradient)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(36), bottomRight: Radius.circular(36)),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, bool required, {int maxLines = 1}) {
    final double borderRadiusValue = 30.0;

    final OutlineInputBorder roundedInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(borderRadiusValue)),
      borderSide: const BorderSide(color: Color(focusedBorderColor), width: 2.0),
    );

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Color(darkerGreyButton)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
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
      borderSide: const BorderSide(color: Color(focusedBorderColor), width: 2.0),
    );

    return DropdownButtonFormField<String>(
      isExpanded: true,
      dropdownColor: Colors.white,
      decoration: InputDecoration(
        labelText: 'Selecione o museu',
        labelStyle: TextStyle(color: Color(darkerGreyButton)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        border: roundedInputBorder,
        enabledBorder: roundedInputBorder,
        focusedBorder: roundedInputBorder,
      ),
      value: _museuSelecionado,
      items: _museuEnderecoDTO.keys
          .map((value) => DropdownMenuItem(value: value, child: Text(value)))
          .toList(),
      onChanged: (newValue) => setState(() => _museuSelecionado = newValue),
      validator: (value) => value == null || value.isEmpty ? 'Por favor, selecione um museu' : null,
    );
  }

  Widget _buildObras() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _obras.length,
          itemBuilder: (context, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Obra ${index + 1} de ${_obras.length}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
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
            label: Text('Adicionar obra', style: TextStyle(color: Color(titleColor))),
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
          _buildTextField(obra.descricaoController, 'Texto sobre a obra', false, maxLines: 4),
          const SizedBox(height: 16),
          _buildTextField(obra.linkController, 'Link da obra', false),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text('Imagem da obra', style: TextStyle(color: Color(greySubtitleColor), fontSize: 16)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        if (obra.imagem != null) {
                          setState(() => obra.imagem = null);
                        } else {
                          final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
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
                          border: Border.all(color: Color(focusedBorderColor), width: 2.0),
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
                              Icon(Icons.attachment, color: Color(darkerGreyButton), size: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    Text('QR Code Vinculado', style: TextStyle(color: Color(greySubtitleColor), fontSize: 16)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        if (obra.qrCode != null) {
                          setState(() => obra.qrCode = null);
                        } else {
                          final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                          if (picked != null) {
                            setState(() => obra.qrCode = picked);
                          }
                        }
                      },
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(color: Color(focusedBorderColor), width: 2.0),
                          color: Colors.white,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (obra.qrCode != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14.0),
                                child: Image.file(
                                  File(obra.qrCode!.path),
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              )
                            else
                              Icon(Icons.attachment, color: Color(darkerGreyButton), size: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
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
        padding: const EdgeInsets.symmetric(
          horizontal: 60,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(primaryColorGradient), Color(secondaryColorGradient)],
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

  Future<void> _salvarExposicao() async {
    if (!_formKey.currentState!.validate()) return;

    if (_museuSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, selecione um museu')));
      return;
    }

    final enderecoDTO = _museuEnderecoDTO[_museuSelecionado!]!;
    int? exhibitionId;

    try {
      exhibitionId = await _exposureService.createExhibition(
        name: _nomeExposicaoController.text,
        description: _descricaoExposicaoController.text,
        enderecoDTO: enderecoDTO,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao criar exposição: ${e.toString()}')));
      return;
    }

    if (exhibitionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao criar exposição: ID não retornado.')));
      return;
    }

    for (var obra in _obras) {
      bool success;
      try {
        success = await _artworkService.createArtworkMultipart( // Chamando a função do serviço unificado
          exhibitionId: exhibitionId,
          nome: obra.tituloController.text,
          descricao: obra.descricaoController.text,
          nomeArtista: obra.artistaController.text,
          link: obra.linkController.text,
          imagem: obra.imagem,
          qrCode: obra.qrCode,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar uma das obras: ${e.toString()}')));
        return;
      }

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro desconhecido ao salvar uma das obras.')));
        return;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exposição salva com sucesso!')));
    widget.onBack();
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
  XFile? qrCode;

  void dispose() {
    artistaController.dispose();
    tituloController.dispose();
    descricaoController.dispose();
    linkController.dispose();
  }
}