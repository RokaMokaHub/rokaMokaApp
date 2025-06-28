import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:async';
import 'post_qr_code_screen.dart';

class QRCodeScreen extends StatefulWidget {
  const QRCodeScreen({Key? key}) : super(key: key);

  @override
  State<QRCodeScreen> createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {
  bool showCamera = false;
  bool isScanned = false;
  bool cameraBusy = false;
  String? scannedValue;
  final MobileScannerController cameraController = MobileScannerController();
  Timer? _scanTimeoutTimer;

  int _retryCount = 0;
  final int _maxRetries = 3;
  final Duration _retryDelay = const Duration(seconds: 5);

  @override
  void dispose() {
    _stopScanTimeout();
    cameraController.dispose();
    super.dispose();
  }

  void _startScanTimeout() {
    _scanTimeoutTimer = Timer(const Duration(seconds: 10), () async {
      if (!isScanned && showCamera) {
        await _stopCamera();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tempo limite para leitura do QR Code atingido.'),
            ),
          );
        }
      }
    });
  }

  void _stopScanTimeout() {
    _scanTimeoutTimer?.cancel();
    _scanTimeoutTimer = null;
  }

  Future<void> _startCamera() async {
    if (cameraBusy) return;
    cameraBusy = true;
    try {
      await cameraController.stop();
      await Future.delayed(const Duration(milliseconds: 300));
      await cameraController.start();
      _startScanTimeout();
      _retryCount = 0;
    } catch (e) {
      print('Erro ao iniciar a câmera: $e');

      final String errorMessage = e.toString();

      if (errorMessage.contains('controllerInitializing') || errorMessage.contains('The MobileScannerController is still initializing')) {
        if (_retryCount < _maxRetries) {
          _retryCount++;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Câmera indisponível, aguarde ${_retryDelay.inSeconds}s e tente novamente. Tentativa $_retryCount de $_maxRetries.'),
              ),
            );
          }
          await Future.delayed(_retryDelay);
          if (mounted) {
            await _startCamera();
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Não foi possível iniciar a câmera após várias tentativas. Por favor, tente novamente mais tarde.')),
            );
            setState(() {
              showCamera = false;
            });
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao iniciar a câmera: $errorMessage')),
          );
          setState(() {
            showCamera = false;
          });
        }
      }
    } finally {
      cameraBusy = false;
    }
  }

  Future<void> _stopCamera() async {
    if (cameraBusy) return;
    cameraBusy = true;
    try {
      await cameraController.stop();
      setState(() {
        showCamera = false;
        isScanned = false;
        scannedValue = null;
      });
    } catch (e) {
      print('Erro ao parar a câmera: $e');
    } finally {
      _stopScanTimeout();
      cameraBusy = false;
    }
  }

  Future<bool> _onWillPop() async {
    if (showCamera) {
      await _stopCamera();
      return false;
    } else {
      return true;
    }
  }

  void _handleBackButton() {
    if (showCamera) {
      _onWillPop();
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
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
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
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
                                onDetect: (capture) async {
                                  if (!isScanned) {
                                    final String? code = capture.barcodes.first.rawValue;
                                    if (code != null) {
                                      setState(() {
                                        scannedValue = code;
                                        isScanned = true;
                                        showCamera = false;
                                      });
                                      _stopScanTimeout();
                                      await cameraController.stop();
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PostQRCodeScreen(artworkId: code),
                                        ),
                                      );
                                      setState(() {
                                        scannedValue = null;
                                        isScanned = false;
                                      });
                                    }
                                  }
                                },
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
                        padding: const EdgeInsets.symmetric(horizontal: 120, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: () async {
                        setState(() {
                          showCamera = true;
                          isScanned = false;
                          scannedValue = null;
                        });
                        WidgetsBinding.instance.addPostFrameCallback((_) async {
                          if (mounted) {
                            await _startCamera();
                          }
                        });
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