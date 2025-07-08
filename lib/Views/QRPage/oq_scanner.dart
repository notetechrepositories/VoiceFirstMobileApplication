import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  String? qrText;
  bool isFlashOn = false;
  final MobileScannerController controller = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Scan QR Code'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: MobileScanner(
              controller: controller,
              onDetect: (BarcodeCapture capture) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isEmpty || barcodes.first.rawValue == null) return;
                setState(() {
                  qrText = barcodes.first.rawValue;
                });
                controller.stop(); // stop scanning after first scan
              },
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              color: Colors.black,
              child: Column(
                children: [
                  Text(
                    qrText != null ? 'Scanned: $qrText' : 'Scan a code',
                    style: TextStyle(
                      color: qrText != null ? Color(0xFFFCC737) : Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      controller.toggleTorch();
                      setState(() => isFlashOn = !isFlashOn);
                    },
                    icon: Icon(isFlashOn ? Icons.flash_off : Icons.flash_on),
                    label: Text(isFlashOn ? 'Flash Off' : 'Flash On'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFCC737),
                      foregroundColor: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  if (qrText != null)
                    ElevatedButton.icon(
                      onPressed: () {
                        controller.start(); // Resume scanning
                        setState(() => qrText = null);
                      },
                      icon: Icon(Icons.restart_alt),
                      label: Text('Scan Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFCC737),
                        foregroundColor: Colors.black,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
