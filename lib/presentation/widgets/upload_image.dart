// image_upload_field.dart (novo arquivo)
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'snack_bar_rejeitada.dart';

class ImageUploadField extends StatefulWidget {
  final String label;
  final Function(XFile? imageFile) onImageSelected;

  const ImageUploadField({
    Key? key,
    required this.label,
    required this.onImageSelected,
  }) : super(key: key);

  @override
  _ImageUploadFieldState createState() => _ImageUploadFieldState();
}

class _ImageUploadFieldState extends State<ImageUploadField> {
  XFile? _displayedImageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      setState(() {
        _displayedImageFile = pickedFile;
      });
      widget.onImageSelected(_displayedImageFile);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBarRejeitada(
            titulo: 'Erro ao selecionar imagem',
            subtitulo: e.toString(),
          ).buildSnackBar(context),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Selecionar Fonte da Imagem"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: const Text("Galeria"),
                  onTap: () {
                    _pickImage(ImageSource.gallery);
                    Navigator.of(dialogContext).pop();
                  },
                ),
                const Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: const Text("Câmera"),
                  onTap: () {
                    _pickImage(ImageSource.camera);
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
            if (_displayedImageFile != null)
              Expanded(
                child: Image.file(
                  File(_displayedImageFile!.path),
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
              const Icon(
                Icons.attach_file_outlined,
                size: 32,
                color: Colors.grey,
              ),
            const SizedBox(height: 8),
            Text(
              _displayedImageFile != null ? 'Alterar Imagem' : widget.label,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}
