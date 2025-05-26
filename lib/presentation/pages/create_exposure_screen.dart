import 'package:flutter/material.dart';

class CreateExposureScreen extends StatefulWidget {
  final VoidCallback onBack;

  const CreateExposureScreen({Key? key, required this.onBack}) : super(key: key);

  @override
  _CreateExposureScreenState createState() => _CreateExposureScreenState();
}

class _CreateExposureScreenState extends State<CreateExposureScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeExposicaoController = TextEditingController();
  String? _museuSelecionado; // Para armazenar o museu selecionado
  final List<Obra> _obras = [Obra()]; // Inicializa com uma obra

  // Estilo de borda laranja permanente para campos de entrada
  final OutlineInputBorder _permanentOrangeInputBorder = OutlineInputBorder(
    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
    borderSide: const BorderSide(color: Color(0xFFE94C19), width: 2.0), // Cor laranja e espessura da borda focada
  );

  // Borda para quando o campo está focado (pode ser a mesma ou ligeiramente diferente se desejado)
  final OutlineInputBorder _focusedInputBorder = OutlineInputBorder(
    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
    borderSide: const BorderSide(color: Color(0xFFE94C19), width: 2.0), // Mantém a cor laranja
  );


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inserir Exposição', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true, // Centraliza o título no AppBar
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
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
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
                  border: _permanentOrangeInputBorder, // Borda laranja permanente
                  enabledBorder: _permanentOrangeInputBorder, // Borda laranja quando habilitado
                  focusedBorder: _focusedInputBorder, // Borda quando focado (pode ser a mesma)
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
                decoration: InputDecoration(
                  labelText: 'Selecione o museu',
                  border: _permanentOrangeInputBorder, // Borda laranja permanente
                  enabledBorder: _permanentOrangeInputBorder, // Borda laranja quando habilitado
                  focusedBorder: _focusedInputBorder, // Borda quando focado
                ),
                value: _museuSelecionado,
                items: <String>['Museu A', 'Museu B', 'Museu C'] // Substitua pela sua lista de museus
                    .map((String value) {
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
              // O título da seção de obras agora usa o comprimento da lista
              Text('Obra ${ _obras.isNotEmpty ? 1 : 0 }${_obras.length > 1 ? ' de '+_obras.length.toString() : ''}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _obras.length,
                itemBuilder: (context, index) {
                  // Passa o número da obra para o método de construção do formulário
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
                  label: const Text('Adicionar obra', style: TextStyle(color: Color(0xFFE94C19))),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(child: _buildImageUploadButton('Imagem da obra')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildQrCodeUploadButton('QR Code Vinculado')),
                ],
              ),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE94C19),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    minimumSize: const Size(double.infinity, 50), // Faz o botão ocupar a largura
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Processar os dados do formulário
                      print('Nome da Exposição: ${_nomeExposicaoController.text}');
                      print('Museu Selecionado: $_museuSelecionado');
                      for (int i = 0; i < _obras.length; i++) {
                        print('Obra ${i + 1}:');
                        print('  Nome do Artista: ${_obras.elementAt(i).artistaController.text}');
                        print('  Título da Obra: ${_obras.elementAt(i).tituloController.text}');
                        print('  Descrição da Obra: ${_obras.elementAt(i).descricaoController.text}');
                        print('  Link da Obra: ${_obras.elementAt(i).linkController.text}');
                      }
                      // TODO: Implementar a lógica de envio dos dados
                    }
                  },
                  child: const Text('Salvar Exposição', style: TextStyle(fontSize: 18)),
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
          // Adiciona o título "Obra X" antes de cada formulário de obra, se houver mais de uma.
          if (obras.length > 1 && index > 0) // Mostra apenas para a segunda obra em diante
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text('Obra $numeroObra', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          if (obras.length > 1) // Mostra o botão de excluir apenas se houver mais de uma obra
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
              border: _permanentOrangeInputBorder, // Borda laranja permanente
              enabledBorder: _permanentOrangeInputBorder, // Borda laranja quando habilitado
              focusedBorder: _focusedInputBorder, // Borda quando focado
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira o nome do artista';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: obra.tituloController,
            decoration: InputDecoration(
              labelText: 'Título da obra', // Alterado de "Text Field"
              border: _permanentOrangeInputBorder, // Borda laranja permanente
              enabledBorder: _permanentOrangeInputBorder, // Borda laranja quando habilitado
              focusedBorder: _focusedInputBorder, // Borda quando focado
            ),
            // Adicionar validador se necessário
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: obra.descricaoController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Texto sobre a obra',
              border: _permanentOrangeInputBorder, // Borda laranja permanente
              enabledBorder: _permanentOrangeInputBorder, // Borda laranja quando habilitado
              focusedBorder: _focusedInputBorder, // Borda quando focado
            ),
            // Adicionar validador se necessário
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: obra.linkController,
            decoration: InputDecoration(
              labelText: 'Link da obra (opcional)',
              border: _permanentOrangeInputBorder, // Borda laranja permanente
              enabledBorder: _permanentOrangeInputBorder, // Borda laranja quando habilitado
              focusedBorder: _focusedInputBorder, // Borda quando focado
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildImageUploadButton(String label) {
    return InkWell(
      onTap: () {
        // TODO: Implementar a lógica de upload de imagem
        print('Clicou em $label');
      },
      child: Container(
        height: 120, // Altura definida para melhor proporção
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.attach_file_outlined, size: 32, color: Colors.grey.shade600),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade700)),
          ],
        ),
      ),
    );
  }

  Widget _buildQrCodeUploadButton(String label) {
    return InkWell(
      onTap: () {
        // TODO: Implementar a lógica de upload de QR Code
        print('Clicou em $label');
      },
      child: Container(
        height: 120, // Altura definida para melhor proporção
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code_sharp, size: 32, color: Colors.grey.shade600),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade700)),
          ],
        ),
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
