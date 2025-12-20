import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:roka_moka_app/constants/colors.dart';
import 'package:roka_moka_app/presentation/widgets/snack_bar_aceita.dart';
import 'package:roka_moka_app/presentation/widgets/snack_bar_rejeitada.dart';
import '../../domain/services/manage_role_request_service.dart';
import '../widgets/show_tela_rejeicao.dart';

enum FilterOption { todas, aceitadas, rejeitadas, naoRespondidas }

class PermissionRequest {
  final int requestId;
  final String userName;
  final String email;
  final String targetRole;
  bool? accepted;
  String? rejectionReason;

  PermissionRequest({
    required this.requestId,
    required this.userName,
    required this.email,
    required this.targetRole,
    this.accepted,
    this.rejectionReason,
  });

  factory PermissionRequest.fromJson(Map<String, dynamic> json) {
    String formatRole(String role) {
      if (role.isEmpty) return role;
      return role[0].toUpperCase() + role.substring(1).toLowerCase();
    }

    return PermissionRequest(
      requestId: json['requestId'],
      userName: json['userName'],
      email: json['email'],
      targetRole: formatRole(json['targetRole']),
    );
  }
}

class PermissionsScreen extends StatefulWidget {
  final VoidCallback onBack;

  const PermissionsScreen({super.key, required this.onBack});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  final ManageRoleRequestService _manageAccessService = ManageRoleRequestService();
  final List<PermissionRequest> _allRequests = [];
  List<PermissionRequest> _filteredRequests = [];

  bool _isLoading = true;
  FilterOption _selectedFilter = FilterOption.todas;

  @override
  void initState() {
    super.initState();
    _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _manageAccessService.listRequestpermissions();
      final List<dynamic> rawList = data['body'] ?? [];
      final List<PermissionRequest> loadedRequests =
      rawList.map((json) => PermissionRequest.fromJson(json)).toList();

      setState(() {
        _allRequests.clear();
        _allRequests.addAll(loadedRequests);
        _applyFilter(_selectedFilter);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      final snackBar = SnackBarRejeitada(
        titulo: "Erro ao aceitar permissão: $e",
        subtitulo:
        "Tente novamente mais tarde. Se o erro persistir, entre em contato com o suporte.",
      ).buildSnackBar(context);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void _applyFilter(FilterOption option) {
    setState(() {
      _selectedFilter = option;
      switch (option) {
        case FilterOption.aceitadas:
          _filteredRequests =
              _allRequests.where((req) => req.accepted == true).toList();
          break;
        case FilterOption.rejeitadas:
          _filteredRequests =
              _allRequests.where((req) => req.accepted == false).toList();
          break;
        case FilterOption.naoRespondidas:
          _filteredRequests =
              _allRequests.where((req) => req.accepted == null).toList();
          break;
        case FilterOption.todas:
        _filteredRequests = List.from(_allRequests);
          break;
      }
    });
  }

  void _acceptRequest(PermissionRequest request) async {
    setState(() {
      request.accepted = true;
      _applyFilter(_selectedFilter);
    });

    try {
      final service = ManageRoleRequestService();
      await service.acceptPermissions(request.requestId);

      final snackBar = SnackBarAceita(
        nome: request.userName,
        titulo: "Permissão aceita!",
        subtitulo: "Permissão de ${request.userName} foi aceita com sucesso.",
      ).buildSnackBar(context);

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      setState(() {
        request.accepted = false;
        _applyFilter(_selectedFilter);
      });

      final snackBar = SnackBarRejeitada(
        titulo: "Erro ao aceitar permissão: $e",
        subtitulo:
        "Tente novamente mais tarde. Se o erro persistir, entre em contato com o suporte.",
      ).buildSnackBar(context);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void _rejectRequest(PermissionRequest request, String motivo) async {
    try {
      final service = ManageRoleRequestService();
      await service.rejectPermissions(
        request.requestId,
        motivo,
        request.userName,
      );

      final snackBar = SnackBarRejeitada(
        nome: request.userName,
        titulo: "Permissão rejeitada!",
        subtitulo:
        "Permissão de ${request.userName} foi rejeitada com sucesso.",
      ).buildSnackBar(context);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      setState(() {
        request.accepted = false;
        request.rejectionReason = motivo;
      });
    } catch (e) {
      setState(() {
        request.rejectionReason = null;
        _applyFilter(_selectedFilter);
      });

      final snackBar = SnackBarRejeitada(
        nome: request.userName,
        titulo: e.toString(),
        subtitulo:
        "Tente novamente mais tarde. Se o erro persistir, entre em contato com o suporte.",
      ).buildSnackBar(context);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 90,
        title: const Text(
          'Gerenciar Permissões',
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
      body:
      _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Container(
            padding: const EdgeInsets.only(right: 16, top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                PopupMenuButton<FilterOption>(
                  onSelected: _applyFilter,
                  child: const Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.filter,
                        color: Colors.grey,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "Filtrar",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  itemBuilder:
                      (BuildContext context) =>
                  <PopupMenuEntry<FilterOption>>[
                    const PopupMenuItem<FilterOption>(
                      value: FilterOption.todas,
                      child: Text('Todas'),
                    ),
                    const PopupMenuItem<FilterOption>(
                      value: FilterOption.aceitadas,
                      child: Text('Aceitadas'),
                    ),
                    const PopupMenuItem<FilterOption>(
                      value: FilterOption.rejeitadas,
                      child: Text('Rejeitadas'),
                    ),
                    const PopupMenuItem<FilterOption>(
                      value: FilterOption.naoRespondidas,
                      child: Text('Não respondidas'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredRequests.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Nenhuma permissão encontrada",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Não há solicitações de permissão no momento.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 12,
              ),
              itemCount: _filteredRequests.length,
              itemBuilder: (context, index) {
                final req = _filteredRequests[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: Colors.grey[400]!,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 32,
                          backgroundColor: Color(0xFFE0E0E0),
                          child: Icon(
                            Icons.person,
                            color: Colors.black45,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                req.targetRole,
                                style: const TextStyle(
                                  color: Colors.deepOrange,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                req.userName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                req.email,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                ),
                              ),
                              if (req.rejectionReason != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 4.0,
                                  ),
                                  child: Text(
                                    "Motivo: ${req.rejectionReason}",
                                    style: const TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (req.accepted == null) ...[
                              ElevatedButton(
                                onPressed: () => _acceptRequest(req),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      20,
                                    ),
                                  ),
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF34A34C),
                                        Color(0xFF55C26C),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      20,
                                    ),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 22,
                                      vertical: 6,
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      "Aceitar",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  showTelaRejeicao(
                                    context: context,
                                    onSalvar:
                                        (motivo) =>
                                        _rejectRequest(req, motivo),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      20,
                                    ),
                                  ),
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFB21A1A),
                                        Color(0xFFE91919),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      20,
                                    ),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 6,
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      "Rejeitar",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ] else ...[
                              Container(
                                width: 90,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(
                                    20,
                                  ),
                                ),
                                child: Text(
                                  req.accepted == true
                                      ? "Aceita"
                                      : "Rejeitada",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}