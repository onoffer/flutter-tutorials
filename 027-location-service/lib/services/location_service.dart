import 'dart:async';

import 'package:location/location.dart';
import 'package:location_service/datamodels/user_location.dart';

//# Location service:
class LocationService {
  UserLocation _userLocation;
  StreamController<UserLocation> _controller = StreamController<UserLocation>();

  // Singleton:
  static LocationService _instance = LocationService._();
  factory LocationService() => _instance;

  // Private constructor:
  LocationService._() {
    var location = Location();
    location.serviceEnabled().then((bool isEnabledState) {
      if (!isEnabledState) {
        location.requestService().then((bool isGrantedState) {
          if (!isGrantedState) return;
        });
      }
      location.hasPermission().then((PermissionStatus isPermittedState) {
        if (isPermittedState == PermissionStatus.denied) {
          location.requestPermission().then((PermissionStatus requestedPermissionState) {
            if (requestedPermissionState != PermissionStatus.granted) return;
          });
        }
      });
    });
    location.onLocationChanged.listen((LocationData data) {
      if (data != null) {
        _userLocation = UserLocation(latitude: data.latitude, longitude: data.longitude);
        _controller.add(_userLocation);
      }
    });
  }

  // Getters:
  UserLocation get location => _userLocation;
  Stream<UserLocation> get locationStream => _controller.stream;
}

