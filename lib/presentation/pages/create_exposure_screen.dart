import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roka_moka_app/constants/webservice.dart';
import 'package:roka_moka_app/domain/services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roka_moka_app/constants/colors.dart';

// Classe principal da tela de criação de exposição
class CreateExposureScreen extends StatefulWidget {
  final VoidCallback onBack;

  const CreateExposureScreen({Key? key, required this.onBack}) : super(key: key);

  @override
  _CreateExposureScreenState createState() => _CreateExposureScreenState();
}

class _CreateExposureScreenState extends State<CreateExposureScreen> {
  // Chave do formulário para validação
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto para nome e descrição da exposição
  final TextEditingController _nomeExposicaoController = TextEditingController();
  final TextEditingController _descricaoExposicaoController = TextEditingController();

  // Variável para armazenar o museu selecionado no dropdown
  String? _museuSelecionado;

  // Lista de obras, inicializada com uma obra vazia
  final List<Obra> _obras = [Obra()];

  // Serviço de autenticação para obter o token
  final AuthService _authService = AuthService();

  // Mapa de museus e seus respectivos endereços DTO
  final Map<String, Map<String, String>> _museuEnderecoDTO = {
    'Museu da Baronesa': {
      'rua': 'Rua Baronesa',
      'numero': '100',
      'cep': '96000-001',
      'complemento': 'Sala A',
    },
    'Museu de Arte Leopoldo Gotuzzo (MALG)': {
      'rua': 'Rua Leopoldo Gotuzzo',
      'numero': '50',
      'cep': '96000-002',
      'complemento': 'Andar 2',
    },
    'Museu do Doce': {
      'rua': 'Rua Doce',
      'numero': '200',
      'cep': '96000-003',
      'complemento': 'Entrada Principal',
    },
    'Museu de História Natural Carlos Ritter': {
      'rua': 'Rua Carlos Ritter',
      'numero': '75',
      'cep': '96000-004',
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
            // Campo de texto para o nome da exposição
            _buildTextField(_nomeExposicaoController, 'Nome da exposição', true),
            const SizedBox(height: 16),
            // Dropdown para seleção do museu
            _buildDropdownMuseus(),
            const SizedBox(height: 16),
            // Campo de texto para a descrição da exposição
            _buildTextField(_descricaoExposicaoController, 'Descrição da exposição', false, maxLines: 4),
            const SizedBox(height: 24),
            // Seção para adicionar e gerenciar obras
            _buildObras(),
            const SizedBox(height: 32),
            // Botão para salvar a exposição
            _buildSalvarButton(),
            const SizedBox(height: 32),
          ]),
        ),
      ),
    );
  }

  // --- Widgets da Página ---

  // Constrói a AppBar personalizada
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

  // Constrói um campo de texto reutilizável
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

  // Constrói o dropdown para seleção de museus
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

  // Constrói a seção de obras, permitindo adicionar múltiplas obras
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

  // Constrói o formulário para uma única obra
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

  // Constrói o botão de salvar exposição
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

  // --- Requisições de API ---

  // Função para criar uma nova exposição
  Future<int?> createExhibition({
    required String name,
    required String description,
    required Map<String, String> enderecoDTO,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      final response = await http.post(
        Uri.parse(createExhibitionEndpoint),
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'description': description,
          'enderecoDTO': enderecoDTO,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['body']['id'];
      }
    } catch (e) {
      print('Erro ao criar exposição: $e');
    }
    return null;
  }

  // Função para criar uma obra com envio de arquivos (multipart)
  Future<bool> createArtworkMultipart({
    required int exhibitionId,
    required String nome,
    required String descricao,
    required String nomeArtista,
    String? link,
    XFile? imagem,
    XFile? qrCode,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return false;

      final uri = Uri.parse(createArtworkEndpoint(exhibitionId.toString()));
      final request = http.MultipartRequest('POST', uri);
      request.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';

      request.fields['nome'] = nome;
      request.fields['descricao'] = descricao;
      request.fields['nomeArtista'] = nomeArtista;
      request.fields['link'] = link ?? '';

      if (imagem != null) {
        final fileBytes = await imagem.readAsBytes();
        final multipartFile = http.MultipartFile.fromBytes(
          'image',
          fileBytes,
          filename: imagem.name,
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(multipartFile);
      }

      if (qrCode != null) {
        final qrBytes = await qrCode.readAsBytes();
        final qrBase64 = base64Encode(qrBytes);
        request.fields['qrCode'] = qrBase64;
      }

      final response = await request.send();
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Erro ao salvar obra: $e');
      return false;
    }
  }

  // --- Lógica de Negócio ---

  // Função para salvar a exposição e suas obras
  Future<void> _salvarExposicao() async {
    if (!_formKey.currentState!.validate()) return;

    if (_museuSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, selecione um museu')));
      return;
    }

    final enderecoDTO = _museuEnderecoDTO[_museuSelecionado!]!;
    final id = await createExhibition(
      name: _nomeExposicaoController.text,
      description: _descricaoExposicaoController.text,
      enderecoDTO: enderecoDTO,
    );

    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao criar exposição')));
      return;
    }

    for (var obra in _obras) {
      final success = await createArtworkMultipart(
        exhibitionId: id,
        nome: obra.tituloController.text,
        descricao: obra.descricaoController.text,
        nomeArtista: obra.artistaController.text,
        link: obra.linkController.text,
        imagem: obra.imagem,
        qrCode: obra.qrCode,
      );

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao salvar uma das obras')));
        return;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exposição salva com sucesso!')));
    widget.onBack();
  }
}

// Classe que representa uma Obra com seus controladores de texto e arquivos
class Obra {
  final TextEditingController artistaController = TextEditingController();
  final TextEditingController tituloController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();
  final TextEditingController linkController = TextEditingController();
  XFile? imagem;
  XFile? qrCode;
}