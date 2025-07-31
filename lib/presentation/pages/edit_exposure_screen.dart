import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roka_moka_app/constants/colors.dart';
import 'package:roka_moka_app/domain/services/exposure_service.dart';
import 'package:roka_moka_app/domain/services/artwork_service.dart';

// Classe principal da tela de edição de exposição
class EditExposureScreen extends StatefulWidget {
  final String exposureId; // ID da exposição a ser editada
  final VoidCallback onBack;

  const EditExposureScreen({
    Key? key,
    required this.exposureId,
    required this.onBack,
  }) : super(key: key);

  @override
  State<EditExposureScreen> createState() => _EditExposureScreenState();
}

class _EditExposureScreenState extends State<EditExposureScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomeExposicaoController =
      TextEditingController();
  final TextEditingController _descricaoExposicaoController =
      TextEditingController();

  String? _museuSelecionado;
  List<Obra> _obras = [];
  final List<int> _deletedArtworkIds =
      []; // Lista para rastrear obras excluídas

  // Estado para controlar o carregamento dos dados
  bool _isLoading = true;

  // Instâncias dos serviços
  final ExposureService _exposureService = ExposureService();
  final ArtworkService _artworkService = ArtworkService();

  final Map<String, Map<String, String>> _museuEnderecoDTO = {
    'Museu da Baronesa': {
      'id': '1',
      'rua': 'Rua Baronesa',
      'numero': '100',
      'cep': '96000-001',
      'complemento': 'Sala A',
    },
    'Museu de Arte Leopoldo Gotuzzo (MALG)': {
      'id': '2',
      'rua': 'Rua Leopoldo Gotuzzo',
      'numero': '50',
      'cep': '96000-002',
      'complemento': 'Andar 2',
    },
    'Museu do Doce': {
      'id': '3',
      'rua': 'Rua Doce',
      'numero': '200',
      'cep': '96000-003',
      'complemento': 'Entrada Principal',
    },
    'Museu de História Natural Carlos Ritter': {
      'id': '4',
      'rua': 'Rua Carlos Ritter',
      'numero': '75',
      'cep': '96000-004',
      'complemento': 'Pavilhão B',
    },
  };

  @override
  void initState() {
    super.initState();
    _fetchExposureData();
  }

  // Método para buscar os dados da exposição e preencher o formulário
  Future<void> _fetchExposureData() async {
    try {
      // Agora usando o ID passado para o widget para buscar os dados reais.
      final exposureData = await _exposureService.getExhibitionById(
        widget.exposureId,
      );

      print('Dados retornados da API: $exposureData');

      // Estratégia para buscar o museu filtrando pelo ID
      _nomeExposicaoController.text = exposureData['name'] as String;
      _descricaoExposicaoController.text =
          exposureData['description'] as String;

      // Mock dos dados, pois a rota para buscar as obras ainda não existe.
      final mockArtworks = [
        {
          'id': 1,
          'exposicao_id': 1,
          'artist': 'Wassily Kandinsky',
          'title': 'Composição VIII',
          'description': 'Obra de 1923.',
          'link': 'https://pt.wikipedia.org/wiki/Wassily_Kandinsky',
          'imageUrl': 'https://i.imgur.com/8so4a9a.jpeg',
          'qrCodeUrl': 'https://i.imgur.com/ABCDE12.png',
        },
        {
          'id': 2,
          'exposicao_id': 1,
          'artist': 'Piet Mondrian',
          'title': 'Composição com Vermelho, Amarelo e Azul',
          'description': 'Obra de 1930.',
          'link': 'https://pt.wikipedia.org/wiki/Piet_Mondrian',
          'imageUrl': 'https://i.imgur.com/xT5u6vW.jpeg',
          'qrCodeUrl': 'https://i.imgur.com/FGHIJ34.png',
        },
      ];

      // Preenchendo a lista de obras com os dados estáticos
      _obras =
          mockArtworks.map((data) {
            return Obra(
              id: data['id'] as int,
              artista: data['artist'] as String,
              titulo: data['title'] as String,
              descricao: data['description'] as String,
              link: data['link'] as String,
              imageUrl: data['imageUrl'] as String,
              qrCodeUrl: data['qrCodeUrl'] as String,
            );
          }).toList();
    } catch (e) {
      if (!mounted) return;

      // Agendamos a execução do SnackBar para depois da construção da tela.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao buscar dados da exposição: ${e.toString()}'),
          ),
        );
        widget.onBack();
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Edite as informações da exposição:', // Texto alterado
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        _nomeExposicaoController,
                        'Nome da exposição',
                        true,
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownMuseus(),
                      const SizedBox(height: 16),
                      _buildTextField(
                        _descricaoExposicaoController,
                        'Descrição da exposição',
                        false,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 24),
                      _buildObras(),
                      const SizedBox(height: 24),
                      Column(
                        spacing: 15,
                        children: [_buildAddButton(), _buildSalvarButton()],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      toolbarHeight: 90,
      automaticallyImplyLeading: false,
      title: const Text(
        'Editar Exposição',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
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

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    bool required, {
    int maxLines = 1,
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

    return DropdownButtonFormField<String>(
      isExpanded: true,
      dropdownColor: Colors.white,
      decoration: InputDecoration(
        labelText: 'Selecione o museu',
        labelStyle: TextStyle(color: Color(darkerGreyButton)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 12.0,
        ),
        border: roundedInputBorder,
        enabledBorder: roundedInputBorder,
        focusedBorder: roundedInputBorder,
      ),
      value: _museuSelecionado,
      items:
          _museuEnderecoDTO.keys
              .map(
                (value) => DropdownMenuItem(value: value, child: Text(value)),
              )
              .toList(),
      onChanged: (newValue) => setState(() => _museuSelecionado = newValue),
      validator:
          (value) =>
              value == null || value.isEmpty
                  ? 'Por favor, selecione um museu'
                  : null,
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
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildObraForm(_obras, index),
              ],
            );
          },
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
          // Apenas mostra o botão de excluir se houver mais de uma obra
          if (obras.isNotEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () {
                  setState(() {
                    // Se a obra já existe no banco (tem um ID), a adiciona na lista para exclusão posterior
                    if (obra.id != null) {
                      _deletedArtworkIds.add(obra.id!);
                    }
                    obras.removeAt(index);
                  });
                },
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
          ),
          const SizedBox(height: 16),
          _buildTextField(obra.linkController, 'Link da obra', false),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildImagePicker(obra, isQrCode: false)),
              const SizedBox(width: 16),
              Expanded(child: _buildImagePicker(obra, isQrCode: true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker(Obra obra, {required bool isQrCode}) {
    final XFile? file = isQrCode ? obra.qrCode : obra.imagem;
    final String? url = isQrCode ? obra.qrCodeUrl : obra.imageUrl;
    final String title = isQrCode ? 'QR Code Vinculado' : 'Imagem da obra';

    return Column(
      children: [
        Text(
          title,
          style: TextStyle(color: Color(greySubtitleColor), fontSize: 16),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final picked = await ImagePicker().pickImage(
              source: ImageSource.gallery,
            );
            if (picked != null) {
              setState(() {
                if (isQrCode) {
                  obra.qrCode = picked;
                } else {
                  obra.imagem = picked;
                }
              });
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14.0),
              child: _buildImageWidget(file, url),
            ),
          ),
        ),
      ],
    );
  }

  // Widget auxiliar para decidir qual imagem mostrar: local, da rede ou ícone.
  Widget _buildImageWidget(XFile? file, String? url) {
    if (file != null) {
      return Image.file(
        File(file.path),
        width: 120,
        height: 120,
        fit: BoxFit.cover,
      );
    }
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          return progress == null
              ? child
              : const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.error, color: Color(darkerGreyButton), size: 40);
        },
      );
    }
    return Icon(Icons.attachment, color: Color(darkerGreyButton), size: 40);
  }

  Widget _buildSalvarButton() {
    return GestureDetector(
      onTap: _updateExhibition, // Método alterado
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
            'Salvar exposição', // Texto alterado
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

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () => setState(() => _obras.add(Obra())), // Método alterado
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
            'Adicionar nova obra', // Texto alterado
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

  // Lógica de atualização
  Future<void> _updateExhibition() async {
    if (!_formKey.currentState!.validate()) return;

    if (_museuSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione um museu')),
      );
      return;
    }

    final enderecoDTO = _museuEnderecoDTO[_museuSelecionado!]!;

    try {
      /* Atualiza os dados da exposição principal
      await _exposureService.updateExhibition(
        // Método de update
        exhibitionId: widget.exposureId,
        name: _nomeExposicaoController.text,
        description: _descricaoExposicaoController.text,
        enderecoDTO: enderecoDTO,
      );
      */

      /* Processa as obras: atualiza existentes, cria novas
      for (var obra in _obras) {
        if (obra.id != null) {
          // Obra existente -> ATUALIZA
          await _artworkService.updateArtworkMultipart(
            // Método de update
            artworkId: obra.id!,
            exhibitionId: widget.exposureId,
            nome: obra.tituloController.text,
            descricao: obra.descricaoController.text,
            nomeArtista: obra.artistaController.text,
            link: obra.linkController.text,
            imagem: obra.imagem, // Pode ser nulo se não foi alterada
            qrCode: obra.qrCode, // Pode ser nulo se não foi alterado
          );
        } else {
          // Obra nova -> CRIA
          await _artworkService.createArtworkMultipart(
            exhibitionId: widget.exposureId,
            nome: obra.tituloController.text,
            descricao: obra.descricaoController.text,
            nomeArtista: obra.artistaController.text,
            link: obra.linkController.text,
            imagem: obra.imagem,
            qrCode: obra.qrCode,
          );
        }
      }
      */

      /* Deleta as obras que foram removidas da lista
      for (var artworkId in _deletedArtworkIds) {
        await _artworkService.deleteArtwork(artworkId); // Método de delete
      }
      */
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar exposição: ${e.toString()}')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exposição atualizada com sucesso!')),
    );
    // widget.onBack();
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

// Classe Obra atualizada para suportar dados de edição
class Obra {
  int? id; // ID da obra, nulo se for uma nova obra
  final TextEditingController artistaController;
  final TextEditingController tituloController;
  final TextEditingController descricaoController;
  final TextEditingController linkController;
  XFile? imagem; // Nova imagem selecionada
  XFile? qrCode; // Novo QR code selecionado
  String? imageUrl; // URL da imagem existente
  String? qrCodeUrl; // URL do QR code existente

  Obra({
    this.id,
    String artista = '',
    String titulo = '',
    String descricao = '',
    String link = '',
    this.imagem,
    this.qrCode,
    this.imageUrl,
    this.qrCodeUrl,
  }) : artistaController = TextEditingController(text: artista),
       tituloController = TextEditingController(text: titulo),
       descricaoController = TextEditingController(text: descricao),
       linkController = TextEditingController(text: link);

  void dispose() {
    artistaController.dispose();
    tituloController.dispose();
    descricaoController.dispose();
    linkController.dispose();
  }
}
