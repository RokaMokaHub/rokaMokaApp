import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roka_moka_app/constants/colors.dart';
import 'package:roka_moka_app/domain/services/location_service.dart';
import 'package:roka_moka_app/presentation/pages/location_form_screen.dart';
import 'package:roka_moka_app/presentation/widgets/snack_bar_rejeitada.dart';
import 'package:roka_moka_app/presentation/widgets/urgent_alert_dialog.dart';

import '../widgets/snack_bar_aceita.dart';

class LocationsScreen extends StatefulWidget {
  final VoidCallback onBack;
  final LocationService? locationService;

  const LocationsScreen({
    super.key,
    required this.onBack,
    this.locationService,
  });

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  late final LocationService _locationService;
  bool _isLoading = true;
  List<Location> _locations = const [];

  @override
  void initState() {
    super.initState();
    _locationService = widget.locationService ?? LocationService();
    _loadLocations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 90,
        title: const Text(
          'Locais',
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Column(
            children: [
              _buildAddButton(context),
              const SizedBox(height: 18),
              Expanded(child: _buildBody(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _openForm(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(primaryColorGradient),
              Color(secondaryColorGradient),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Center(
          child: Text(
            'Adicionar novo local',
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

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_locations.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadLocations,
        child: ListView(
          children: const [
            SizedBox(height: 120),
            Center(
              child: Text(
                'Nenhum local cadastrado.',
                style: TextStyle(fontSize: 16, color: Color(greySubtitleColor)),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLocations,
      child: ListView.separated(
        itemCount: _locations.length,
        separatorBuilder: (_, index) => const SizedBox(height: 18),
        itemBuilder: (context, index) {
          final location = _locations[index];
          return _LocationCard(
            location: location,
            onEdit: () => _openForm(context, location: location),
            onDelete: () => _confirmDelete(location),
          );
        },
      ),
    );
  }

  Future<void> _openForm(BuildContext context, {Location? location}) async {
    final shouldReload = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder:
            (_) => LocationFormScreen(
              locationService: _locationService,
              location: location,
            ),
      ),
    );

    if (shouldReload == true) {
      await _loadLocations();
    }
  }

  Future<void> _loadLocations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final locations = await _locationService.listLocations();
      if (!mounted) {
        return;
      }
      setState(() {
        _locations = locations;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _locations = const [];
        _isLoading = false;
      });
      final snackBar = SnackBarRejeitada(
        titulo: 'Erro ao carregar locais',
        subtitulo: e.toString(),
      ).buildSnackBar(context);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> _confirmDelete(Location location) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return UrgentAlertDialog(
          title: 'Excluir local',
          content: 'Deseja realmente excluir "${location.name}"?',
          confirmText: 'Excluir',
          cancelText: 'Cancelar',
        );
      },
    );

    if (confirm == true) {
      await _deleteLocation(location);
    }
  }

  Future<void> _deleteLocation(Location location) async {
    try {
      await _locationService.deleteLocation(location.id);

      if (!mounted) return;

      final snackBar = SnackBarAceita(
        titulo: 'Sucesso!',
        subtitulo: 'Local excluído com sucesso.',
      ).buildSnackBar(context);

      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      await _loadLocations();
    } catch (e) {
      if (!mounted) return;

      final snackBar = SnackBarRejeitada(
        titulo: 'Erro ao excluir local',
        subtitulo: e.toString(),
      ).buildSnackBar(context);

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}

class _LocationCard extends StatelessWidget {
  final Location location;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _LocationCard({
    required this.location,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(borderColor), width: 2.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              location.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(greySubtitleColor),
              ),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: onEdit,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(
                color: Color(focusedBorderColor),
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            child: const Text(
              'Editar',
              style: TextStyle(
                color: Color(focusedBorderColor),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: onDelete,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(
                color: Color(focusedBorderColor),
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            child: const Text(
              'Excluir',
              style: TextStyle(
                color: Color(focusedBorderColor),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
