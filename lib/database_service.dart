import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:location/location.dart';

class DatabaseService {
  final _supabase = Supabase.instance.client;

  Future<void> addLocationLog(LocationData locationData) async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        debugPrint('Attempting to add location log for user ${user.id}');
        await _supabase.from('location_logs').insert({
          'user_id': user.id,
          'latitude': locationData.latitude,
          'longitude': locationData.longitude,
        });
        debugPrint('Location log added successfully.');
      } catch (e) {
        debugPrint('Error adding location log: $e');
      }
    } else {
      debugPrint('No user is currently signed in. Cannot add location log.');
    }
  }
} 