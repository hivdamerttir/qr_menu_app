import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import '../providers/cart_provider.dart';
import './menu_screen.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  late MobileScannerController controller;
  bool isProcessing = false;
  bool isFlashOn = false;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restoran QR Kod Okuyucu'),
        actions: [
          IconButton(
            icon: Icon(isFlashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: () {
              setState(() {
                isFlashOn = !isFlashOn;
                controller.toggleTorch();
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) async {
              if (isProcessing) return;
              final List<Barcode> barcodes = capture.barcodes;

              if (barcodes.isEmpty) return;

              setState(() {
                isProcessing = true;
              });

              try {
                final restaurantId = barcodes.first.rawValue;
                if (restaurantId == null) return;

                final firebaseService = FirebaseService();
                final restaurant = await firebaseService.getRestaurantById(
                  restaurantId,
                );

                if (!mounted) return; // Set restaurant info in cart provider
                context.read<CartProvider>().setRestaurantInfo(
                  restaurant.id,
                  '1', // Default table number for now
                );

                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => MenuScreen(restaurant: restaurant),
                  ),
                );
              } catch (e) {
                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Geçersiz QR kod. Lütfen tekrar deneyin.'),
                  ),
                );
              } finally {
                setState(() {
                  isProcessing = false;
                });
              }
            },
          ),
          if (isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black54,
              padding: const EdgeInsets.all(16),
              child: const Text(
                'QR kodu kare içerisinde tutun',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 16),
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
