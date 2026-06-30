import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';
import '../widgets/snack_bar_rejeitada.dart';
import 'post_qr_code_screen.dart';

class QRCodeScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const QRCodeScreen({Key? key, this.onBack}) : super(key: key);

  @override
  State<QRCodeScreen> createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {
  bool _isScanning = false;

  Future<void> _scan() async {
    if (_isScanning) return;
    setState(() => _isScanning = true);

    try {
      final String result = await FlutterBarcodeScanner.scanBarcode(
        '#FF6600',
        'Cancelar',
        true,
        ScanMode.QR,
      );

      if (!mounted) return;

      if (result != '-1') {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostQRCodeScreen(qrCode: result),
          ),
        );
      }
    } on PlatformException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBarRejeitada(
          titulo: 'Erro ao iniciar a câmera',
          subtitulo: e.message ?? e.toString(),
        ).buildSnackBar(context),
      );
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                'lib/presentation/assets/images/backgroundQRScreen.png',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.black.withOpacity(0.6),
          body: Column(
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: widget.onBack ?? () => Navigator.pop(context),
                  ),
                ),
              ),
              const Spacer(),
              if (_isScanning)
                const CircularProgressIndicator(color: Colors.orange),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 120,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: _isScanning ? null : _scan,
                  child: const Text(
                    'Capturar Obra',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
