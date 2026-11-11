

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'l10n/app_localizations.dart';
import 'main.dart';


//  flutter gen-l10n run to genearte files in terminal

class MobileTracking extends StatefulWidget {
  const MobileTracking({Key? key}) : super(key: key);

  @override
  State<MobileTracking> createState() => _MobileTrackingState();
}

class _MobileTrackingState extends State<MobileTracking> {
  final TextEditingController _myPhoneController = TextEditingController();
  final TextEditingController _trackPhoneController = TextEditingController();
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Timer? _trackTimer;
  Timer? _sendTimer;

  final String serverUrl = 'http://10.164.48.23:5000'; // Replace with your PC's IP
  final LatLng _defaultLocation = LatLng(33.6844, 73.0479); // Islamabad

  @override
  void dispose() {
    _myPhoneController.dispose();
    _trackPhoneController.dispose();
    _trackTimer?.cancel();
    _sendTimer?.cancel();
    super.dispose();
  }

  void startSendingMyLocation(String phone) {
    phone = phone.trim();
    if (phone.isEmpty) return;

    _sendTimer?.cancel();
    _sendTimer = Timer.periodic(Duration(seconds: 10), (_) async {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      LocationPermission permission = await Geolocator.checkPermission();
      if (!serviceEnabled || permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      Position position = await Geolocator.getCurrentPosition();

      await http.post(
        Uri.parse('$serverUrl/update_location'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'lat': position.latitude,
          'lng': position.longitude,
        }),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ Sending location for $phone')),
    );
  }

  void startTrackingUser(String phone) {
    phone = phone.trim();
    if (phone.isEmpty) return;

    _trackTimer?.cancel();
    _trackTimer = Timer.periodic(Duration(seconds: 5), (_) => fetchAndDisplayLocation(phone));
  }

  Future<void> fetchAndDisplayLocation(String phone) async {
    try {
      final response = await http.get(Uri.parse('$serverUrl/get_location/$phone'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        LatLng location = LatLng(data['lat'], data['lng']);

        setState(() {
          _markers = {
            Marker(
              markerId: MarkerId(phone),
              position: location,
              infoWindow: InfoWindow(title: 'Tracking: $phone'),
            ),
          };
        });

        _mapController?.animateCamera(CameraUpdate.newLatLng(location));
      } else {
        print('❌ User not found');
      }
    } catch (e) {
      print('❌ Error: $e');
    }
  }
  void _toggleLanguage(BuildContext context) {
    final currentLang = Localizations.localeOf(context).languageCode;
    final newLang = currentLang == 'en' ? 'ur' : 'en';
    MyApp.setLocale(context, Locale(newLang));
  }

  @override
  Widget build(BuildContext context) {

    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.trackUser,style: TextStyle(
      fontSize: 18,
      fontFamily: "FontMain",
      color: Color(0xff012A4A)))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                TextField(
                  controller: _myPhoneController,
                  decoration: InputDecoration(
                    hintText: loc.number,
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff012A4A),),
                  onPressed: () => startSendingMyLocation(_myPhoneController.text),
                  child: Text(loc.sendLocation,style: TextStyle(
                      fontSize: 15,
                      fontFamily: "FontMain",
                      color: Colors.white)),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _trackPhoneController,
                  decoration: InputDecoration(
                    hintText: loc.track,
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff012A4A),),
                  onPressed: () => startTrackingUser(_trackPhoneController.text),
                  child: Text(loc.startTracking,style: TextStyle(
                      fontSize: 15,
                      fontFamily: "FontMain",
                      color: Colors.white)),
                ),
              ],
            ),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: _defaultLocation, zoom: 13),
              onMapCreated: (controller) => _mapController = controller,
              markers: _markers,
            ),
          ),
        ],
      ),
    );
  }
}



