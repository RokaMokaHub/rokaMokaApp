import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RequestPermissionScreen extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _RequestPermissionState createState() => _RequestPermissionState();
}

class _RequestPermissionState extends State<RequestPermissionScreen> {
  String? _selectedProfile = "Curador";
  bool _submitted = false;

  void _showSuccessPopup() {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder:
          (context) => Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[600],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Color(0xFF383838), size: 20),
                    SizedBox(width: 16),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Solicitação enviada!",
                          style: TextStyle(
                            color: Color(0xFF383838),
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Sua solicitação foi enviada com sucesso.",
                          style: TextStyle(
                            color: Color(0xFF383838),
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(Duration(seconds: 3)).then((_) => overlayEntry.remove());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(children: [_appBar(context), _screenContent()]),
      ),
    );
  }

  Widget _screenContent() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        spacing: 30,
        children: [
          _selectProfile(),
          _button(),
          if (_submitted) _statusRequest(),
        ],
      ),
    );
  }

  Widget _statusRequest() {
    return Column(
      spacing: 10,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
          child: Container(
            width: double.infinity,
            height: 1,
            decoration: BoxDecoration(color: Color(0xFF999999)),
          ),
        ),
        Text(
          "Status da solicitação:",
          style: TextStyle(
            color: Color(0xFF646464),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Color(0xFFE9E9E9),
            borderRadius: BorderRadius.all(Radius.circular(15)),
            border: Border.all(color: Color(0xFF999999)),
          ),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: _selectedProfile,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8B8B8B),
                    fontSize: 16,
                  ),
                ),
                TextSpan(
                  text: " - Aguardando análise",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF8B8B8B),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _button() {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFB23F1A), Color(0xFFE94C19)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _submitted = true;
          });
          _showSuccessPopup();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          padding: EdgeInsets.zero,
        ),
        child: const Text(
          'Solicitar cargo',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _selectProfile() {
    return Column(
      spacing: 16,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Escolha o cargo que deseja solicitar a permissão:",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF646464),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _cardProfile(
          title: "Curador",
          description: "Gerencie e organize conteúdos das exposições.",
        ),
        _cardProfile(
          title: "Pesquisador",
          description:
              "Tenha acesso a informações e documentos exclusivos para pesquisa.",
        ),
      ],
    );
  }

  Widget _cardProfile({required String title, required String description}) {
    final isSelected = _selectedProfile == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedProfile = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFCFCFCF) : Color(0xFFE9E9E9),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? Color(0xFFE94C19) : Color(0xFFB9B9B9),
            width: 2,
          ),
        ),
        child: Row(
          spacing: 10,
          children: [
            Icon(
              Icons.search,
              color: isSelected ? Color(0xFF4A4A4A) : Color(0xFF999999),
              size: 40,
            ),
            Expanded(
              child: Column(
                spacing: 4,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Color(0xFF4A4A4A) : Color(0xFF646464),
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: isSelected ? Color(0xFF4A4A4A) : Color(0xFF646464),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _appBar(BuildContext context) {
  return Container(
    padding: EdgeInsets.only(top: 65, left: 16, right: 16, bottom: 20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFFB23F1A), Color(0xFFE94C19)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(50),
        bottomRight: Radius.circular(50),
      ),
    ),
    child: Center(
      child: Text(
        "Solicitar Permissão",
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
