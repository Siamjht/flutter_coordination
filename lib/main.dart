import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LocationPage(),
    );
  }
}

class LocationPage extends StatelessWidget {
  final LocationController controller = Get.put(LocationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() => Text('Latitude: ${controller.latitude.value}, Longitude: ${controller.longitude.value}')),
            SizedBox(height: 20),
            Obx(() => Text('Address: ${controller.address.value}')),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                controller.determinePosition();
              },
              child: Text('Get Location'),
            ),
          ],
        ),
      ),
    );
  }
}

class LocationController extends GetxController {
  final latitude = RxDouble(0.0);
  final longitude = RxDouble(0.0);
  final address = RxString('');

  Future<void> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition();
    print("'latitude': ${position.latitude}, 'longitude': ${position.longitude}");
    latitude.value = position.latitude;
    longitude.value = position.longitude;
    await getAddressFromCoordinates(lat: latitude.value, long: longitude.value);
  }

  Future<void> getAddressFromCoordinates({required double lat, required double long}) async {
    print("$lat $long");
    try {
      List<Placemark> placeMarks = await placemarkFromCoordinates(
        lat,
        long,
      );
      List<Location> locations = await locationFromAddress("dhaka");
      print(locations.first);

      if (placeMarks.isNotEmpty) {
        Placemark placeMark = placeMarks.first;
        address.value = '${placeMark.street}, ${placeMark.locality}, ${placeMark.country}';
      }
    } catch (e) {
      print('Error getting address: $e');
    }
  }
}
