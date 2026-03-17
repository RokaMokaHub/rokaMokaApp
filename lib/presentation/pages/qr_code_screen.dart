import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:async';
import '../widgets/snack_bar_rejeitada.dart';
import 'post_qr_code_screen.dart';

class QRCodeScreen extends StatefulWidget {
  const QRCodeScreen({Key? key}) : super(key: key);

  @override
  State<QRCodeScreen> createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {
  bool showCamera = false;
  bool isScanned = false;
  String? scannedValue;
  MobileScannerController? _cameraController;
  Timer? _scanTimeoutTimer;

  @override
  void dispose() {
    _stopScanTimeout();
    _cameraController?.dispose();
    super.dispose();
  }

  void _startScanTimeout() {
    _scanTimeoutTimer = Timer(const Duration(seconds: 60), () async {
      if (!isScanned && showCamera) {
        await _closeCamera();
      }
    });
  }

  void _stopScanTimeout() {
    _scanTimeoutTimer?.cancel();
    _scanTimeoutTimer = null;
  }

  /// Fecha a câmera e limpa o estado. Pode ser chamado de qualquer lugar.
  Future<void> _closeCamera() async {
    _stopScanTimeout();
    final old = _cameraController;
    if (mounted) {
      setState(() {
        showCamera = false;
        isScanned = false;
        scannedValue = null;
        _cameraController = null;
      });
    }
    try {
      await old?.stop();
      await old?.dispose();
    } catch (_) {}
  }

  /// Abre uma nova sessão de scan:
  /// 1. Cria controller fresco com autoStart: false
  /// 2. Monta o widget MobileScanner
  /// 3. Chama start() via postFrameCallback (exigido pelo mobile_scanner v7)
  void _openCamera() {
    final newController = MobileScannerController(autoStart: false);
    setState(() {
      showCamera = true;
      isScanned = false;
      scannedValue = null;
      _cameraController = newController;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      try {
        await newController.start();
        _startScanTimeout();
      } catch (e) {
        debugPrint('Erro ao iniciar câmera: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBarRejeitada(
              titulo: 'Erro ao iniciar a câmera',
              subtitulo: e.toString(),
            ).buildSnackBar(context),
          );
          await _closeCamera();
        }
      }
    });
  }

  Future<bool> _onWillPop() async {
    if (showCamera) {
      await _closeCamera();
      return false;
    }
    return true;
  }

  void _handleBackButton() {
    if (showCamera) _closeCamera();
    // Quando a câmera não está aberta não faz nada — QRCodeScreen é
    // embutida no HomeController, não é uma rota empurrada.
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
        WillPopScope(
          onWillPop: _onWillPop,
          child: Scaffold(
            backgroundColor: Colors.black.withOpacity(0.6),
            body: Column(
              children: [
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
                      onPressed: _handleBackButton,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (showCamera && _cameraController != null)
                          Container(
                            height: 320,
                            width: 320,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.orange,
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: MobileScanner(
                                controller: _cameraController!,
                                onDetect: (capture) async {
                                  if (!isScanned) {
                                    final String? code =
                                        capture.barcodes.first.rawValue;
                                    if (code != null) {
                                      setState(() {
                                        scannedValue = code;
                                        isScanned = true;
                                      });
                                      await _closeCamera();
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PostQRCodeScreen(qrCode: code),
                                        ),
                                      );
                                      if (mounted) {
                                        setState(() => scannedValue = null);
                                      }
                                    }
                                  }
                                },
                              ),
                            ),
                          ),

                        if (showCamera && _cameraController == null)
                          const SizedBox(
                            height: 320,
                            width: 320,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.orange,
                              ),
                            ),
                          ),

                        const SizedBox(height: 36),
                        if (scannedValue != null && !showCamera)
                          const Text(
                            'QR Code lido! Redirecionando...',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                      ],
                    ),
                  ),
                ),
                if (!showCamera && scannedValue == null)
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
                      onPressed: _openCamera,
                      child: const Text(
                        'Capturar Obra',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
