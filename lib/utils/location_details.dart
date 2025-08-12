import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart' as GeoCode;
// import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';

import 'package:location/location.dart';
import 'package:pristine_andaman/utils/constant.dart';

class GetLocation {
  LocationData? _currentPosition;

  late String _address = "";
  Location location1 = Location();
  String firstLocation = "", lat = "", lng = "";
  ValueChanged onResult;

  GetLocation(this.onResult);
  Future<void> getLoc() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location1.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location1.requestService();
      if (!_serviceEnabled) {
        print('ek');
        return;
      }
    }

    _permissionGranted = await location1.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location1.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        print('no');
        return;
      }
    }

    location1.onLocationChanged.listen((LocationData currentLocation) {
      print("${currentLocation.latitude} : ${currentLocation.longitude}");
      _currentPosition = currentLocation;
      print(currentLocation.latitude);
      latitudeFirst = _currentPosition!.latitude!;
      longitudeFirst = _currentPosition!.longitude!;
      if (latitude == 0) {
        getAddress(_currentPosition!.latitude, _currentPosition!.longitude)
            .then((value) {
          var first = value.first;
          //||latitude!=latitudeFirst
          print(
              '${first.name},${first.subLocality},${first.locality},${first.country}');
          if (latitude == 0) {
            onResult(value);
          }
        });
      }
    });
  }
}

Future<List<GeoCode.Placemark>> getAddress(double? lat, double? lng) async {
  List<GeoCode.Placemark> address =
      await GeoCode.placemarkFromCoordinates(lat ?? 0, lng ?? 0);
  return address;
}
