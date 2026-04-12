import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roka_moka_app/constants/colors.dart';
import 'package:roka_moka_app/domain/services/exposure_service.dart';
import 'package:roka_moka_app/domain/services/artwork_service.dart';
import 'package:roka_moka_app/presentation/pages/create_exposure_screen.dart';
import 'package:roka_moka_app/presentation/widgets/snack_bar_aceita.dart';
import 'package:roka_moka_app/presentation/widgets/snack_bar_rejeitada.dart';

class ReviewExposureScreen extends StatefulWidget {
  final String exhibitionName;
  final String locationName;
  final int artworksCount;
  final String description;
  final int locationId;
  final List<Obra> obras;
  final VoidCallback onBack;

  const ReviewExposureScreen({
    super.key,
    required this.exhibitionName,
    required this.locationName,
    required this.artworksCount,
    required this.description,
    required this.locationId,
    required this.obras,
    required this.onBack,
  });

  @override
  State<ReviewExposureScreen> createState() => _ReviewExposureScreenState();
}

class _ReviewExposureScreenState extends State<ReviewExposureScreen> {
  final ExposureService _exposureService = ExposureService();
  final ArtworkService _artworkService = ArtworkService();
  bool _isLoading = false;

  String _mensagemErro(Object e) {
    final msg = e.toString();
    if (msg.startsWith('Exception: ')) return msg.substring('Exception: '.length);
    return msg;
  }

  Future<void> _confirmar() async {
    setState(() => _isLoading = true);

    int? exhibitionId;

    try {
      exhibitionId = await _exposureService.createExhibition(
        name: widget.exhibitionName,
        description: widget.description,
        locationId: widget.locationId,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBarRejeitada(
          titulo: 'Erro ao criar exposição',
          subtitulo: _mensagemErro(e),
        ).buildSnackBar(context),
      );
      return;
    }

    if (!mounted) return;

    if (exhibitionId == null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBarRejeitada(
          titulo: 'Erro ao criar exposição',
          subtitulo: 'ID da exposição não foi retornado pelo servidor.',
        ).buildSnackBar(context),
      );
      return;
    }

    for (var obra in widget.obras) {
      bool success;
      try {
        success = await _artworkService.createArtworkMultipart(
          exhibitionId: exhibitionId,
          nome: obra.tituloController.text,
          descricao: obra.descricaoController.text,
          nomeArtista: obra.artistaController.text,
          link: obra.linkController.text,
          imagem: obra.imagem,
          qrCode: obra.qrCodeValue,
        );
      } catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBarRejeitada(
            titulo: 'Erro ao salvar obra',
            subtitulo: _mensagemErro(e),
          ).buildSnackBar(context),
        );
        return;
      }

      if (!success) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBarRejeitada(
            titulo: 'Erro ao salvar obra',
            subtitulo: 'Erro desconhecido ao salvar uma das obras.',
          ).buildSnackBar(context),
        );
        return;
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBarAceita(
        titulo: 'Exposição salva!',
        subtitulo: 'A exposição foi cadastrada com sucesso.',
      ).buildSnackBar(context),
    );
    Navigator.of(context).pop();
    widget.onBack();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Confirme todas as informações da exposição antes de salvar:',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black45,
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoRow('Nome', widget.exhibitionName),
            _buildInfoRow('Local', widget.locationName),
            _buildInfoRow(
              'Quantidade de obras adicionadas',
              widget.artworksCount.toString(),
            ),
            const SizedBox(height: 32),
            _buildConfirmarButton(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      toolbarHeight: 90,
      title: const Text(
        'Revisão',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
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

  Widget _buildInfoRow(String label, String value) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Color(greySubtitleColor),
                    fontSize: 18,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmarButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _confirmar,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 12),
        decoration: BoxDecoration(
          gradient: _isLoading
              ? null
              : LinearGradient(
                  colors: [
                    Color(primaryColorGradient),
                    Color(secondaryColorGradient),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          color: _isLoading ? Color(greyButton) : null,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  'Confirmar',
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
}
