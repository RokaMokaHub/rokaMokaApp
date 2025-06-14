import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:async';

class QRCodeScreen extends StatefulWidget {
  const QRCodeScreen({Key? key}) : super(key: key);

  @override
  State<QRCodeScreen> createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {
  bool showCamera = false;
  bool isScanned = false;
  String? scannedValue;
  final MobileScannerController cameraController = MobileScannerController();
  Timer? _scanTimeoutTimer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant QRCodeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (showCamera && _scanTimeoutTimer == null) {
      _startScanTimeout();
    } else if (!showCamera && _scanTimeoutTimer != null) {
      _stopScanTimeout();
    }
  }

  void _startScanTimeout() {
    _scanTimeoutTimer = Timer(const Duration(seconds: 10), () {
      if (!isScanned && showCamera) {
        cameraController.stop();
        setState(() {
          showCamera = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tempo limite para leitura do QR Code atingido.'),
          ),
        );
      }
    });
  }

  void _stopScanTimeout() {
    _scanTimeoutTimer?.cancel();
    _scanTimeoutTimer = null;
  }

  Future<bool> _onWillPop() async {
    if (showCamera) {
      _stopScanTimeout();
      cameraController.stop();
      setState(() {
        showCamera = false;
        isScanned = false;
        scannedValue = null;
      });
      return false;
    } else {
      return true;
    }
  }

  void _handleBackButton() {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _stopScanTimeout();
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Imagem de fundo
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('lib/presentation/assets/images/backgroundQRScreen.png'),
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
                // Botão de voltar
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
                        if (showCamera)
                          Container(
                            height: 320,
                            width: 320,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.orange, width: 3),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: MobileScanner(
                                controller: cameraController,
                                onDetect: (capture) {
                                  if (!isScanned) {
                                    final String? code = capture.barcodes.first.rawValue;
                                    if (code != null) {
                                      setState(() {
                                        scannedValue = code;
                                        isScanned = true;
                                        showCamera = false;
                                      });
                                      _stopScanTimeout(); // Cancela o timer após a leitura
                                      cameraController.stop();
                                    }
                                  }
                                },
                              ),
                            ),
                          ),

                        const SizedBox(height: 36),

                        if (scannedValue != null && !showCamera)
                          Text(
                            'QR Code lido:\n$scannedValue',
                            style: const TextStyle(color: Colors.white, fontSize: 16),
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
                        padding: const EdgeInsets.symmetric(horizontal: 120, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          showCamera = true;
                          isScanned = false;
                          scannedValue = null;
                        });
                        cameraController.start();
                        _startScanTimeout(); // Inicia o timer ao abrir a câmera
                      },
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