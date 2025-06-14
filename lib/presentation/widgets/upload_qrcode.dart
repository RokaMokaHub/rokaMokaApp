import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class QrCodeUploadField extends StatefulWidget {
  final String label;
  final Function(XFile? qrCodeFile) onQrCodeSelected;

  const QrCodeUploadField({
    Key? key,
    required this.label,
    required this.onQrCodeSelected,
  }) : super(key: key);

  @override
  _QrCodeUploadFieldState createState() => _QrCodeUploadFieldState();
}

class _QrCodeUploadFieldState extends State<QrCodeUploadField> {
  XFile? _qrCodeImageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickQrCodeImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      setState(() {
        _qrCodeImageFile = pickedFile;
      });
      widget.onQrCodeSelected(_qrCodeImageFile);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao selecionar imagem do QR Code: $e')),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Selecionar Imagem do QR Code"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: const Text("Galeria"),
                  onTap: () {
                    _pickQrCodeImage(ImageSource.gallery);
                    Navigator.of(dialogContext).pop();
                  },
                ),
                const Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: const Text("Câmera"),
                  onTap: () {
                    _pickQrCodeImage(ImageSource.camera);
                    Navigator.of(dialogContext).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _showImageSourceDialog,
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_qrCodeImageFile != null)
              Expanded(
                child: Image.file(
                  File(_qrCodeImageFile!.path),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 32),
                        SizedBox(height: 4),
                        Text(
                          'Erro ao carregar',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    );
                  },
                ),
              )
            else
              const Icon(Icons.qr_code_sharp, size: 32, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              _qrCodeImageFile != null ? 'Alterar QR Code' : widget.label,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}
