import 'package:flutter/material.dart';
import 'package:roka_moka_app/presentation/widgets/snack_bar_rejeitada.dart';

import '../../constants/colors.dart';
import '../widgets/snack_bar_aceita.dart';

class SolicitarPermissaoScreen extends StatefulWidget {
  final VoidCallback onBack;

  const SolicitarPermissaoScreen({super.key, required this.onBack});

  @override
  State<SolicitarPermissaoScreen> createState() =>
      _SolicitarPermissaoScreenState();
}

class _SolicitarPermissaoScreenState extends State<SolicitarPermissaoScreen> {
  String? selectedCargo;
  bool solicitacaoFeita = false;

  void _solicitarPermissao() {
    if (selectedCargo != null) {
      setState(() {
        solicitacaoFeita = true;
        final snackBar = SnackBarAceita(
          titulo: "Solicitação enviada!",
          subtitulo: "Sua solicitação foi enviada com sucesso.",
        ).buildSnackBar(context);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
    } else {
      setState(() {
        solicitacaoFeita = false;
        final snackBar = SnackBarRejeitada(
          titulo: "Solicitação rejeitada!",
          subtitulo: "Selecione um cargo.",
        ).buildSnackBar(context);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
    }
  }

  Widget _buildCargoTile({
    required String cargo,
    required String descricao,
    required IconData icon,
  }) {
    bool isSelected = selectedCargo == cargo;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        border: Border.all(
          color: isSelected ? Color(0xFFEF5B25) : Colors.grey.shade500,
          width: isSelected ? 3 : 2,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54, size: 48),
          SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cargo,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  descricao,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 90,
        title: const Text(
          'Solicitar Permissão',
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Escolha o cargo que deseja solicitar a permissão:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap:
                  solicitacaoFeita
                      ? null
                      : () => setState(() => selectedCargo = 'Curador'),
              child: _buildCargoTile(
                cargo: 'Curador',
                descricao: 'Gerencie e organize conteúdos das exposições.',
                icon: Icons.photo_outlined,
              ),
            ),
            GestureDetector(
              onTap:
                  solicitacaoFeita
                      ? null
                      : () => setState(() => selectedCargo = 'Pesquisador'),
              child: _buildCargoTile(
                cargo: 'Pesquisador',
                descricao: 'Descrição sobre as funções atribuídas ao cargo.',
                icon: Icons.search,
              ),
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                gradient:
                    solicitacaoFeita
                        ? null
                        : LinearGradient(
                          colors: [
                            Color(primaryColorGradient),
                            Color(secondaryColorGradient),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                borderRadius: BorderRadius.circular(32),
                color: solicitacaoFeita ? Colors.grey[400] : null,
              ),
              child: ElevatedButton(
                onPressed: solicitacaoFeita ? _solicitarPermissao : _solicitarPermissao,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
                child: Text(
                  'Solicitar cargo',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            if (solicitacaoFeita) ...[
              SizedBox(height: 32),
              Divider(),
              SizedBox(height: 12),
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Status da solicitação:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 48),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade600),
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '$selectedCargo',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                                fontSize: 16,
                              ),
                            ),
                            TextSpan(
                              text: ' – Aguardando análise.',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Colors.black54,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),

                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
