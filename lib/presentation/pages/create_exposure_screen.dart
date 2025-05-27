import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roka_moka_app/presentation/widgets/upload_image.dart';
import 'package:roka_moka_app/presentation/widgets/upload_qrcode.dart';

class CreateExposureScreen extends StatefulWidget {
  final VoidCallback onBack;

  const CreateExposureScreen({Key? key, required this.onBack})
    : super(key: key);

  @override
  _CreateExposureScreenState createState() => _CreateExposureScreenState();
}

class _CreateExposureScreenState extends State<CreateExposureScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeExposicaoController =
      TextEditingController();
  String? _museuSelecionado;
  final List<Obra> _obras = [Obra()];

  XFile? _imagemDaExposicao;

  final OutlineInputBorder _permanentOrangeInputBorder = OutlineInputBorder(
    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
    borderSide: const BorderSide(color: Color(0xFFE94C19), width: 2.0),
  );

  final OutlineInputBorder _focusedInputBorder = OutlineInputBorder(
    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
    borderSide: const BorderSide(color: Color(0xFFE94C19), width: 2.0),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(36),
            bottomRight: Radius.circular(36),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Preencha as informações para cadastrar uma nova exposição:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomeExposicaoController,
                decoration: InputDecoration(
                  labelText: 'Nome da exposição',
                  border: _permanentOrangeInputBorder,
                  enabledBorder: _permanentOrangeInputBorder,
                  focusedBorder: _focusedInputBorder,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome da exposição';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                isExpanded: true,
                dropdownColor: Colors.grey.shade200,
                decoration: InputDecoration(
                  labelText: 'Selecione o museu',
                  border: _permanentOrangeInputBorder,
                  enabledBorder: _permanentOrangeInputBorder,
                  focusedBorder: _focusedInputBorder,
                ),
                value: _museuSelecionado,
                items:
                    <String>[
                      'Museu da Baronesa',
                      'Museu de Arte Leopoldo Gotuzzo (MALG)',
                      'Museu do Doce',
                      'Museu de História Natural Carlos Ritter',
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _museuSelecionado = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecione um museu';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Obra ${_obras.isNotEmpty ? 1 : 0}${_obras.length > 1 ? ' de ${_obras.length}' : ''}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _obras.length,
                itemBuilder: (context, index) {
                  return _buildObraForm(_obras, index, index + 1);
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _obras.add(Obra());
                    });
                  },
                  icon: const Icon(Icons.add, color: Color(0xFFE94C19)),
                  label: const Text(
                    'Adicionar obra',
                    style: TextStyle(color: Color(0xFFE94C19)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    // Envolve o ImageUploadField com Expanded
                    child: ImageUploadField(
                      label: 'Imagem da obra',
                      onImageSelected: (XFile? imageFile) {
                        setState(() {
                          _imagemDaExposicao =
                              imageFile; // Certifique-se que _imagemDaExposicao está definida no seu State
                        });
                        if (imageFile != null) {
                          print(
                            'Imagem selecionada na tela principal: ${imageFile.path}',
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ), // Adiciona um espaço entre os dois campos
                  Expanded(
                    // Envolve o QrCodeUploadField com Expanded
                    child: QrCodeUploadField(
                      label: 'QR Code da obra',
                      onQrCodeSelected: (XFile? qrCodeFile) {
                        // Se precisar usar o qrCodeFile, lembre-se de usar setState para uma variável de estado
                        // setState(() {
                        //   _qrCodeDaExposicao = qrCodeFile; // Crie _qrCodeDaExposicao se necessário
                        // });
                        if (qrCodeFile != null) {
                          print(
                            'QR Code selecionado na tela principal: ${qrCodeFile.path}',
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE94C19),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Lógica de salvar
                    }
                  },
                  child: const Text(
                    'Salvar Exposição',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildObraForm(List<Obra> obras, int index, int numeroObra) {
    final obra = obras.elementAt(index);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (obras.length > 1 && index > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Obra $numeroObra',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (obras.length > 1)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () {
                  setState(() {
                    obras.removeAt(index);
                  });
                },
                icon: const Icon(Icons.delete),
                label: const Text('Excluir obra'),
              ),
            ),
          TextFormField(
            controller: obra.artistaController,
            decoration: InputDecoration(
              labelText: 'Nome do artista',
              border: _permanentOrangeInputBorder,
              enabledBorder: _permanentOrangeInputBorder,
              focusedBorder: _focusedInputBorder,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira o nome do artista';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: obra.tituloController,
            decoration: InputDecoration(
              labelText: 'Título da obra',
              border: _permanentOrangeInputBorder,
              enabledBorder: _permanentOrangeInputBorder,
              focusedBorder: _focusedInputBorder,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: obra.descricaoController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Texto sobre a obra',
              border: _permanentOrangeInputBorder,
              enabledBorder: _permanentOrangeInputBorder,
              focusedBorder: _focusedInputBorder,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: obra.linkController,
            decoration: InputDecoration(
              labelText: 'Link da obra (opcional)',
              border: _permanentOrangeInputBorder,
              enabledBorder: _permanentOrangeInputBorder,
              focusedBorder: _focusedInputBorder,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class Obra {
  final TextEditingController artistaController = TextEditingController();
  final TextEditingController tituloController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();
  final TextEditingController linkController = TextEditingController();
}
