import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../../data/models/contact.dart';
import '../../../data/repositories/contact_repository.dart';
import '../../../services/location/location_service.dart';
import '../../widgets/contact/contact_card.dart';

class RadarMapScreen extends StatefulWidget {
  const RadarMapScreen({super.key});

  @override
  State<RadarMapScreen> createState() => _RadarMapScreenState();
}

class _RadarMapScreenState extends State<RadarMapScreen> with SingleTickerProviderStateMixin {
  Position? _currentPosition;
  List<Contact> _nearbyContacts = [];
  bool _isLoading = true;
  
  // Radar Animation
  late AnimationController _controller;

  // Config
  double _maxRangeKm = 5000; // Initial zoom level (5000km radius)

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    
    _initData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initData() async {
    // 1. Get User Location
    _currentPosition = await LocationService.instance.getCurrentLocation();
    
    // 2. Get Contacts
    final repo = Provider.of<ContactRepository>(context, listen: false);
    final allContacts = await repo.getAllContacts();
    
    // 3. Filter those with coordinates
    setState(() {
      _nearbyContacts = allContacts.where((c) => 
        c.latitude != null && c.longitude != null
      ).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }

    if (_currentPosition == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.gps_off, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text("GPS Required for Radar", style: TextStyle(color: Colors.white)),
              TextButton(onPressed: _initData, child: const Text("Retry"))
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Network Radar", style: TextStyle(color: Colors.green, fontFamily: 'Courier')),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_out_map, color: Colors.green),
            onPressed: () {
              setState(() {
                _maxRangeKm = _maxRangeKm == 5000 ? 500 : 5000; // Toggle Zoom
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Range: ${_maxRangeKm.toInt()} km"))
              );
            },
          )
        ],
      ),
      body: Stack(
        children: [
          // 1. The Radar Visualizer
          Positioned.fill(
            child: CustomPaint(
              painter: RadarPainter(
                center: _currentPosition!,
                contacts: _nearbyContacts,
                scanAngle: _controller,
                maxRangeKm: _maxRangeKm,
              ),
            ),
          ),

          // 2. Legend / Overlay
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.withOpacity(0.5)),
                ),
                child: Text(
                  "${_nearbyContacts.length} Signals Detected",
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RadarPainter extends CustomPainter {
  final Position center;
  final List<Contact> contacts;
  final Animation<double> scanAngle;
  final double maxRangeKm;

  RadarPainter({
    required this.center,
    required this.contacts,
    required this.scanAngle,
    required this.maxRangeKm,
  }) : super(repaint: scanAngle);

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = min(centerX, centerY) * 0.9;

    final paintGrid = Paint()
      ..color = Colors.green.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final paintBlip = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    // 1. Draw Radar Grid (Concentric Circles)
    canvas.drawCircle(Offset(centerX, centerY), radius, paintGrid);
    canvas.drawCircle(Offset(centerX, centerY), radius * 0.66, paintGrid);
    canvas.drawCircle(Offset(centerX, centerY), radius * 0.33, paintGrid);
    
    // Crosshairs
    canvas.drawLine(Offset(centerX, centerY - radius), Offset(centerX, centerY + radius), paintGrid);
    canvas.drawLine(Offset(centerX - radius, centerY), Offset(centerX + radius, centerY), paintGrid);

    // 2. Draw Contacts (Blips)
    for (var contact in contacts) {
      // Math to convert GPS diff to X/Y on radar
      final distKm = Geolocator.distanceBetween(
        center.latitude, center.longitude, 
        contact.latitude!, contact.longitude!
      ) / 1000;

      if (distKm > maxRangeKm) continue; // Out of range

      // Bearing (Angle)
      final bearing = Geolocator.bearingBetween(
        center.latitude, center.longitude, 
        contact.latitude!, contact.longitude!
      );
      
      // Convert Bearing to Radians (Flutter uses 0 = Right, Geolocation uses 0 = North)
      // Geo: 0=N, 90=E. Canvas: 0=E, 90=S. 
      // Adjust: (Bearing - 90) * (pi/180)
      final angleRad = (bearing - 90) * (pi / 180);
      
      // Scale distance to radius
      final scale = distKm / maxRangeKm;
      final blipRadius = radius * scale;

      final blipX = centerX + (blipRadius * cos(angleRad));
      final blipY = centerY + (blipRadius * sin(angleRad));

      // Draw Blip
      canvas.drawCircle(Offset(blipX, blipY), 4, paintBlip);
      
      // Optional: Draw Name if close
      if (scale > 0.2) {
        final textSpan = TextSpan(
          text: contact.name.split(' ')[0],
          style: TextStyle(color: Colors.green.withOpacity(0.8), fontSize: 10),
        );
        final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
        textPainter.layout();
        textPainter.paint(canvas, Offset(blipX + 5, blipY + 5));
      }
    }

    // 3. Draw Scanner Sweep
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        colors: [Colors.green.withOpacity(0.0), Colors.green.withOpacity(0.5)],
        stops: const [0.75, 1.0],
        transform: GradientRotation(scanAngle.value * 2 * pi),
      ).createShader(Rect.fromCircle(center: Offset(centerX, centerY), radius: radius));
    
    canvas.drawCircle(Offset(centerX, centerY), radius, sweepPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}