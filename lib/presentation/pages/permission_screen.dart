import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:roka_moka_app/constants/colors.dart';
import 'package:roka_moka_app/domain/providers/user_provider.dart';
import 'package:roka_moka_app/presentation/widgets/snack_bar_aceita.dart';
import 'package:roka_moka_app/presentation/widgets/snack_bar_rejeitada.dart';

enum FilterOption { todas, aceitadas, rejeitadas, naoRespondidas }

class PermissionRequest {
  final String name;
  final String email;
  final String role;
  final String date;
  bool? accepted;
  String? rejectionReason;

  PermissionRequest({
    required this.name,
    required this.email,
    required this.role,
    required this.date,
    this.accepted,
  });
}

class PermissionsScreen extends StatefulWidget {
  final UserRole currentUserRole;
  final VoidCallback onBack;

  const PermissionsScreen({
    super.key,
    required this.currentUserRole,
    required this.onBack,
  });

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  final List<PermissionRequest> _allRequests = [
    PermissionRequest(
      name: "Yuji Sakuma",
      email: "yujisakuma@ufpel.com",
      role: "Pesquisador",
      date: "26/04/2025",
    ),
    PermissionRequest(
      name: "Pedro Rosa",
      email: "pedrorosa@ufpel.com",
      role: "Curador",
      date: "01/04/2025",
    ),
    PermissionRequest(
      name: "Bernardo Ferrão",
      email: "bernardferrao@ufpel.com",
      role: "Pesquisador",
      date: "20/03/2025",
    ),
    PermissionRequest(
      name: "Arthur Teles",
      email: "arthurteles@ufpel.com",
      role: "Pesquisador",
      date: "14/03/2025",
    ),
    PermissionRequest(
      name: "Aline Silva",
      email: "alinesilva@ufpel.com",
      role: "Curador",
      date: "12/03/2025",
      accepted: true,
    ),
    PermissionRequest(
      name: "Carlos Andrade",
      email: "carlosandrade@ufpel.com",
      role: "Pesquisador",
      date: "10/03/2025",
      accepted: false,
    ),
  ];

  late List<PermissionRequest> _filteredRequests;
  FilterOption _selectedFilter = FilterOption.todas;

  @override
  void initState() {
    super.initState();
    _filteredRequests = List.from(_allRequests);
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
        default:
          _filteredRequests = List.from(_allRequests);
          break;
      }
    });
  }

  void _acceptRequest(PermissionRequest request) {
    setState(() {
      request.accepted = true;
      _applyFilter(_selectedFilter);
    });
    final snackBar = SnackBarAceita(nome: request.name).buildSnackBar(context);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _rejectRequest(PermissionRequest request) {
    setState(() {
      request.accepted = false;
      _applyFilter(_selectedFilter);
    });
    final snackBar = SnackBarRejeitada(
      nome: request.name,
    ).buildSnackBar(context);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentUserRole != UserRole.administrador &&
        widget.currentUserRole != UserRole.curador) {
      return const Center(
        child: Text(
          "Acesso negado. Apenas administradores e curadores têm permissão.",
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 90,
        title: const Text(
          'Aceitar Permissões',
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
      body: Column(
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
                        style: TextStyle(color: Colors.black54, fontSize: 16),
                      ),
                    ],
                  ),
                  itemBuilder:
                      (BuildContext context) => <PopupMenuEntry<FilterOption>>[
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
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              itemCount: _filteredRequests.length,
              itemBuilder: (context, index) {
                final req = _filteredRequests[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey[400]!, width: 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 24,
                          backgroundColor: Color(0xFFE0E0E0),
                          child: Icon(Icons.person, color: Colors.black45),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                req.role,
                                style: const TextStyle(
                                  color: Colors.deepOrange,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                req.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                req.email,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                req.date,
                                style: const TextStyle(
                                  color: Colors.black45,
                                  fontSize: 12,
                                ),
                              ),
                              if (req.rejectionReason != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    "Motivo: ${req.rejectionReason}",
                                    style: const TextStyle(color: Colors.red),
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
                                    borderRadius: BorderRadius.circular(20),
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
                                    borderRadius: BorderRadius.circular(20),
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
                                onPressed: () => _rejectRequest(req),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
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
                                    borderRadius: BorderRadius.circular(20),
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
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  req.accepted == true ? "Aceita" : "Rejeitada",
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
