import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:driver_tracking_app/auth_service.dart';
import 'package:driver_tracking_app/database_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  final Location _location = Location();
  StreamSubscription<LocationData>? _locationSubscription;
  LocationData? _currentLocation;

  @override
  void initState() {
    super.initState();
    _requestPermissionsAndTrackLocation();
  }

  Future<void> _requestPermissionsAndTrackLocation() async {
    final status = await Permission.location.request();
    debugPrint('Location permission status: $status');

    if (status.isGranted) {
      debugPrint('Location permission granted. Starting location tracking.');
      _locationSubscription =
          _location.onLocationChanged.listen((LocationData locationData) {
        debugPrint('New location received: ${locationData.latitude}, ${locationData.longitude}');
        setState(() {
          _currentLocation = locationData;
        });
        _databaseService.addLocationLog(locationData);
      });
    } else {
      debugPrint('Location permission denied.');
    }
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome! You are logged in.'),
            const SizedBox(height: 20),
            if (_currentLocation != null)
              Text(
                  'Lat: ${_currentLocation!.latitude}, Lng: ${_currentLocation!.longitude}')
            else
              const Text('Getting location...'),
          ],
        ),
      ),
    );
  }
} 