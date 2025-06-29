import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:driver_tracking_app/auth_service.dart';
import 'package:driver_tracking_app/database_service.dart';
import 'package:go_router/go_router.dart';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';


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
  bool _isTracking = false;

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
      setState(() {
        _isTracking = true;
      });
      _locationSubscription =
          _location.onLocationChanged.listen((LocationData locationData) {
        debugPrint(
            'New location received: ${locationData.latitude}, ${locationData.longitude}');
        setState(() {
          _currentLocation = locationData;
        });
        _databaseService.addLocationLog(locationData);
      });
    } else {
      debugPrint('Location permission denied.');
      setState(() {
        _isTracking = false;
      });
    }
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  @override

Widget build(BuildContext context) {
  final uri = Uri.parse(GoRouterState.of(context).uri.toString());
  final loginSuccess = uri.queryParameters['login'] == 'success';

  if (loginSuccess) {
    // Clear the query param by pushing to clean route
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ElegantNotification.success(
        title: const Text("Success"),
        description: const Text('Welcome, driver!'),
      ).show(context);

      // Remove query parameter to avoid repeated alert
      context.go('/');
    });
  }

  final user = _authService.currentUser;


    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () async {
              await _authService.signOut();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Text(
                'Welcome, ${user.email}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('GPS Tracking'),
              Switch(
                value: _isTracking,
                onChanged: (value) async {
                  if (value) {
                    await _requestPermissionsAndTrackLocation();
                  } else {
                    _locationSubscription?.cancel();
                    setState(() {
                      _isTracking = false;
                    });
                  }
                },
              ),
            ],
            ),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: _isTracking ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Live Location Status',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isTracking
                        ? 'Tracking is active. Your location is being shared.'
                        : 'Tracking is inactive. Grant location permissions to start.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Divider(height: 32),
                  _buildLocationInfo(
                    icon: Icons.gps_fixed,
                    label: 'Latitude',
                    value: _currentLocation?.latitude?.toStringAsFixed(6) ??
                        'N/A',
                  ),
                  const SizedBox(height: 12),
                  _buildLocationInfo(
                    icon: Icons.gps_fixed,
                    label: 'Longitude',
                    value: _currentLocation?.longitude?.toStringAsFixed(6) ??
                        'N/A',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue.shade700, size: 20),
        const SizedBox(width: 12),
        Text('$label: ', style: Theme.of(context).textTheme.titleMedium),
        const Spacer(),
        Text(value, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
} 